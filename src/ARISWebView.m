//
//  ARISWebView.m
//  ARIS
//
//  Created by Phil Dougherty on 7/30/13.
//
//

#import "ARISWebView.h"
#import "AppModel.h"
#import "AppServices.h"
#import "ARISAppDelegate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ARISWebView()
{
    NSMutableDictionary *audioPlayers;
    id<ARISWebViewDelegate,StateControllerProtocol> __unsafe_unretained delegate;
}
@property (nonatomic, strong) NSMutableDictionary *audioPlayers;

@end

@implementation ARISWebView

@synthesize audioPlayers;

- (id) initWithFrame:(CGRect)frame delegate:(id<ARISWebViewDelegate,StateControllerProtocol>)d
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
        [self setDelegate:d];
    }
    return self;
}

- (id) initWithDelegate:(id<ARISWebViewDelegate,StateControllerProtocol>)d
{
    if(self = [super init])
    {
        [self initialize];
        [self setDelegate:d];
    }
    return self;
}

- (void) initialize
{
    self.audioPlayers = [[NSMutableDictionary alloc] initWithCapacity:10];
}

- (void) setDelegate:(id<ARISWebViewDelegate,StateControllerProtocol>)d
{
    [super setDelegate:d];
    delegate = d;
}

- (void) loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    [super loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
}

- (void) loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [super loadHTMLString:string baseURL:baseURL];
}

- (void) loadRequest:(NSURLRequest *)request
{
    [self loadRequest:request withAppendation:@""];
}

- (void) loadRequest:(NSURLRequest *)request withAppendation:(NSString *)appendation
{
    NSString *url = [[request URL] absoluteString];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];//PHIL REMOVING CACHES
    
    if([url rangeOfString:@"?"].location == NSNotFound)
        url = [url stringByAppendingString:[NSString stringWithFormat:@"?gameId=%d&playerId=%d&aris=1%@",[AppModel sharedAppModel].currentGame.gameId, [AppModel sharedAppModel].player.playerId, appendation]];
    else
        url = [url stringByAppendingString:[NSString stringWithFormat:@"&gameId=%d&playerId=%d&aris=1%@",[AppModel sharedAppModel].currentGame.gameId, [AppModel sharedAppModel].player.playerId, appendation]];
    
    NSLog(@"ARISWebView loadingRequest: %@",url);
    [super loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void) injectHTMLWithARISjs
{
    NSString *arisjs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"arisjs" ofType:@"js"] encoding:NSASCIIStringEncoding error:NULL];
    [self stringByEvaluatingJavaScriptFromString:arisjs];
}

- (BOOL) isARISRequest:(NSURLRequest *)request
{
    return [[[[request URL] scheme] lowercaseString] isEqualToString:@"aris"];
}

- (BOOL) handleARISRequestIfApplicable:(NSURLRequest *)request
{
    NSLog(@"ARISWebView received: %@",[[request URL] absoluteString]);
    if(![self isARISRequest:request]) return NO;
    
    [self stringByEvaluatingJavaScriptFromString: @"ARIS.isCurrentlyCalling();"];
    
    NSString *mainCommand = [[request URL] host];
    NSArray *components   = [[request URL] pathComponents];
    
    if([mainCommand isEqualToString:@"closeMe"])
    {
        [self clear];
        [delegate ARISWebViewRequestsDismissal:self];
    }
    else if([mainCommand isEqualToString:@"leaveButton"])
    {
        if([components count] > 1 && [[components objectAtIndex:1] isEqualToString:@"disable"])
            [delegate ARISWebViewRequestsHideButton:self];
    }
    else if([mainCommand isEqualToString:@"exitTo"])
    {
        [self clear];
        
        NSString *type = @"";
        NSString *token = @"";
        if([components count] > 1) type  = [components objectAtIndex:1];
        if([components count] > 2) token = [components objectAtIndex:2];
        
        if([type isEqualToString:@"tab"])
            [delegate displayTab:token];
        else if([type isEqualToString:@"scanner"])
            [delegate displayScannerWithPrompt:token];
        else if([type isEqualToString:@"trade"])
            [delegate displayTrade]; 
        else if([type isEqualToString:@"plaque"])
            [delegate displayGameObject:[[AppModel sharedAppModel] nodeForNodeId:[token intValue]]           fromSource:delegate];
        else if([type isEqualToString:@"webpage"])
            [delegate displayGameObject:[[AppModel sharedAppModel] webPageForWebPageId:[token intValue]]     fromSource:delegate];
        else if([type isEqualToString:@"item"])
            [delegate displayGameObject:[[AppModel sharedAppModel] itemForItemId:[token intValue]]           fromSource:delegate];
        else if([type isEqualToString:@"character"])
            [delegate displayGameObject:[[AppModel sharedAppModel] npcForNpcId:[token intValue]]             fromSource:delegate];
        else if([type isEqualToString:@"panoramic"])
            [delegate displayGameObject:[[AppModel sharedAppModel] panoramicForPanoramicId:[token intValue]] fromSource:delegate];
    }
    else if([mainCommand isEqualToString:@"refreshStuff"])
    {
        [[AppServices sharedAppServices] fetchAllPlayerLists];
        [delegate ARISWebViewRequestsRefresh:self];
    }
    else if([mainCommand isEqualToString:@"vibrate"])
        [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] vibrate];
    else if([mainCommand isEqualToString:@"player"])
    {
        Media *playerMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId ofType:@"PHOTO"];
        NSString *playerJSON = [NSString stringWithFormat:
                                @"{"
                                "\"playerId\":%d," 
                                "\"username\":\"%@\","
                                "\"displayname\":\"%@\"," 
                                "\"photoURL\":\"%@\"" 
                                "}",
                                [AppModel sharedAppModel].player.playerId,
                                [AppModel sharedAppModel].player.username, 
                                [AppModel sharedAppModel].player.displayname, 
                                playerMedia.url];
        [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didReceivePlayer(%@);",playerJSON]];
    }
    else if([mainCommand isEqualToString:@"inventory"])
    {
        if([components count] > 2 && [[components objectAtIndex:1] isEqualToString:@"get"])
        {
            int itemId = [[components objectAtIndex:2] intValue];
            int qty = [self getQtyInInventoryOfItem:itemId];
            [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%d,%d);",itemId,qty]];
        }
        if([components count] > 3 && [[components objectAtIndex:1] isEqualToString:@"set"])
        {
            int itemId = [[components objectAtIndex:2] intValue];
            int qty = [[components objectAtIndex:3] intValue];
            int newQty = [self setQtyInInventoryOfItem:itemId toQty:qty];
            [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%d,%d);",itemId,newQty]];
        }
        if([components count] > 3 && [[components objectAtIndex:1] isEqualToString:@"give"])
        {
            int itemId = [[components objectAtIndex:2] intValue];
            int qty = [[components objectAtIndex:3] intValue];
            int newQty = [self giveQtyInInventoryToItem:itemId ofQty:qty];
            [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%d,%d);",itemId,newQty]];
        }
        if([components count] > 3 && [[components objectAtIndex:1] isEqualToString:@"take"])
        {
            int itemId = [[components objectAtIndex:2] intValue];
            int qty = [[components objectAtIndex:3] intValue];
            int newQty = [self takeQtyInInventoryFromItem:itemId ofQty:qty];
            [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%d,%d);",itemId,newQty]];
        }
    }
    else if([mainCommand isEqualToString:@"media"])
    {
        if([components count] > 2 && [[components objectAtIndex:1] isEqualToString:@"prepare"])
            [self loadAudioFromMediaId:[[components objectAtIndex:2] intValue]];
        else if([components count] > 2 && [[components objectAtIndex:1] isEqualToString:@"play"])
            [self playAudioFromMediaId:[[components objectAtIndex:2] intValue]];
        else if([components count] > 2 && [[components objectAtIndex:1] isEqualToString:@"stop"])
            [self stopAudioFromMediaId:[[components objectAtIndex:2] intValue]];
        else if([components count] > 3 && [[components objectAtIndex:1] isEqualToString:@"setVolume"])
            [self setMediaId:[[components objectAtIndex:2] intValue] volumeTo:[[components objectAtIndex:3] floatValue]];
        else if([components count] > 2 && [[components objectAtIndex:1] isEqualToString:@"playAndVibrate"])
        {
            [self playAudioFromMediaId:[[components objectAtIndex:2] intValue]];
            [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] vibrate];
        }
    }
    
    [self stringByEvaluatingJavaScriptFromString:@"ARIS.isNotCurrentlyCalling();"];
    return YES;
}

- (void) loadAudioFromMediaId:(int)mediaId
{
    Media* media = [[AppModel sharedAppModel] mediaForMediaId:mediaId ofType:@"AUDIO"];
    NSURL* url = [NSURL URLWithString:media.url];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    [audioPlayers setObject:player forKey:[NSNumber numberWithInt:mediaId]];
}

- (void) playAudioFromMediaId:(int)mediaId
{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithInt:mediaId]];
    CMTime zero = CMTimeMakeWithSeconds(0, 600);
    [player seekToTime:zero];
    if(!player)
    {
        [self loadAudioFromMediaId:mediaId];
        player = [audioPlayers objectForKey:[NSNumber numberWithInt:mediaId]];
    }
    [player play];
}

- (void) stopAudioFromMediaId:(int)mediaId
{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithInt:mediaId]];
    [player pause];
}

- (void) setMediaId:(int)mediaId volumeTo:(float)volume
{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithInt:mediaId]];
    
    NSArray *audioTracks = [player.currentItem.asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    player.currentItem.audioMix = audioMix;
    
}

- (int) getQtyInInventoryOfItem:(int)itemId
{
    Item *i;
    if((i = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:itemId]))   return i.qty;
    if((i = [[AppModel sharedAppModel].currentGame.attributesModel attributesItemForId:itemId])) return i.qty;
    return 0;
}

- (int) setQtyInInventoryOfItem:(int)itemId toQty:(int)qty
{
    if(qty < 1) qty = 0;
    [[AppServices sharedAppServices] updateServerInventoryItem:itemId qty:qty];
    
    Item *i = [[AppModel sharedAppModel] itemForItemId:itemId];
    int newQty = 0;
    if(i.itemType != ItemTypeAttribute)
    {
        Item *ii = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:itemId];
        if     (ii && ii.qty < qty) newQty = [[AppModel sharedAppModel].currentGame.inventoryModel addItemToInventory:i      qtyToAdd:qty-ii.qty];
        else if(ii && ii.qty > qty) newQty = [[AppModel sharedAppModel].currentGame.inventoryModel removeItemFromInventory:i qtyToRemove:ii.qty-qty];
        else if(!ii && qty > 0)     newQty = [[AppModel sharedAppModel].currentGame.inventoryModel addItemToInventory:i      qtyToAdd:qty];
    }
    else
    {
        Item *ii = [[AppModel sharedAppModel].currentGame.attributesModel attributesItemForId:itemId];
        if     (ii && ii.qty < qty) newQty = [[AppModel sharedAppModel].currentGame.attributesModel addItemToAttributes:i      qtyToAdd:qty-ii.qty];
        else if(ii && ii.qty > qty) newQty = [[AppModel sharedAppModel].currentGame.attributesModel removeItemFromAttributes:i qtyToRemove:ii.qty-qty];
        else if(!ii && qty > 0)     newQty = [[AppModel sharedAppModel].currentGame.attributesModel addItemToAttributes:i      qtyToAdd:qty];
    }
    return newQty;
}

- (int) giveQtyInInventoryToItem:(int)itemId ofQty:(int)qty
{
    [[AppServices sharedAppServices] updateServerAddInventoryItem:itemId addQty:qty];
    
    Item *i = [[AppModel sharedAppModel] itemForItemId:itemId];
    int newQty = 0;
    if(i.itemType != ItemTypeAttribute) newQty = [[AppModel sharedAppModel].currentGame.inventoryModel addItemToInventory:i   qtyToAdd:qty];
    else                                newQty = [[AppModel sharedAppModel].currentGame.attributesModel addItemToAttributes:i qtyToAdd:qty];
    
    return newQty;
}

- (int) takeQtyInInventoryFromItem:(int)itemId ofQty:(int)qty
{
    [[AppServices sharedAppServices] updateServerAddInventoryItem:itemId addQty:qty];
    
    Item *i = [[AppModel sharedAppModel] itemForItemId:itemId];
    int newQty = 0;
    if(i.itemType != ItemTypeAttribute) newQty = [[AppModel sharedAppModel].currentGame.inventoryModel  removeItemFromInventory:i  qtyToRemove:qty];
    else                                newQty = [[AppModel sharedAppModel].currentGame.attributesModel removeItemFromAttributes:i qtyToRemove:qty];
    [[AppServices sharedAppServices] updateServerRemoveInventoryItem:itemId removeQty:qty];
    
    return newQty;
}

- (void) hookWithParams:(NSString *)params
{
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.hook(%@);",params]];
}

- (void) clear
{
    [self stopLoading];
    [self loadHTMLString:@"" baseURL:nil]; //clears out any pusher connections, etc...
    [self.audioPlayers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        AVPlayer *player = obj;
        [player pause];
    }];
}

- (void) dealloc
{
    [self clear];
}

@end

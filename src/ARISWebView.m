//
//  ARISWebView.m
//  ARIS
//
//  Created by Phil Dougherty on 7/30/13.
//
//

#import "ARISWebView.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "AppServices.h"
#import "User.h"
#import "ARISAppDelegate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ARISWebView() <UIWebViewDelegate>
{
    UIWebView *webView;
    NSMutableDictionary *audioPlayers;
    id<ARISWebViewDelegate,StateControllerProtocol> __unsafe_unretained delegate;
}

@end

@implementation ARISWebView

- (id) initWithFrame:(CGRect)frame delegate:(id<ARISWebViewDelegate,StateControllerProtocol>)d
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
        [self setDelegate:d];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
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
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.delegate = self; 
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO; 
    [self addSubview:webView];
    audioPlayers = [[NSMutableDictionary alloc] initWithCapacity:10];
}

- (void) setFrame:(CGRect)f
{
    [super setFrame:f];
    webView.frame = self.bounds;
}

- (void) setDelegate:(id<ARISWebViewDelegate,StateControllerProtocol>)d
{
    delegate = d;
}

- (void) loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [webView loadHTMLString:string baseURL:baseURL];
}

- (NSString *) stringByEvaluatingJavaScriptFromString:(NSString *)s;
{
    return [webView stringByEvaluatingJavaScriptFromString:s];
}

- (void) stopLoading
{
    [webView stopLoading];
}

- (UIScrollView *) scrollView
{
    return webView.scrollView;
}

- (void) setScalesPageToFit:(BOOL)s
{
    webView.scalesPageToFit = s;
}

- (void) setAllowsInlineMediaPlayback:(BOOL)a
{
    webView.allowsInlineMediaPlayback = a; 
}

- (void) setMediaPlaybackRequiresUserAction:(BOOL)m
{
    webView.mediaPlaybackRequiresUserAction = m; 
}

- (void) loadRequest:(NSURLRequest *)request
{
    NSLog(@"ARISWebView loadingRequest: %@",request);
    //[[NSURLCache sharedURLCache] removeAllCachedResponses];//Uncomment to clear cache
    [webView loadRequest:request]; 
}

- (void) loadRequest:(NSURLRequest *)request withAppendation:(NSString *)appendation
{
    NSString *url = [[request URL] absoluteString];
    
    if([url rangeOfString:@"?"].location == NSNotFound)
        url = [url stringByAppendingString:[NSString stringWithFormat:@"?game_id=%d&user_id=%d&aris=1%@",_MODEL_GAME_.game_id, _MODEL_PLAYER_.user_id, appendation]];
    else
        url = [url stringByAppendingString:[NSString stringWithFormat:@"&game_id=%d&user_id=%d&aris=1%@",_MODEL_GAME_.game_id, _MODEL_PLAYER_.user_id, appendation]];
    
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]]; 
}

- (BOOL) webView:(UIWebView*)wv shouldStartLoadWithRequest:(NSURLRequest*)r navigationType:(UIWebViewNavigationType)nt
{
    NSString *url = [r URL].absoluteString;
    if([url isEqualToString:@"about:blank"]) return YES;
    if([self isARISRequest:r]) { [self handleARISRequest:r]; return NO; }
    
    if([delegate respondsToSelector:@selector(ARISWebView:shouldStartLoadWithRequest:navigationType:)])  
        return [delegate ARISWebView:self shouldStartLoadWithRequest:r navigationType:nt];
    return NO;
}
    
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    if([delegate respondsToSelector:@selector(ARISWebViewDidStartLoad:)])
        [delegate ARISWebViewDidStartLoad:self];
}

- (void) webViewDidFinishLoad:(UIWebView *)wv
{
    [self injectHTMLWithARISjs];
    if([delegate respondsToSelector:@selector(ARISWebViewDidFinishLoad:)]) 
        [delegate ARISWebViewDidFinishLoad:self];
}

- (void) injectHTMLWithARISjs
{
    NSString *arisjs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"arisjs" ofType:@"js"] encoding:NSASCIIStringEncoding error:NULL];
    [webView stringByEvaluatingJavaScriptFromString:arisjs];
}

- (BOOL) isARISRequest:(NSURLRequest *)request
{
    return [[[[request URL] scheme] lowercaseString] isEqualToString:@"aris"];
}

- (void) handleARISRequest:(NSURLRequest *)request
{
    NSLog(@"ARISWebView received: %@",[[request URL] absoluteString]);
    [webView stringByEvaluatingJavaScriptFromString: @"ARIS.isCurrentlyCalling();"];
    
    NSString *mainCommand = [[request URL] host];
    NSArray *components   = [[request URL] pathComponents];
    
    if([mainCommand isEqualToString:@"closeMe"])
    {
        [self clear];
        if([delegate respondsToSelector:@selector(ARISWebViewRequestsDismissal:)])   
            [delegate ARISWebViewRequestsDismissal:self];
    }
    else if([mainCommand isEqualToString:@"leaveButton"])
    {
        if(components.count > 1 && [[components objectAtIndex:1] isEqualToString:@"disable"])
            if([delegate respondsToSelector:@selector(ARISWebViewRequestsHideButton:)])    
                [delegate ARISWebViewRequestsHideButton:self];
    }
    else if([mainCommand isEqualToString:@"exitTo"])
    {
        [self clear];
        
        NSString *type = @"";
        NSString *token = @"";
        if(components.count > 1) type  = [components objectAtIndex:1];
        if(components.count > 2) token = [components objectAtIndex:2];
        
        if([type isEqualToString:@"tab"])
        {
            if([delegate respondsToSelector:@selector(displayTab:)])     
                [delegate displayTab:token];
        }
        else if([type isEqualToString:@"scanner"])
        {
            if([delegate respondsToSelector:@selector(displayScannerWithPrompt:)])      
                [delegate displayScannerWithPrompt:token];
        }
        else if([type isEqualToString:@"plaque"])
        {
            if([delegate respondsToSelector:@selector(displayGameObject:fromSource:)])       
                [delegate displayGameObject:[_MODEL_PLAQUES_ plaqueForId:[token intValue]] fromSource:delegate];
        }
        else if([type isEqualToString:@"webpage"])
        {
            if([delegate respondsToSelector:@selector(displayGameObject:fromSource:)])        
                [delegate displayGameObject:[_MODEL_WEBPAGES_ webPageForId:[token intValue]] fromSource:delegate];
        }
        else if([type isEqualToString:@"item"])
        {
            if([delegate respondsToSelector:@selector(displayGameObject:fromSource:)])        
                [delegate displayGameObject:[_MODEL_ITEMS_ itemForId:[token intValue]] fromSource:delegate];
        }
        else if([type isEqualToString:@"character"])
        {
            if([delegate respondsToSelector:@selector(displayGameObject:fromSource:)])        
                [delegate displayGameObject:[_MODEL_NPCS_ npcForId:[token intValue]] fromSource:delegate];
        }
    }
    else if([mainCommand isEqualToString:@"refreshStuff"])
    {
        [_SERVICES_ fetchAllPlayerLists];
        if([delegate respondsToSelector:@selector(ARISWebViewRequestsRefresh:)])
            [delegate ARISWebViewRequestsRefresh:self];
    }
    else if([mainCommand isEqualToString:@"vibrate"])
        [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] vibrate];
    else if([mainCommand isEqualToString:@"player"])
    {
        Media *playerMedia = [_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id];
        NSString *playerJSON = [NSString stringWithFormat:
                                @"{"
                                "\"user_id\":%d," 
                                "\"user_name\":\"%@\","
                                "\"display_name\":\"%@\"," 
                                "\"photoURL\":\"%@\"" 
                                "}",
                                _MODEL_PLAYER_.user_id,
                                _MODEL_PLAYER_.user_name, 
                                _MODEL_PLAYER_.display_name, 
                                playerMedia.remoteURL];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didReceivePlayer(%@);",playerJSON]];
    }
    else if([mainCommand isEqualToString:@"inventory"])
    {
        if(components.count > 2 && [[components objectAtIndex:1] isEqualToString:@"get"])
        {
            int item_id = [[components objectAtIndex:2] intValue];
            int qty = [_MODEL_ITEMS_ qtyOwnedForItem:item_id];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%d,%d);",item_id,qty]];
        }
        if(components.count > 3 && [[components objectAtIndex:1] isEqualToString:@"set"])
        {
            int item_id = [[components objectAtIndex:2] intValue];
            int qty = [[components objectAtIndex:3] intValue];
            int newQty = [_MODEL_ITEMS_ setItemsForPlayer:item_id qtyToSet:qty];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%d,%d);",item_id,newQty]];
        }
        if(components.count > 3 && [[components objectAtIndex:1] isEqualToString:@"give"])
        {
            int item_id = [[components objectAtIndex:2] intValue];
            int qty = [[components objectAtIndex:3] intValue];
            int newQty = [_MODEL_ITEMS_ giveItemToPlayer:item_id qtyToAdd:qty];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%d,%d);",item_id,newQty]];
        }
        if(components.count > 3 && [[components objectAtIndex:1] isEqualToString:@"take"])
        {
            int item_id = [[components objectAtIndex:2] intValue];
            int qty = [[components objectAtIndex:3] intValue];
            int newQty = [_MODEL_ITEMS_ takeItemFromPlayer:item_id qtyToRemove:qty];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%d,%d);",item_id,newQty]];
        }
    }
    else if([mainCommand isEqualToString:@"media"])
    {
        if(components.count > 2 && [[components objectAtIndex:1] isEqualToString:@"prepare"])
            [self loadAudioFromMediaId:[[components objectAtIndex:2] intValue]];
        else if(components.count > 2 && [[components objectAtIndex:1] isEqualToString:@"play"])
            [self playAudioFromMediaId:[[components objectAtIndex:2] intValue]];
        else if(components.count > 2 && [[components objectAtIndex:1] isEqualToString:@"stop"])
            [self stopAudioFromMediaId:[[components objectAtIndex:2] intValue]];
        else if(components.count > 3 && [[components objectAtIndex:1] isEqualToString:@"setVolume"])
            [self setMediaId:[[components objectAtIndex:2] intValue] volumeTo:[[components objectAtIndex:3] floatValue]];
        else if(components.count > 2 && [[components objectAtIndex:1] isEqualToString:@"playAndVibrate"])
        {
            [self playAudioFromMediaId:[[components objectAtIndex:2] intValue]];
            [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] vibrate];
        }
    }
    
    [webView stringByEvaluatingJavaScriptFromString:@"ARIS.isNotCurrentlyCalling();"];
}

- (void) loadAudioFromMediaId:(int)media_id
{
    Media* media = [_MODEL_MEDIA_ mediaForId:media_id];
    AVPlayer *player = [AVPlayer playerWithURL:media.localURL];
    [audioPlayers setObject:player forKey:[NSNumber numberWithInt:media_id]];
}

- (void) playAudioFromMediaId:(int)media_id
{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithInt:media_id]];
    CMTime zero = CMTimeMakeWithSeconds(0, 600);
    [player seekToTime:zero];
    if(!player)
    {
        [self loadAudioFromMediaId:media_id];
        player = [audioPlayers objectForKey:[NSNumber numberWithInt:media_id]];
    }
    [player play];
}

- (void) stopAudioFromMediaId:(int)media_id
{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithInt:media_id]];
    [player pause];
}

- (void) setMediaId:(int)media_id volumeTo:(float)volume
{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithInt:media_id]];
    
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

- (void) hookWithParams:(NSString *)params
{
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.hook(%@);",params]];
}

- (void) clear
{
    [webView stopLoading];
    webView.delegate = nil; 
    [webView loadHTMLString:@"" baseURL:nil]; //clears out any pusher connections, etc...
    [audioPlayers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        AVPlayer *player = obj;
        [player pause];
    }];
}

- (void) dealloc
{
    [self clear];
}

@end

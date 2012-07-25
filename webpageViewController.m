//
//  webpageViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "webpageViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "NodeOption.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "DialogViewController.h"
#import "NodeViewController.h"
#import "QuestsViewController.h"
#import "ItemDetailsViewController.h"

@implementation webpageViewController
@synthesize webView,webPage,delegate,activityIndicator,blackView, audioPlayers, bumpSendString, isConnectedToBump;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isConnectedToBump = NO;
        self.bumpSendString = @"";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.audioPlayers = [[NSMutableDictionary alloc] init];
    self.webView.delegate = self;
    self.webView.hidden = YES;
    //Create a close button
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"")
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	
    
    
    //Create a URL object.
    NSString *urlAddress = self.webPage.url;
    
    //Check to prepend url query with '?' or '&'
    if([self.webPage.url rangeOfString:@"?"].location == NSNotFound)
        urlAddress = [self.webPage.url stringByAppendingString: [NSString stringWithFormat: @"?gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, webPage.webPageId, [AppModel sharedAppModel].playerId]];
    else       
        urlAddress = [self.webPage.url stringByAppendingString: [NSString stringWithFormat: @"&gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, webPage.webPageId, [AppModel sharedAppModel].playerId]];
    
    NSLog(@"WebPageVC: Loading URL: %@",urlAddress);
    NSURL *url = [NSURL URLWithString:urlAddress];
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Config the webView
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    
}

-(void)viewDidAppear:(BOOL)animated{
    self.webView.hidden = YES;
    self.blackView.hidden = NO;
}

- (void)viewDidUnload
{
    NSLog(@"WebPageVC: viewDidUnload");
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"WebPageVC: viewWillDisapear");
    [self.audioPlayers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        AVPlayer *player = obj;
        [player pause]; 
    }];
}

#pragma mark -
#pragma mark General Logic
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webView.hidden = NO;
    self.blackView.hidden = YES;
    [self dismissWaitingIndicator];
}
-(void)webViewDidStartLoad:(UIWebView *)webView {
    [self showWaitingIndicator];
}
-(void)showWaitingIndicator {
    [self.activityIndicator startAnimating];
}

-(void)dismissWaitingIndicator {
    [self.activityIndicator stopAnimating];
}

- (IBAction)backButtonTouchAction: (id) sender{
    if(self.isConnectedToBump) [BumpClient sharedClient].bumpable = NO;

	NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerWebPageViewed:webPage.webPageId fromLocation:webPage.locationId];
	
	
    if([self.delegate isKindOfClass:[DialogViewController class]]) [self refreshConvos];
	if([self.delegate isKindOfClass:[DialogViewController class]] || 
       [self.delegate isKindOfClass:[NodeViewController class]] || 
       [self.delegate isKindOfClass:[QuestsViewController class]] ||
       [self.delegate isKindOfClass:[ItemDetailsViewController class]])
        [self.navigationController popToRootViewControllerAnimated:YES];
    else{
        ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.modalPresent=NO;
        [appDelegate dismissNearbyObjectView:self];    
    }
}

#pragma mark -
#pragma mark ARIS/JavaScript Connections

- (BOOL)webView:(UIWebView*)webViewFromMethod shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType { 
    self.webView = webViewFromMethod;
    [self.webView stringByEvaluatingJavaScriptFromString: @"isCurrentlyCalling();"];
    
    //Is this a special call from HTML back to ARIS?
    NSString* scheme = [[req URL] scheme];
    if (!([scheme isEqualToString:@"aris"] || [scheme isEqualToString:@"ARIS"])) return YES;
    
    //What was it requesting?
    NSString* mainCommand = [[req URL] host];
    NSArray *components = [[req URL]pathComponents];
    
    if ([mainCommand isEqualToString:@"closeMe"]) {
        NSLog(@"WebPageVC: aris://closeMe/ called");
        [self dismissModalViewControllerAnimated:NO];
        [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
        return NO; 
    }  
    
    if ([mainCommand isEqualToString:@"refreshStuff"]) {
        NSLog(@"WebPageVC: aris://refreshStuff/ called");
        [self refreshConvos];
        [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
        return NO; 
    }  
    
    if ([mainCommand isEqualToString:@"vibrate"]) {
        NSLog(@"WebPageVC: aris://vibrate/ called");
        [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] vibrate];
        [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
        return NO; 
    } 
    
    if ([mainCommand isEqualToString:@"player"]) {
        NSLog(@"WebPageVC: aris://player/ called");
        
        if ([components count] > 1 && 
            [[components objectAtIndex:1] isEqualToString:@"name"]) 
        {
            [self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"setPlayerName(\"%@\");",[AppModel sharedAppModel].userName]];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO;
        }
        if ([components count] > 1 && 
            [[components objectAtIndex:1] isEqualToString:@"id"]) 
        {
            [self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"setPlayerId(%@);",[AppModel sharedAppModel].playerId]];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        }
    }
    
    if ([mainCommand isEqualToString:@"inventory"]) {
        NSLog(@"WebPageVC: aris://inventory/ called");
        
        if ([components count] > 2 && 
            [[components objectAtIndex:1] isEqualToString:@"get"]) {
            int itemId = [[components objectAtIndex:2] intValue];
            NSLog(@"WebPageVC: aris://inventory/get/ called from webpage with itemId = %d",itemId);
            int qty = [self getQtyInInventoryOfItem:itemId];
            [self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"didUpdateItemQty(%d,%d);",itemId,qty]];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        }  
        
        if ([components count] > 3 && 
            [[components objectAtIndex:1] isEqualToString:@"set"]) {
            int itemId = [[components objectAtIndex:2] intValue];
            int qty = [[components objectAtIndex:3] intValue];
            NSLog(@"WebPageVC: aris://inventory/set/ called from webpage with itemId = %d and qty = %d",itemId,qty);
            int newQty = [self setQtyInInventoryOfItem:itemId toQty:qty];
            [self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"didUpdateItemQty(%d,%d);",itemId,newQty]];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        } 
        
        if ([components count] > 3 && 
            [[components objectAtIndex:1] isEqualToString:@"give"]) {
            int itemId = [[components objectAtIndex:2] intValue];
            int qty = [[components objectAtIndex:3] intValue];
            NSLog(@"WebPageVC: aris://inventory/give/ called from webpage with itemId = %d and qty = %d",itemId,qty);
            int newQty = [self giveQtyInInventoryToItem:itemId ofQty:qty];
            [self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"didUpdateItemQty(%d,%d);",itemId,newQty]];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        } 
        
        if ([components count] > 3 && 
            [[components objectAtIndex:1] isEqualToString:@"take"]) {
            int itemId = [[components objectAtIndex:2] intValue];
            int qty = [[components objectAtIndex:3] intValue];
            NSLog(@"WebPageVC: aris://inventory/take/ called from webpage with itemId = %d and qty = %d",itemId,qty);
            int newQty = [self takeQtyInInventoryFromItem:itemId ofQty:qty];
            [self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"didUpdateItemQty(%d,%d);",itemId,newQty]];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        } 
        
    } 
    
    if ([mainCommand isEqualToString:@"media"]) {
        NSLog(@"WebPageVC: aris://media called");
        
        if ([components count] > 2 && 
            [[components objectAtIndex:1] isEqualToString:@"prepare"]) {
            int mediaId = [[components objectAtIndex:2] intValue];
            NSLog(@"WebPageVC: aris://media/prepare/ called from webpage with mediaId = %d",mediaId );
            [self loadAudioFromMediaId:mediaId];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        }  
        
        if ([components count] > 2 && 
            [[components objectAtIndex:1] isEqualToString:@"play"]) {
            int mediaId = [[components objectAtIndex:2] intValue];
            NSLog(@"WebPageVC: aris://media/play/ called from webpage with mediaId = %d",mediaId );
            [self playAudioFromMediaId:mediaId];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        }  
        
        if ([components count] > 2 && 
            [[components objectAtIndex:1] isEqualToString:@"playAndVibrate"]) {
            int mediaId = [[components objectAtIndex:2] intValue];
            NSLog(@"WebPageVC: aris://media/playAndVibrate/ called from webpage with mediaId = %d",mediaId );
            [self playAudioFromMediaId:mediaId];
            [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] vibrate];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        }  
        
        if ([components count] > 2 && 
            [[components objectAtIndex:1] isEqualToString:@"stop"]) {
            int mediaId = [[components objectAtIndex:2] intValue];
            NSLog(@"WebPageVC: aris://media/stop/ called from webpage with mediaId = %d",mediaId );
            [self stopAudioFromMediaId:mediaId];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        }  
        
        if ([components count] > 3 && 
            [[components objectAtIndex:1] isEqualToString:@"setVolume"]) {
            int mediaId = [[components objectAtIndex:2] intValue];
            int volume = [[components objectAtIndex:3] floatValue];
            NSLog(@"WebPageVC: aris://media/setVolume/ called from webpage with mediaId = %d and volume =%d",mediaId,volume );
            [self setMediaId:mediaId volumeTo:volume];
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO; 
        }
    }
    
    if ([mainCommand isEqualToString:@"bump"]) {
        NSLog(@"WebPageVC: aris://bump/ called");
        if ([components count] > 1) 
        {
            self.bumpSendString = [components objectAtIndex:1];
            [self configureBump];
            [BumpClient sharedClient].bumpable = YES;
            [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
            return NO;
        }
    }  
    
    //Shouldn't get here. 
    NSLog(@"WebPageVC: WARNING. An aris:// url was called with no handler");
    return YES;
}


- (void)refreshConvos {
    [[AppServices sharedAppServices] fetchAllPlayerLists];
    if([self.delegate isKindOfClass:[DialogViewController class]]){
        DialogViewController *temp = (DialogViewController *)self.delegate;
        [[AppServices sharedAppServices] fetchNpcConversations:temp.currentNpc.npcId afterViewingNode:temp.currentNode.nodeId];
        [temp showWaitingIndicatorForPlayerOptions];
    }
}

- (void) loadAudioFromMediaId:(int)mediaId{
    NSLog(@"WebPageVC: loadAudioFromMediaId");
    Media* media = [[AppModel sharedAppModel] mediaForMediaId: mediaId];
    NSURL* url = [NSURL URLWithString:media.url];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    [audioPlayers setObject:player forKey:[NSNumber numberWithInt:mediaId]];
}


- (void) playAudioFromMediaId:(int)mediaId{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithInt:mediaId]];
    CMTime zero = CMTimeMakeWithSeconds(0, 600);
    [player seekToTime: zero];
    if (!player) {
        [self loadAudioFromMediaId:mediaId];
        player = [audioPlayers objectForKey:[NSNumber numberWithInt:mediaId]];
    }
    [player play];
}

- (void) stopAudioFromMediaId:(int)mediaId{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithInt:mediaId]];
    [player pause];
}

- (void) setMediaId:(int)mediaId volumeTo:(float)volume{    
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
    Item *i = [[AppModel sharedAppModel].inventory objectForKey:[NSString stringWithFormat:@"%d",itemId]];
    if(i)
        return i.qty;
    i = [[AppModel sharedAppModel].attributes objectForKey:[NSString stringWithFormat:@"%d",itemId]];
    if(i)
        return i.qty;
    return 0;
}

- (int) setQtyInInventoryOfItem:(int)itemId toQty:(int)qty
{
    //If in inventory
    Item *i = [[AppModel sharedAppModel].inventory objectForKey:[NSString stringWithFormat:@"%d",itemId]];
    if(i)
    {
        i.qty = qty;
        [[AppServices sharedAppServices] updateServerInventoryItem:itemId qty:qty];
        return qty;
    }
    //If in attributes
    i = [[AppModel sharedAppModel].attributes objectForKey:[NSString stringWithFormat:@"%d",itemId]];
    if(i)
    {
        i.qty = qty;
        [[AppServices sharedAppServices] updateServerInventoryItem:itemId qty:qty];
        return qty;
    }
    
    //If not yet in inventory/attributes
    i = [[AppModel sharedAppModel] itemForItemId:itemId];
    if(i)
    {
        i.qty = qty;
        if(!i.isAttribute)
            [[AppModel sharedAppModel].inventory setObject:i forKey:[NSString stringWithFormat:@"%d",itemId]];
        else
            [[AppModel sharedAppModel].attributes setObject:i forKey:[NSString stringWithFormat:@"%d",itemId]];
        [[AppServices sharedAppServices] updateServerAddInventoryItem:itemId addQty:qty];
        return qty;
    }
    return 0;
}

- (int) giveQtyInInventoryToItem:(int)itemId ofQty:(int)qty
{
    //If in inventory
    Item *i = [[AppModel sharedAppModel].inventory objectForKey:[NSString stringWithFormat:@"%d",itemId]];
    if(i)
    {
        i.qty += qty;
        [[AppServices sharedAppServices] updateServerAddInventoryItem:itemId addQty:qty];
        return i.qty;
    }
    //If in attributes
    i = [[AppModel sharedAppModel].attributes objectForKey:[NSString stringWithFormat:@"%d",itemId]];
    if(i)
    {
        i.qty += qty;
        [[AppServices sharedAppServices] updateServerAddInventoryItem:itemId addQty:qty];
        return i.qty;
    }
    
    //If not yet in inventory/attributes
    i = [[AppModel sharedAppModel] itemForItemId:itemId];
    if(i)
    {
        i.qty = qty;
        if(!i.isAttribute)
            [[AppModel sharedAppModel].inventory setObject:i forKey:[NSString stringWithFormat:@"%d",itemId]];
        else
            [[AppModel sharedAppModel].attributes setObject:i forKey:[NSString stringWithFormat:@"%d",itemId]];
        [[AppServices sharedAppServices] updateServerAddInventoryItem:itemId addQty:qty];
        return qty;
    }
    return 0;
}

- (int) takeQtyInInventoryFromItem:(int)itemId ofQty:(int)qty
{
    //If in inventory
    Item *i = [[AppModel sharedAppModel].inventory objectForKey:[NSString stringWithFormat:@"%d",itemId]];
    if(i)
    {
        i.qty -= qty;
        [[AppServices sharedAppServices] updateServerRemoveInventoryItem:itemId removeQty:qty];
        if(i.qty < 1)
        {
            [[AppModel sharedAppModel].inventory removeObjectForKey:[NSString stringWithFormat:@"%d",itemId]];
            return 0;
        }
        return i.qty;
    }
    //If in attributes
    i = [[AppModel sharedAppModel].attributes objectForKey:[NSString stringWithFormat:@"%d",itemId]];
    if(i)
    {
        i.qty -= qty;
        [[AppServices sharedAppServices] updateServerRemoveInventoryItem:itemId removeQty:qty];
        if(i.qty < 1)
        {
            [[AppModel sharedAppModel].attributes removeObjectForKey:[NSString stringWithFormat:@"%d",itemId]];
            return 0;
        }
        return i.qty;
    }
    return 0;
}

- (void) configureBump {
    if(self.isConnectedToBump) return;
    [BumpClient configureWithAPIKey:@"4ff1c7a0c2a84bb9938dafc3a1ac770c" andUserID:[[UIDevice currentDevice] name]];
    
    [[BumpClient sharedClient] setMatchBlock:^(BumpChannelID channel) { 
        NSLog(@"Matched with user: %@", [[BumpClient sharedClient] userIDForChannel:channel]); 
        [[BumpClient sharedClient] confirmMatch:YES onChannel:channel];
    }];
    
    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
        NSLog(@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]);
        [[BumpClient sharedClient] sendData:[self.bumpSendString dataUsingEncoding:NSUTF8StringEncoding]
                                  toChannel:channel];
    }];
    
    [[BumpClient sharedClient] setDataReceivedBlock:^(BumpChannelID channel, NSData *data) {
        NSString *receipt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Data received:\n%@",receipt);
        [self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat:@"bumpReceived(%@);",receipt]];
            }];
    
    [[BumpClient sharedClient] setConnectionStateChangedBlock:^(BOOL connected) {
        if (connected) {
            NSLog(@"Bump connected...");
            self.isConnectedToBump = YES;
        } else {
            NSLog(@"Bump disconnected...");
            self.isConnectedToBump = NO;
        }
    }];
    
    [[BumpClient sharedClient] setBumpEventBlock:^(bump_event event) {
        switch(event) {
            case BUMP_EVENT_BUMP:
                NSLog(@"Bump detected.");
                break;
            case BUMP_EVENT_NO_MATCH:
                NSLog(@"No match.");
                break;
        }
    }];
}


@end
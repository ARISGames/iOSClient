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
@synthesize webView,webPage,delegate,activityIndicator,blackView, audioPlayers;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
        urlAddress = [self.webPage.url stringByAppendingString: [NSString stringWithFormat: @"?gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, [AppModel sharedAppModel].playerId, webPage.webPageId]];
    else       
        urlAddress = [self.webPage.url stringByAppendingString: [NSString stringWithFormat: @"&gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, [AppModel sharedAppModel].playerId, webPage.webPageId]];
    
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
        [RootViewController sharedRootViewController].modalPresent=NO;
        [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];    
    }
}

#pragma mark -
#pragma mark ARIS/JavaScript Connections

- (BOOL)webView:(UIWebView*)webViewFromMethod shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType { 
    
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
        [appDelegate vibrate];
        [self.webView stringByEvaluatingJavaScriptFromString: @"isNotCurrentlyCalling();"];
        return NO; 
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
            [appDelegate vibrate];
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

@end
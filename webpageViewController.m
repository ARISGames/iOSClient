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
@synthesize webView,webPage,delegate,activityIndicator,blackView, mediaClips;
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
    mediaClips = [[NSMutableDictionary alloc] init];
    webView.delegate = self;
    webView.hidden = YES;
    //Create a close button
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"")
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	

    
    NSString *urlAddress = self.webPage.url;
    
    //Create a URL object.
    
    urlAddress = [self.webPage.url stringByAppendingString: [NSString stringWithFormat: @"?playerId=%d&gameId=%d",[AppModel sharedAppModel].playerId,[AppModel sharedAppModel].currentGame.gameId]];
NSURL *url = [NSURL URLWithString:urlAddress];
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Config the webView
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerWebPageViewed:webPage.webPageId];
	
	
    if([self.delegate isKindOfClass:[DialogViewController class]]) [self refreshConvos];
	//[self.view removeFromSuperview];
	if([self.delegate isKindOfClass:[DialogViewController class]] || [self.delegate isKindOfClass:[NodeViewController class]]
       || [self.delegate isKindOfClass:[QuestsViewController class]] || [self.delegate isKindOfClass:[ItemDetailsViewController class]])
        [self.navigationController popToRootViewControllerAnimated:YES];
    else{
        ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent=NO;
    [appDelegate dismissNearbyObjectView:self];    
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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
-(void)viewDidAppear:(BOOL)animated{
    self.webView.hidden = YES;
    self.blackView.hidden = NO;
}
- (void)refreshConvos {
    [[AppServices sharedAppServices] fetchAllPlayerLists];
    if([self.delegate isKindOfClass:[DialogViewController class]]){
        DialogViewController *temp = (DialogViewController *)self.delegate;
        [[AppServices sharedAppServices] fetchNpcConversations:temp.currentNpc.npcId afterViewingNode:temp.currentNode.nodeId];
        [temp showWaitingIndicatorForPlayerOptions];
    }
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType { 

    if ([[[req URL] absoluteString] hasPrefix:@"aris://closeMe"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO; 
    }  
    else if ([[[req URL] absoluteString] hasPrefix:@"aris://refreshStuff"]) {
        [self refreshConvos];
        return NO; 
    }   
    else if ([[[req URL] absoluteString] hasPrefix:@"aris://media/prepare/"]) {
        NSString *number = [[[req URL] absoluteString] substringFromIndex:21];
        int mediaId = [number integerValue];
        [self loadAudioFromMediaId:mediaId];
        return NO; 
    }   
    else if ([[[req URL] absoluteString] hasPrefix:@"aris://media/play/"]) {
        NSString *number = [[[req URL] absoluteString] substringFromIndex:18];
        int mediaId = [number integerValue];;
        [self playAudioFromMediaId:mediaId];
        return NO; 
    } 
    else if ([[[req URL] absoluteString] hasPrefix:@"aris://media/stop/"]) {
        NSString *number = [[[req URL] absoluteString] substringFromIndex:18];
        int mediaId = [number integerValue];
        [self stopAudioFromMediaId:mediaId];
        return NO; 
    } 
    return YES;
}

- (void) loadAudioFromMediaId:(int)mediaId{
    Media*  media = [[AppModel sharedAppModel] mediaForMediaId: mediaId];
 /*   if(media.image != nil){
        NSLog(@"Load AVAudioPlayer");
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];	
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        NSError* err;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData: media.image error:&err];
        [player setDelegate: self];
        [player prepareToPlay];
        [mediaClips setObject:player forKey:[NSNumber numberWithInt:mediaId]];
    } */
        NSLog(@"Load ARISMoviePlayerController");
        ARISMoviePlayerViewController *ARISMoviePlayer = [[ARISMoviePlayerViewController alloc]init];
        ARISMoviePlayer.moviePlayer.view.hidden = YES; 
        ARISMoviePlayer = [[ARISMoviePlayerViewController alloc] init];
        [ARISMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
        ARISMoviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [ARISMoviePlayer.moviePlayer setContentURL: [NSURL URLWithString:media.url]];
        [ARISMoviePlayer.moviePlayer setControlStyle:MPMovieControlStyleNone];
        [ARISMoviePlayer.moviePlayer setFullscreen:NO];
        [ARISMoviePlayer.moviePlayer setShouldAutoplay:NO];
        [ARISMoviePlayer.moviePlayer prepareToPlay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChangeNotification: ) name:MPMoviePlayerLoadStateDidChangeNotification object:ARISMoviePlayer.moviePlayer];
        [mediaClips setObject:ARISMoviePlayer forKey:[NSNumber numberWithInt:mediaId]];
}


- (void) playAudioFromMediaId:(int)mediaId{
    ARISMoviePlayerViewController *player = [mediaClips objectForKey:[NSNumber numberWithInt:mediaId]];
    self.localARISMoviePlayer = player;
    [player.moviePlayer play];
}

- (void) stopAudioFromMediaId:(int)mediaId{
    ARISMoviePlayerViewController *player = [mediaClips objectForKey:[NSNumber numberWithInt:mediaId]];
    [player.moviePlayer stop];
}

#pragma mark MPMoviePlayerController notifications

- (void)MPMoviePlayerLoadStateDidChangeNotification:(NSNotification *)notif
{
    NSLog(@"loadState: %d", self.localARISMoviePlayer.moviePlayer.loadState);
    if (self.localARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStateStalled) {
        [self showWaitingIndicator];
        [self.localARISMoviePlayer.moviePlayer pause];
    } 
    else if (self.localARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStatePlayable) {
        [self dismissWaitingIndicator];
        NSLog(@"Load state changes");
        [self.localARISMoviePlayer.moviePlayer play];
    }
} 


@end

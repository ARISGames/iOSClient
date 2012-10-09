//
//  NodeViewController.m
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "NodeViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "NodeOption.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "webpageViewController.h"
#import "WebPage.h"
#import <AVFoundation/AVFoundation.h>
#import "AsyncMediaPlayerButton.h"
#import "UIImage+Scale.h"

static NSString * const OPTION_CELL = @"option";

NSString *const kPlaqueDescriptionHtmlTemplate =
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: #000000;"
@"		color: #FFFFFF;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"	}"
@"	a {color: #9999FF; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";

@implementation NodeViewController
@synthesize node, isLink, hasMedia, imageLoaded, webLoaded, scrollView, mediaArea, webView, continueButton, webViewSpinner, mediaImageView;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
        
        self.isLink=NO;
        AsyncMediaImageView *mediaImageViewAlloc = [[AsyncMediaImageView alloc]init];
        self.mediaImageView = mediaImageViewAlloc;
        self.mediaImageView.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.title = self.node.name;
    [RootViewController sharedRootViewController].modalPresent = YES;
    
    //Setup the Image View/Video Preview Image (if needed)
    Media *media = [[AppModel sharedAppModel] mediaForMediaId: self.node.mediaId];
    if(([media.type isEqualToString: kMediaTypeVideo] || [media.type isEqualToString: kMediaTypeAudio] || [media.type isEqualToString: kMediaTypeImage]) && media.url) hasMedia = YES;
    else hasMedia = NO;
    
    mediaArea = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,10)];
    if ([media.type isEqualToString: kMediaTypeImage] && media.url)
    {
        if(!mediaImageView.loaded)
            [mediaImageView loadImageFromMedia:media];
        mediaImageView.frame = CGRectMake(0, 0, 320, 320);
        mediaArea.frame = CGRectMake(0, 0, 320, 320);
        [mediaArea addSubview:mediaImageView];        
    }
    else if(([media.type isEqualToString: kMediaTypeVideo] || [media.type isEqualToString:kMediaTypeAudio]) && media.url)
    {
        AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presentingController:self preloadNow:NO];
        mediaArea.frame = CGRectMake(0, 0, 300, 240);
        [mediaArea addSubview:mediaButton];
        mediaArea.frame = CGRectMake(0, 0, 300, 240);
    }
    
    //Setup the Description Webview
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, mediaArea.frame.size.height + 20, 300, 10)];
    webView.delegate = self;
    webView.backgroundColor =[UIColor clearColor];
    webView.scrollView.bounces = NO;
    webView.scrollView.scrollEnabled = NO;
    NSString *htmlDescription = [NSString stringWithFormat:kPlaqueDescriptionHtmlTemplate, self.node.text];
    webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob
	[webView loadHTMLString:htmlDescription baseURL:nil];
    
    UIActivityIndicatorView *webViewSpinnerAlloc = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.webViewSpinner = webViewSpinnerAlloc;
    self.webViewSpinner.center = webView.center;
    [self.webViewSpinner startAnimating];
    self.webViewSpinner.backgroundColor = [UIColor clearColor];
    [webView addSubview:self.webViewSpinner];
    
    //Create continue button cell
    continueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [continueButton setTitle:NSLocalizedString(@"TapToContinueKey", @"") forState:UIControlStateNormal];
    [continueButton setFrame:CGRectMake(0, webView.frame.origin.y + webView.frame.size.height + 20, 320, 30)];
    [continueButton addTarget:self action:@selector(continueButtonTouchAction) forControlEvents:UIControlEventTouchUpInside];
    
    //Setup the scrollview
    //scrollView.frame = self.parentViewController.view.frame;
    scrollView.contentSize = CGSizeMake(320,continueButton.frame.origin.y + continueButton.frame.size.height + 50);
    if(hasMedia) [scrollView addSubview:mediaArea];
    [scrollView addSubview:webView];
    [scrollView addSubview:continueButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView*)webViewFromMethod shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType {
    
    if(self.isLink) return YES; // <- I actually don't know what function 'isLink' has... kept for harmless legacy reasons. - Phil 10/2012
    
    NSString *url = [req URL].absoluteString;
    if([url isEqualToString:@"about:blank"]) return YES;
    //Check to prepend url query with '?' or '&'
    if([url rangeOfString:@"?"].location == NSNotFound)
        url = [url stringByAppendingString: [NSString stringWithFormat: @"?gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, node.nodeId, [AppModel sharedAppModel].playerId]];
    else
        url = [url stringByAppendingString: [NSString stringWithFormat: @"&gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, node.nodeId, [AppModel sharedAppModel].playerId]];
    
    webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle: [NSBundle mainBundle]];
    WebPage *temp = [[WebPage alloc]init];
    temp.url = url;
    webPageViewController.webPage = temp;
    webPageViewController.delegate = self;
    [self.navigationController pushViewController:webPageViewController animated:NO];
    
    return NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)theWebView{
    webView.alpha = 1.00;
    
    //Calculate the height of the web content
    float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    [webView setFrame:CGRectMake(webView.frame.origin.x,
                                 webView.frame.origin.y,
                                 webView.frame.size.width,
                                 newHeight+5)];
    [continueButton setFrame:CGRectMake(continueButton.frame.origin.x ,
                                        webView.frame.origin.y + webView.frame.size.height + 20,
                                        continueButton.frame.size.width,
                                        continueButton.frame.size.height)];
    scrollView.contentSize = CGSizeMake(320,continueButton.frame.origin.y + continueButton.frame.size.height + 50);
    
    //Find the webCell spinner and remove it
    [webViewSpinner removeFromSuperview]; 
}

#pragma mark AsyncImageView Delegate Methods
-(void)imageFinishedLoading{
    NSLog(@"NodeVC: imageFinishedLoading with size: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
    /*
     if(self.mediaImageView.image.size.width > 0){
     [self.mediaImageView setContentScaleFactor:(float)(320/self.mediaImageView.image.size.width)];
     self.mediaImageView.frame = CGRectMake(0, 0, 300, self.mediaImageView.contentScaleFactor*self.mediaImageView.image.size.height);
     NSLog(@"NodeVC: Image resized to: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
     [(UITableViewCell *)[self.cellArray objectAtIndex:0] setFrame:mediaImageView.frame];
     }
     
     [tableView reloadData];
     */
}


#pragma mark Button Handlers
- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId fromLocation:node.locationId];
	
	//[self.view removeFromSuperview];
    [RootViewController sharedRootViewController].modalPresent=NO;
    [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];    
}

- (IBAction)continueButtonTouchAction
{
    NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId fromLocation:node.locationId];
	
    //Remove thyself from the screen // <- lol
    [RootViewController sharedRootViewController].modalPresent = NO;
    [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];
    
    //Check if this was the game complete Node and if so, display the "Start Over" tab
    if((node.nodeId == [AppModel sharedAppModel].currentGame.completeNodeId) && ([AppModel sharedAppModel].currentGame.completeNodeId != 0))
    {
        NSString *tab;
        for(int i = 0;i < [[RootViewController sharedRootViewController].tabBarController.customizableViewControllers count];i++){
            tab = [[[RootViewController sharedRootViewController].tabBarController.customizableViewControllers objectAtIndex:i] title];
            tab = [tab lowercaseString];
            if([tab isEqualToString:@"start over"]) [RootViewController sharedRootViewController].tabBarController.selectedIndex = i;
        }
    }
    
}

/*-(IBAction)playMovie:(id)sender {
 [mMoviePlayer.moviePlayer play];
 [self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
 }
 */

#pragma mark MPMoviePlayerController Notification Handlers

/*
 - (void)movieLoadStateChanged:(NSNotification*) aNotification{
 MPMovieLoadState state = [(MPMoviePlayerController *) aNotification.object loadState];
 
 if( state & MPMovieLoadStateUnknown ) {
 NSLog(@"NodeViewController: Unknown Load State");
 }
 if( state & MPMovieLoadStatePlayable ) {
 NSLog(@"NodeViewController: Playable Load State");
 
 //Create a thumbnail for the button
 if (![mediaPlaybackButton backgroundImageForState:UIControlStateNormal]){
 UIImage *videoThumb = [mMoviePlayer.moviePlayer thumbnailImageAtTime:(NSTimeInterval)1.0 timeOption:MPMovieTimeOptionExact];
 UIImage *videoThumbSized = [videoThumb scaleToSize:CGSizeMake(300, 240)];
 [mediaPlaybackButton setBackgroundImage:videoThumbSized forState:UIControlStateNormal];
 }
 
 }
 if( state & MPMovieLoadStatePlaythroughOK ) {
 NSLog(@"NodeViewController: Playthrough OK Load State");
 
 }
 if( state & MPMovieLoadStateStalled ) {
 NSLog(@"NodeViewController: Stalled Load State");
 }
 
 }*/


- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}


#pragma mark PickerViewDelegate selectors


#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	NSLog(@"NodeViewController: Dealloc");
    
    
    //remove listeners
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
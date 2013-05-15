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
#import "ARISAppDelegate.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "WebPageViewController.h"
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

@interface NodeViewController()
{
    BOOL imageLoaded;
    BOOL webLoaded;
    
    UIScrollView *scrollView;
    UIView *mediaArea;
    UIWebView *webView;
    UIButton *continueButton;
    
    MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	UIButton *mediaPlaybackButton;
    
    UIActivityIndicatorView *webViewSpinner;
}
@property(readwrite) Node *node;

@property(readwrite, assign) BOOL imageLoaded;
@property(readwrite, assign) BOOL webLoaded;

@property(nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong) UIView *mediaArea;
@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) UIButton *continueButton;

@property(nonatomic, strong) UIActivityIndicatorView *webViewSpinner;

@end

@implementation NodeViewController
@synthesize node, imageLoaded, webLoaded, scrollView, mediaArea, webView, continueButton, webViewSpinner;

- (id) initWithNode:(Node *)n delegate:(NSObject<GameObjectViewControllerDelegate> *)d
{
    if((self = [super initWithNibName:@"NodeViewController" bundle:nil]))
    {
        delegate = d;

        self.node = n;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    
    return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
    
    self.title = self.node.name;
    
    Media *media = [[AppModel sharedAppModel] mediaForMediaId:self.node.mediaId];
    
    mediaArea = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,10)];
    if([media.type isEqualToString:@"PHOTO"] && media.url)
    {
        AsyncMediaImageView *mediaImageView = [[AsyncMediaImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320) andMedia:media];
        mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
        mediaArea.frame = CGRectMake(0, 0, 320, 320);
        [mediaArea addSubview:mediaImageView];
    }
    else if(([media.type isEqualToString:@"VIDEO"] || [media.type isEqualToString:@"AUDIO"]) && media.url)
    {
        AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presentingController:[RootViewController sharedRootViewController] preloadNow:NO];
        mediaArea.frame = CGRectMake(0, 0, 300, 240);
        [mediaArea addSubview:mediaButton];
    }
    
    //Setup the Description Webview
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, mediaArea.frame.size.height + 20, 300, 10)];
    webView.delegate = self;
    webView.backgroundColor =[UIColor clearColor];
    if([webView respondsToSelector:@selector(scrollView)])
    {
        webView.scrollView.bounces = NO;
        webView.scrollView.scrollEnabled = NO;
    }
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
    [continueButton setFrame:CGRectMake(0, webView.frame.origin.y + webView.frame.size.height + 20, 320, 45)];
    [continueButton addTarget:self action:@selector(continueButtonTouchAction) forControlEvents:UIControlEventTouchUpInside];
    
    //Setup the scrollview
    //scrollView.frame = self.parentViewController.view.frame;
    scrollView.contentSize = CGSizeMake(320,continueButton.frame.origin.y + continueButton.frame.size.height + 50);
    if(media.type && media.url) [scrollView addSubview:mediaArea];
    [scrollView addSubview:webView];
    [scrollView addSubview:continueButton];
}

#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView*)webViewFromMethod shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [req URL].absoluteString;
    if([url isEqualToString:@"about:blank"]) return YES;
    //Check to prepend url query with '?' or '&'
    if([url rangeOfString:@"?"].location == NSNotFound)
        url = [url stringByAppendingString: [NSString stringWithFormat: @"?gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, node.nodeId, [AppModel sharedAppModel].player.playerId]];
    else
        url = [url stringByAppendingString: [NSString stringWithFormat: @"&gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, node.nodeId, [AppModel sharedAppModel].player.playerId]];
    
    //PHIL TODO- convert to ARIS WebView (but first, create ARIS WebView)
    
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    webView.alpha = 1.00;
    
    //Calculate the height of the web content
    float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue] + 3;
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

#pragma mark Button Handlers
- (IBAction) backButtonTouchAction:(id)sender
{
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (IBAction)continueButtonTouchAction
{
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
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

- (void)dealloc
{
    webView.delegate = nil;
    [webView stopLoading];
    //remove listeners
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
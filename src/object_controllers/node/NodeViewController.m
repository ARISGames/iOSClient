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
#import "Node.h"
#import "ARISMoviePlayerViewController.h"
#import "AsyncMediaImageView.h"
#import "UIColor+ARISColors.h"

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

@interface NodeViewController() <UIScrollViewDelegate, UIWebViewDelegate, AsyncMediaImageViewDelegate>
{
    BOOL imageLoaded;
    BOOL webLoaded;
    
    UIScrollView *scrollView;
    UIView *mediaSection;
    UIWebView *webView;
    UIButton *continueButton;
    
    UIActivityIndicatorView *webViewSpinner;
}

@property (readwrite, strong) Node *node;
@property (readwrite, assign) BOOL imageLoaded;
@property (readwrite, assign) BOOL webLoaded;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *mediaSection;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIActivityIndicatorView *webViewSpinner;

@end

@implementation NodeViewController

@synthesize node;
@synthesize imageLoaded;
@synthesize webLoaded;
@synthesize scrollView;
@synthesize mediaSection;
@synthesize webView;
@synthesize continueButton;
@synthesize webViewSpinner;

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
    
    Media *media = [[AppModel sharedAppModel] mediaForMediaId:self.node.mediaId ofType:nil];
    
    self.mediaSection = [[UIView alloc] init];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)]; //Needs width of 320, otherwise "height" is calculated wrong because only 1 character can fit per line
    self.continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //self.continueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    if([media.type isEqualToString:@"PHOTO"] && media.url)
    {
        self.mediaSection.frame = CGRectMake(0,0,320,20);
        AsyncMediaImageView *mediaImageView = [[AsyncMediaImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320) andMedia:media andDelegate:self];
        [self.mediaSection addSubview:mediaImageView];
    }
    else if(([media.type isEqualToString:@"VIDEO"] || [media.type isEqualToString:@"AUDIO"]) && media.url)
    {
        self.mediaSection.frame = CGRectMake(0,0,320,240);
        self.webView.frame = CGRectMake(0, self.mediaSection.frame.size.height+10, 320, self.webView.frame.size.height);
        AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presenter:self preloadNow:NO];
        [self.mediaSection addSubview:mediaButton];
    }
    
    //Setup the Description Webview
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    if([self.webView respondsToSelector:@selector(scrollView)])
    {
        self.webView.scrollView.bounces = NO;
        self.webView.scrollView.scrollEnabled = NO;
    }
    NSString *htmlDescription = [NSString stringWithFormat:kPlaqueDescriptionHtmlTemplate, self.node.text];
    self.webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob
	[self.webView loadHTMLString:htmlDescription baseURL:nil];
    
    self.webViewSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.webViewSpinner.center = self.webView.center;
    [self.webViewSpinner startAnimating];
    self.webViewSpinner.backgroundColor = [UIColor clearColor];
    [self.webView addSubview:self.webViewSpinner];
    
    //Create continue button cell
    self.continueButton.backgroundColor = [UIColor ARISColorLightGrey];
    self.continueButton.layer.cornerRadius = 10.0f;
    [self.continueButton setTitleColor:[UIColor ARISColorBlack] forState:UIControlStateNormal];
    [self.continueButton setTitle:NSLocalizedString(@"TapToContinueKey", @"") forState:UIControlStateNormal];
    [self.continueButton setFrame:CGRectMake(0, 20, 320, 45)];
    [self.continueButton addTarget:self action:@selector(continueButtonTouchAction) forControlEvents:UIControlEventTouchUpInside];
    
    //Setup the scrollview
    //scrollView.frame = self.parentViewController.view.frame;
    scrollView.contentSize = CGSizeMake(320, self.continueButton.frame.origin.y+self.continueButton.frame.size.height+50);
    if(self.mediaSection) [scrollView addSubview:self.mediaSection];
    [scrollView addSubview:self.webView];
    [scrollView addSubview:self.continueButton];
}

- (void) imageFinishedLoading:(AsyncMediaImageView *)image
{
    image.frame = CGRectMake(0, 0, 320, 320/image.image.size.width*image.image.size.height);
    self.mediaSection.frame = image.frame;
    self.webView.frame = CGRectMake(0, self.mediaSection.frame.size.height+10, 320, self.webView.frame.size.height);
    self.continueButton.frame = CGRectMake(0, self.webView.frame.origin.y + self.webView.frame.size.height+10, 320, 45);
    self.scrollView.contentSize = CGSizeMake(320,self.continueButton.frame.origin.y + self.continueButton.frame.size.height+50);
}

- (BOOL) webView:(UIWebView*)webViewFromMethod shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [req URL].absoluteString;
    if([url isEqualToString:@"about:blank"]) return YES;
    //Check to prepend url query with '?' or '&'
    if([url rangeOfString:@"?"].location == NSNotFound)
        url = [url stringByAppendingString: [NSString stringWithFormat: @"?gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, node.nodeId, [AppModel sharedAppModel].player.playerId]];
    else
        url = [url stringByAppendingString:[NSString stringWithFormat: @"&gameId=%d&webPageId=%d&playerId=%d",[AppModel sharedAppModel].currentGame.gameId, node.nodeId, [AppModel sharedAppModel].player.playerId]];
    
    //PHIL TODO- convert to ARIS WebView (but first, create ARIS WebView)
    
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)theWebView
{
    self.webView.alpha = 1.00;
    
    //Calculate the height of the web content
    float newHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue] + 3;
    [self.webView setFrame:CGRectMake(self.webView.frame.origin.x,
                                      self.webView.frame.origin.y,
                                      self.webView.frame.size.width,
                                      newHeight+5)];
    [self.continueButton setFrame:CGRectMake(self.continueButton.frame.origin.x ,
                                             self.webView.frame.origin.y + self.webView.frame.size.height+10,
                                             self.continueButton.frame.size.width,
                                             self.continueButton.frame.size.height)];
    scrollView.contentSize = CGSizeMake(320,self.continueButton.frame.origin.y + self.continueButton.frame.size.height+50);
    
    [self.webViewSpinner removeFromSuperview];
}

- (void) continueButtonTouchAction
{
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}

- (void)dealloc
{
    self.webView.delegate = nil;
    [self.webView stopLoading];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
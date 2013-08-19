//
//  NodeViewController.m
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "NodeViewController.h"
#import "StateControllerProtocol.h"
#import "AppModel.h"
#import "AppServices.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "ARISMediaView.h"
#import "WebPageViewController.h"
#import "WebPage.h"
#import <AVFoundation/AVFoundation.h>
#import "AsyncMediaPlayerButton.h"
#import "UIImage+Scale.h"
#import "Node.h"
#import "ARISMoviePlayerViewController.h"
#import "UIColor+ARISColors.h"

static NSString * const OPTION_CELL = @"option";

NSString *const kPlaqueDescriptionHtmlTemplate =
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"  html { margin:0px; padding:0px; }"
@"	body {"
@"		background-color: #000000;"
@"		color: #FFFFFF;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"      padding:10px;"
@"	}"
@"	a {color: #9999FF; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";

@interface NodeViewController() <UIScrollViewDelegate, UIWebViewDelegate, ARISMediaViewDelegate>
{
    UIScrollView *scrollView;
    UIView *mediaSection;
    UIWebView *webView;
    UIButton *continueButton;
    
    UIActivityIndicatorView *webViewSpinner;
}

@property (readwrite, strong) Node *node;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *mediaSection;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIActivityIndicatorView *webViewSpinner;

@end

@implementation NodeViewController

@synthesize node;
@synthesize scrollView;
@synthesize mediaSection;
@synthesize webView;
@synthesize continueButton;
@synthesize webViewSpinner;

- (id) initWithNode:(Node *)n delegate:(NSObject<GameObjectViewControllerDelegate, StateControllerProtocol> *)d
{
    if((self = [super init]))
    {
        delegate = d;
    
        self.node = n;
        self.title = self.node.name;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    
    return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-44)];
    self.scrollView.contentSize = self.scrollView.bounds.size;
    
    if(![self.node.text isEqualToString:@""])
    {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)]; //Needs correct width, otherwise "height" is calculated wrong because only 1 character can fit per line
        self.webView.delegate = self;
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.scrollView.bounces = NO;
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob
        [self.webView loadHTMLString:[NSString stringWithFormat:kPlaqueDescriptionHtmlTemplate, self.node.text] baseURL:nil];
        
        self.webViewSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.webViewSpinner.center = self.webView.center;
        [self.webViewSpinner startAnimating];
        self.webViewSpinner.backgroundColor = [UIColor clearColor];
        [self.webView addSubview:self.webViewSpinner];
        [self.scrollView addSubview:self.webView];
    }
    
    Media *media = [[AppModel sharedAppModel] mediaForMediaId:self.node.mediaId ofType:nil];
    self.mediaSection = [[UIView alloc] init];
    if([media.type isEqualToString:@"PHOTO"] && media.url)
    {
        self.mediaSection.frame = CGRectMake(0,0,self.view.bounds.size.width,20);
        [self.mediaSection addSubview:[[ARISMediaView alloc] initWithFrame:self.mediaSection.frame media:media mode:ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight delegate:self]];
        [self.scrollView addSubview:self.mediaSection];
    }
    else if(([media.type isEqualToString:@"VIDEO"] || [media.type isEqualToString:@"AUDIO"]) && media.url)
    {
        self.mediaSection.frame = CGRectMake(0,0,self.view.bounds.size.width,240);
        if(self.webView)
            self.webView.frame = CGRectMake(0, self.mediaSection.frame.size.height, self.view.bounds.size.width, self.webView.frame.size.height);
        AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presenter:self preloadNow:NO];
        [self.mediaSection addSubview:mediaButton];
        [self.scrollView addSubview:self.mediaSection];
    }
    
    self.continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.continueButton.backgroundColor = [UIColor ARISColorOffWhite];
    [self.continueButton setTitleColor:[UIColor ARISColorBlack] forState:UIControlStateNormal];
    [self.continueButton setTitle:NSLocalizedString(@"TapToContinueKey", @"") forState:UIControlStateNormal];
    [self.continueButton setFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    self.continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.continueButton addTarget:self action:@selector(continueButtonTouchAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.continueButton];
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    self.mediaSection.frame = amv.frame;
    if(self.webView)
    {
        self.webView.frame = CGRectMake(0, self.mediaSection.frame.size.height, self.view.bounds.size.width, self.webView.frame.size.height);
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,self.webView.frame.origin.y+self.webView.frame.size.height+10);
    }
    else
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,self.mediaSection.frame.size.height);
}

- (BOOL) webView:(UIWebView*)webViewFromMethod shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [req URL].absoluteString;
    if([url isEqualToString:@"about:blank"]) return YES;
    
    [delegate gameObjectViewControllerRequestsDismissal:self];
    WebPage *w = [[WebPage alloc] init];
    w.webPageId = self.node.nodeId;
    w.url = url;
    [(id<StateControllerProtocol>)delegate displayGameObject:w fromSource:self];
    //PHIL TODO- convert to ARIS WebView (but first, create ARIS WebView)

    return NO;
}

- (void) webViewDidFinishLoad:(UIWebView *)theWebView
{
    self.webView.alpha = 1.00;
    
    //Calculate the height of the web content
    float newHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    [self.webView setFrame:CGRectMake(self.webView.frame.origin.x,
                                      self.webView.frame.origin.y,
                                      self.webView.frame.size.width,
                                      newHeight)];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,self.webView.frame.origin.y+self.webView.frame.size.height+10);
    
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
    if(self.webView)
    {
        self.webView.delegate = nil;
        [self.webView stopLoading];
    }
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

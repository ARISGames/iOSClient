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
#import "ARISWebView.h"
#import "WebPageViewController.h"
#import "WebPage.h"
#import "UIImage+Scale.h"
#import "Node.h"
#import "ARISTemplate.h"

static NSString * const OPTION_CELL = @"option";

@interface NodeViewController() <UIScrollViewDelegate, ARISWebViewDelegate, ARISMediaViewDelegate, StateControllerProtocol>
{
    UIScrollView *scrollView;
    UIView *mediaSection;
    ARISWebView *webView;
    UIView *continueButton;
    
    UIActivityIndicatorView *webViewSpinner;
}

@property (readwrite, strong) Node *node;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *mediaSection;
@property (nonatomic, strong) ARISWebView *webView;
@property (nonatomic, strong) UIView *continueButton;
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
    }
    
    return self;
}

- (void) viewWillAppearFirstTime:(BOOL)animated
{
    self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,self.view.bounds.size.height-64-44); 
    self.scrollView.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
    self.scrollView.clipsToBounds = NO;
    
    if(![self.node.text isEqualToString:@""])
    {
        self.webView = [[ARISWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1) delegate:self]; //Needs correct width, otherwise "height" is calculated wrong because only 1 character can fit per line
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.scrollView.bounces = NO;
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob
        [self.webView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], self.node.text] baseURL:nil];
        
        self.webViewSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.webViewSpinner.center = self.webView.center;
        [self.webViewSpinner startAnimating];
        self.webViewSpinner.backgroundColor = [UIColor clearColor];
        [self.webView addSubview:self.webViewSpinner];
        [self.scrollView addSubview:self.webView];
    }
    
    Media *media = [[AppModel sharedAppModel] mediaForMediaId:self.node.mediaId];
    self.mediaSection = [[UIView alloc] init];
    if(media)
    {
        self.mediaSection.frame = CGRectMake(0,0,self.view.bounds.size.width,20);
        [self.mediaSection addSubview:[[ARISMediaView alloc] initWithFrame:self.mediaSection.frame media:media mode:ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight delegate:self]];
        [self.scrollView addSubview:self.mediaSection];
    }
    
    self.continueButton = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    self.continueButton.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
    self.continueButton.userInteractionEnabled = YES;
    self.continueButton.accessibilityLabel = @"Continue";
    UILabel *continueLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width-30,44)];
    continueLbl.textColor = [ARISTemplate ARISColorText];
    continueLbl.textAlignment = NSTextAlignmentRight;
    continueLbl.text = NSLocalizedString(@"ContinueKey", @"");
    continueLbl.font = [ARISTemplate ARISButtonFont];
    [self.continueButton addSubview:continueLbl];
    [self.continueButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueButtonTouchAction)]];
    
    UIImageView *arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    arrow.frame = CGRectMake(self.view.bounds.size.width-25, self.view.bounds.size.height-30, 19, 19);
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 1)];
    line.backgroundColor = [UIColor ARISColorLightGray];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.continueButton];
    [self.view addSubview:arrow];
    [self.view addSubview:line];
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

- (BOOL) webView:(ARISWebView*)wv shouldStartLoadWithRequest:(NSURLRequest*)r navigationType:(UIWebViewNavigationType)nt
{
    [delegate gameObjectViewControllerRequestsDismissal:self];
    WebPage *w = [[WebPage alloc] init];
    w.webPageId = self.node.nodeId;
    w.url = [r.URL absoluteString];
    [(id<StateControllerProtocol>)delegate displayGameObject:w fromSource:self];

    return NO;
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
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

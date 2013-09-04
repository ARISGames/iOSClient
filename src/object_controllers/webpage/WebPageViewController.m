//
//  WebPageViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateControllerProtocol.h"
#import "WebPageViewController.h"
#import "WebPage.h"
#import "AppServices.h"
#import "NpcViewController.h"
#import "ARISWebView.h"

@interface WebPageViewController() <ARISWebViewDelegate,StateControllerProtocol,UIWebViewDelegate>
{
    WebPage *webPage;
    ARISWebView *webView;
    UIActivityIndicatorView *activityIndicator;
    UIButton *continueButton;
    
    BOOL hasAppeared;
    
    id<GameObjectViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) WebPage *webPage;
@property (nonatomic, strong) ARISWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *continueButton;

@end

@implementation WebPageViewController

@synthesize webPage;
@synthesize webView;
@synthesize activityIndicator;

- (id) initWithWebPage:(WebPage *)w delegate:(NSObject<GameObjectViewControllerDelegate, StateControllerProtocol> *)d
{
    if(self = [super init])
    {
        delegate = d;
        self.webPage = w;
        
        hasAppeared = NO;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!hasAppeared) [self viewWillAppearFirstTime];
}

- (void) viewWillAppearFirstTime
{
    hasAppeared = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.activityIndicator];
    
    self.webView = [[ARISWebView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-44) delegate:self];
    self.webView.scalesPageToFit = YES;
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webPage.url]] withAppendation:[NSString stringWithFormat:@"&webPageId=%d",self.webPage.webPageId]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void) webViewDidFinishLoad:(UIWebView *)wv
{
    [self.webView injectHTMLWithARISjs];
    [self.activityIndicator removeFromSuperview];
    [self.activityIndicator stopAnimating];
    self.activityIndicator = nil;
    
    [self.view addSubview:self.webView];
}

- (BOOL) webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return ![self.webView handleARISRequestIfApplicable:request];
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
    [self dismissSelf];
}

- (void) ARISWebViewRequestsHideButton:(ARISWebView *)awv
{
    self.webView.frame = self.view.bounds;
    [self.continueButton removeFromSuperview];
}

- (void) ARISWebViewRequestsRefresh:(ARISWebView *)awv
{
    if([(NSObject *)delegate isKindOfClass:[NpcViewController class]])
    {
        //NpcViewController *npcvc = (NpcViewController *)delegate;
        //[[AppServices sharedAppServices] fetchNpcConversations:npcvc.currentNpc.npcId afterViewingNode:npcvc.currentNode.nodeId];
        //[npcvc showWaitingIndicatorForPlayerOptions];
    }
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [self dismissSelf];
    [delegate displayScannerWithPrompt:p];
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    [self dismissSelf];
    return [delegate displayGameObject:g fromSource:s];
}

- (void) displayTab:(NSString *)t
{
    [self dismissSelf];
    [delegate displayTab:t];
}

- (void) backButtonTouched
{
    [self dismissSelf];
}

- (void) dismissSelf
{
    [self.webView clear];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[AppServices sharedAppServices] updateServerWebPageViewed:webPage.webPageId fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void) dealloc
{
    [self.webView clear];
    webView.delegate = nil;
}


@end
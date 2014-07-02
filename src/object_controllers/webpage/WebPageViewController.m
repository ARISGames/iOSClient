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
#import "DialogViewController.h"
#import "ARISWebView.h"

@interface WebPageViewController() <ARISWebViewDelegate,StateControllerProtocol>
{
    WebPage *webPage;
    ARISWebView *webView;
    UIActivityIndicatorView *activityIndicator;
    
    BOOL hasAppeared;
    
    id<InstantiableViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) WebPage *webPage;
@property (nonatomic, strong) ARISWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation WebPageViewController

@synthesize webPage;
@synthesize webView;
@synthesize activityIndicator;

- (id) initWithWebPage:(WebPage *)w delegate:(NSObject<InstantiableViewControllerDelegate, StateControllerProtocol> *)d
{
    if(self = [super init])
    {
        delegate = d;
        self.webPage = w;
        
        hasAppeared = NO;
        
        
        //WARNING!!!! FOR DEBUGGING PURPOSES ONLY!!! REMOVE FROM PRODUCTION!!!!
        
        // remove all cached responses
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        // set an empty cache
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        
        //WARNING!!!! FOR DEBUGGING PURPOSES ONLY!!! REMOVE FROM PRODUCTION!!!!

        
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
    
    self.webView = [[ARISWebView alloc] initWithFrame:CGRectMake(0,64,self.view.bounds.size.width,self.view.bounds.size.height-64) delegate:self];
    //self.webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.webView.scrollView.bounces = NO;
    self.webView.scalesPageToFit = YES;
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webPage.url]] withAppendation:[NSString stringWithFormat:@"&web_page_id=%d",self.webPage.web_page_id]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    [self.activityIndicator removeFromSuperview];
    [self.activityIndicator stopAnimating];
    self.activityIndicator = nil;
    
    [self.view addSubview:self.webView];
}

- (BOOL) ARISWebView:(ARISWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)r navigationType:(UIWebViewNavigationType)nt
{
    return YES;
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
    [self dismissSelf];
}

- (void) ARISWebViewRequestsRefresh:(ARISWebView *)awv
{
    if([(NSObject *)delegate isKindOfClass:[DialogViewController class]])
    {
        //DialogViewController *npcvc = (DialogViewController *)delegate;
        //[_SERVICES_ fetchDialogConversations:npcvc.currentDialog.npc_id afterViewingPlaque:npcvc.currentPlaque.plaque_id];
        //[npcvc showWaitingIndicatorForPlayerOptions];
    }
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [self dismissSelf];
    [delegate displayScannerWithPrompt:p];
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
    //[_SERVICES_ updateServerWebPageViewed:webPage.web_page_id fromLocation:0];
    [delegate instantiableViewControllerRequestsDismissal:self];
}

- (void) dealloc
{
    [self.webView clear];
    webView.delegate = nil;
}

@end

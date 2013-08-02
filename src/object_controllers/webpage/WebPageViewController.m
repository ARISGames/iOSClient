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
    ARISWebView *aWebView;
    WebPage *webPage;
    IBOutlet UIView  *blackView;
    UIActivityIndicatorView *activityIndicator;
    BOOL loaded;
    
    id<GameObjectViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) ARISWebView *aWebView;
@property (nonatomic, strong) WebPage *webPage;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIView *blackView;
@property (nonatomic, assign) BOOL loaded;

@end

@implementation WebPageViewController

@synthesize aWebView;
@synthesize webPage;
@synthesize activityIndicator;
@synthesize blackView;
@synthesize loaded;

- (id) initWithWebPage:(WebPage *)w delegate:(NSObject<GameObjectViewControllerDelegate, StateControllerProtocol> *)d
{
    self = [super initWithNibName:@"WebPageViewController" bundle:nil];
    if(self)
    {
        delegate = d;
        self.webPage = w;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.loaded = NO;
    
    self.aWebView = [[ARISWebView alloc] initWithFrame:self.blackView.frame delegate:self];
    self.aWebView.hidden = YES;
    self.aWebView.allowsInlineMediaPlayback = YES;
    self.aWebView.mediaPlaybackRequiresUserAction = NO;
    [self.view addSubview:self.aWebView];
    
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouchAction:)];
    
    [self.aWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webPage.url]] withAppendation:[NSString stringWithFormat:@"&webPageId=%d",self.webPage.webPageId]];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.aWebView.frame = self.blackView.frame;
    if(!self.loaded)
    {
        self.aWebView.hidden = YES;
        self.blackView.hidden = NO;
    }
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    if([webView isKindOfClass:[ARISWebView class]])
        [self.aWebView injectHTMLWithARISjs];
    self.loaded = YES;
    self.aWebView.hidden = NO;
    self.blackView.hidden = YES;
    [self.activityIndicator stopAnimating];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([webView isKindOfClass:[ARISWebView class]]) return ![(ARISWebView *)webView handleARISRequestIfApplicable:request];
    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    self.loaded = NO;
    [self.activityIndicator startAnimating];
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
    [self dismissSelf];
}

- (void) ARISWebViewRequestsRefresh:(ARISWebView *)awv
{
    if([(NSObject *)delegate isKindOfClass:[NpcViewController class]])
    {
        NpcViewController *npcvc = (NpcViewController *)delegate;
        [[AppServices sharedAppServices] fetchNpcConversations:npcvc.currentNpc.npcId afterViewingNode:npcvc.currentNode.nodeId];
        [npcvc showWaitingIndicatorForPlayerOptions];
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
    [delegate displayGameObject:g fromSource:s];
}

- (void) displayTab:(NSString *)t
{
    [self dismissSelf];
    [delegate displayTab:t];
}

- (IBAction) backButtonTouchAction:(id)sender
{
    [self dismissSelf];
}

- (void) dismissSelf
{
    [self.aWebView clear];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[AppServices sharedAppServices] updateServerWebPageViewed:webPage.webPageId fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void) dealloc
{
    [self.aWebView clear];
    aWebView.delegate = nil;
}


@end
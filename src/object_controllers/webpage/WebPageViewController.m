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
#import "AppModel.h"
#import "ARISWebView.h"

@interface WebPageViewController() <ARISWebViewDelegate,StateControllerProtocol>
{
    WebPage *webPage;
    Instance *instance;
    Tab *tab;

    ARISWebView *webView;
    UIActivityIndicatorView *activityIndicator;

    BOOL hasAppeared;

    id<WebPageViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation WebPageViewController

- (id) initWithInstance:(Instance *)i delegate:(id<WebPageViewControllerDelegate>)d;
{
    if(self = [super init])
    {
        instance = i;
        webPage = [_MODEL_WEB_PAGES_ webPageForId:i.object_id];

        delegate = d;
        hasAppeared = NO;
    }
    return self;
}
- (Instance *) instance { return instance; }

- (id) initWithTab:(Tab *)t delegate:(id<WebPageViewControllerDelegate>)d;
{
    if(self = [super init])
    {
        tab = t;
        instance = [_MODEL_INSTANCES_ instanceForId:0]; //get null inst
        instance.object_type = tab.type;
        instance.object_id = tab.content_id;
        webPage = [_MODEL_WEB_PAGES_ webPageForId:instance.object_id];

        delegate = d;
        hasAppeared = NO;
    }
    return self;
}
- (Tab *) tab { return tab; }

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

    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];

    webView = [[ARISWebView alloc] initWithFrame:CGRectMake(0,64,self.view.bounds.size.width,self.view.bounds.size.height-64) delegate:self];
    //webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    webView.scrollView.bounces = NO;
    webView.scalesPageToFit = YES;
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webPage.url]] withAppendation:[NSString stringWithFormat:@"&web_page_id=%d",webPage.web_page_id]];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    /*
    UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
    [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside];
    threeLineNavButton.accessibilityLabel = @"In-Game Menu";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
    */
}

- (NSString *) getTabTitle
{
    return webPage.name;
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    [activityIndicator removeFromSuperview];
    [activityIndicator stopAnimating];
    activityIndicator = nil;

    [self.view addSubview:webView];
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

- (void) backButtonTouched
{
    [self dismissSelf];
}

- (void) dismissSelf
{
    [webView clear];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[_SERVICES_ updateServerWebPageViewed:webPage.web_page_id fromLocation:0];
    [delegate instantiableViewControllerRequestsDismissal:self];
}

- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"WEB_PAGE"; }
- (NSString *) tabTitle { return @"Web Page"; }
- (UIImage *) tabIcon { return [UIImage imageNamed:@"qr_icon"]; }

//implement statecontrol stuff for webpage, but just delegate any requests
- (BOOL) displayTrigger:(Trigger *)t   { return [delegate displayTrigger:t]; }
- (BOOL) displayTriggerId:(int)t       { return [delegate displayTriggerId:t]; }
- (BOOL) displayInstance:(Instance *)i { return [delegate displayInstance:i]; }
- (BOOL) displayInstanceId:(int)i      { return [delegate displayInstanceId:i]; }
- (BOOL) displayObject:(id)o           { return [delegate displayObject:o]; }
- (BOOL) displayObjectType:(NSString *)type id:(int)type_id { return [delegate displayObjectType:type id:type_id]; }
- (void) displayTab:(Tab *)t           { [delegate displayTab:t]; }
- (void) displayTabId:(int)t           { [delegate displayTabId:t]; }
- (void) displayTabType:(NSString *)t  { [delegate displayTabType:t]; }
- (void) displayScannerWithPrompt:(NSString *)p { [delegate displayScannerWithPrompt:p]; }

- (void) dealloc
{
    [webView clear];
    webView.delegate = nil;
}

@end

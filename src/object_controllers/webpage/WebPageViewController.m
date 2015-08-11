//
//  WebPageViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebPageViewController.h"
#import "WebPage.h"
#import "DialogViewController.h"
#import "AppModel.h"
#import "ARISWebView.h"
#import "ARISMediaView.h"

@interface WebPageViewController() <ARISWebViewDelegate>
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

- (id) initWithWebPage:(WebPage *)w delegate:(id<WebPageViewControllerDelegate>)d
{
  if(self = [super init])
  {
    Instance *i = [_MODEL_INSTANCES_ instanceForId:0];
    i.object_type = @"WEB_PAGE";
    i.object_id = w.web_page_id;
    
    instance = i;
    webPage = w;

    delegate = d;
    hasAppeared = NO;
  }
  return self; 
}

- (id) initWithInstance:(Instance *)i delegate:(id<WebPageViewControllerDelegate>)d
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
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webPage.url]] withAppendation:[NSString stringWithFormat:@"&web_page_id=%ld",webPage.web_page_id]];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  
    if(!webPage || webPage.back_button_enabled) 
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    if(tab)
    {
        UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
        [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
        [threeLineNavButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        threeLineNavButton.accessibilityLabel = @"In-Game Menu";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
    }
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
    [delegate instantiableViewControllerRequestsDismissal:self];
    if(tab) [self showNav];
}

- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"WEB_PAGE"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; if(webPage.name && ![webPage.name isEqualToString:@""]) return webPage.name; return @"Web Page"; }
- (ARISMediaView *) tabIcon
{
    ARISMediaView *amv = [[ARISMediaView alloc] init];
    if(tab.icon_media_id)
        [amv setMedia:[_MODEL_MEDIA_ mediaForId:tab.icon_media_id]];
    else if(webPage.icon_media_id)
        [amv setMedia:[_MODEL_MEDIA_ mediaForId:webPage.icon_media_id]];
    else
        [amv setImage:[UIImage imageNamed:@"logo_icon"]];
    return amv;
}

- (void) dealloc
{
    [webView clear];
    webView.delegate = nil;
}

@end

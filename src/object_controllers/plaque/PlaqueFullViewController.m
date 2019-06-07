//
//  PlaqueFullViewController.m
//  ARIS
//
//  Created by Michael Tolly on 7/23/18.
//

#import "PlaqueFullViewController.h"
#import "Plaque.h"
#import "AppModel.h"
#import "ARISWebView.h"
#import "ARISMediaView.h"
#import "PopupWebViewController.h"
#import <Google/Analytics.h>

@interface PlaqueFullViewController() <ARISWebViewDelegate, PopupWebViewControllerDelegate>
{
  Plaque *plaque;
  Instance *instance;
  Tab *tab;
  
  ARISWebView *webView;
  UIActivityIndicatorView *activityIndicator;
  UIView *continueButton;
  UILabel *continueLbl;
  UIImageView *arrow;
  UIView *line;
  PopupWebViewController *popupVC;
  
  BOOL hasAppeared;
  
  id<PlaqueFullViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation PlaqueFullViewController

- (id) initWithInstance:(Instance *)i delegate:(id<PlaqueFullViewControllerDelegate>)d
{
  if((self = [super init]))
  {
    delegate = d;
    instance = i;
    plaque = [_MODEL_PLAQUES_ plaqueForId:instance.object_id];
    if(plaque.event_package_id) [_MODEL_EVENTS_ runEventPackageId:plaque.event_package_id];
    self.title = self.tabTitle;
  }
  
  return self;
}
- (Instance *) instance { return instance; }

- (id) initWithTab:(Tab *)t delegate:(id<PlaqueFullViewControllerDelegate>)d
{
  if((self = [super init]))
  {
    delegate = d;
    tab = t;
    instance = [_MODEL_INSTANCES_ instanceForId:0]; //get null inst
    instance.object_type = tab.type;
    instance.object_id = tab.content_id;
    plaque = [_MODEL_PLAQUES_ plaqueForId:instance.object_id];
    self.title = plaque.name;
  }
  return self;
}
- (Tab *) tab { return tab; }

- (void) loadView
{
  [super loadView];
  
  // TODO
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName value:@"Plaque"];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
  
  if(!hasAppeared) [self viewWillAppearFirstTime];
}

- (void) viewWillAppearFirstTime
{
  hasAppeared = YES;
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
  [activityIndicator startAnimating];
  [self.view addSubview:activityIndicator];
  
  CGFloat continueHeight = 0.0;
  if (![plaque.continue_function isEqualToString:@"NONE"]) {
    continueHeight = 44.0;
  }
  webView = [[ARISWebView alloc] initWithFrame:CGRectMake(0,64,self.view.bounds.size.width,self.view.bounds.size.height-64-continueHeight) delegate:self];
  //webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
  webView.scrollView.bounces = NO;
  webView.scalesPageToFit = YES;
  webView.allowsInlineMediaPlayback = YES;
  webView.mediaPlaybackRequiresUserAction = NO;
  [webView loadHTMLString:plaque.desc baseURL:nil]; // does nil work here?
  
  /*
  UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  backButton.frame = CGRectMake(0, 0, 27, 27);
  [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
  backButton.accessibilityLabel = @"Back Button";
  [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  
  if(!plaque || plaque.back_button_enabled)
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
  */
  
  if(tab)
  {
    UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
    // TODO fix this to close the nav if it's already open
    [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside];
    threeLineNavButton.accessibilityLabel = @"In-Game Menu";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
    // newly required in iOS 11: https://stackoverflow.com/a/44456952
    if ([threeLineNavButton respondsToSelector:@selector(widthAnchor)] && [threeLineNavButton respondsToSelector:@selector(heightAnchor)]) {
      [[threeLineNavButton.widthAnchor constraintEqualToConstant:27.0] setActive:true];
      [[threeLineNavButton.heightAnchor constraintEqualToConstant:27.0] setActive:true];
    }
  }
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
  [activityIndicator removeFromSuperview];
  [activityIndicator stopAnimating];
  activityIndicator = nil;
  
  if(_MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 2.0;"];
  }

  [self.view addSubview:webView];
  
  if (![plaque.continue_function isEqualToString:@"NONE"]) {
    continueButton = [[UIView alloc] init];
    continueButton.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
    continueButton.userInteractionEnabled = YES;
    continueButton.accessibilityLabel = @"Continue";
    continueLbl = [[UILabel alloc] init];
    continueLbl.textColor = [ARISTemplate ARISColorText];
    continueLbl.textAlignment = NSTextAlignmentRight;
    continueLbl.text = NSLocalizedString(@"ContinueKey", @"");
    continueLbl.font = [ARISTemplate ARISButtonFont];
    [continueButton addSubview:continueLbl];
    [continueButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueButtonTouched)]];
    
    arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor ARISColorLightGray];

    continueButton.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
    continueLbl.frame = CGRectMake(0,0,self.view.bounds.size.width-30,44);
    arrow.frame = CGRectMake(self.view.bounds.size.width-25, self.view.bounds.size.height-30, 19, 19);
    line.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 1);
    
    [self.view addSubview:continueButton];
    [self.view addSubview:arrow];
    [self.view addSubview:line];
  }
  
}

- (BOOL) ARISWebView:(ARISWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)r navigationType:(UIWebViewNavigationType)nt
{
  return YES;
}

- (void) continueButtonTouched
{
  if ([plaque.continue_function isEqualToString:@"JAVASCRIPT"]) {
    [webView hookWithParams:@""];
  } else if ([plaque.continue_function isEqualToString:@"EXIT"]) {
    [self dismissSelf];
  } else {
    // this shouldn't happen, the button shouldn't have been drawn
  }
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
  [self dismissSelfNoNav];
}

- (void)ARISWebViewRequestsButtonLabel:(ARISWebView *)awv label:(NSString *)s
{
  continueLbl.text = s;
}

- (void) backButtonTouched
{
  [self dismissSelf];
}

- (void)ARISWebViewRequestsPopup:(ARISWebView *)awv content:(NSString *)s
{
  popupVC = [[PopupWebViewController alloc] initWithContent:s delegate:self];
  popupVC.view.frame = self.view.frame;
  popupVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
  [self presentViewController:popupVC animated:YES completion:nil];
}

- (void) popupRequestsDismiss
{
  [popupVC dismissViewControllerAnimated:YES completion:nil];
}

- (void) dismissSelf
{
  [self dismissSelfNoNav];
  if(tab) [self showNav];
}

- (void) dismissSelfNoNav
{
  [webView clear];
  [self.navigationController popToRootViewControllerAnimated:YES];
  [delegate instantiableViewControllerRequestsDismissal:self];
}

- (void) showNav
{
  // normally the "log player viewed" is done on "view controller requests dismissal"
  // so this is only needed for a tab
  if (tab) [_MODEL_LOGS_ playerViewedContent:instance.object_type id:instance.object_id];
  [delegate gamePlayTabBarViewControllerRequestsNav];
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"PLAQUE"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; if(plaque.name && ![plaque.name isEqualToString:@""]) return plaque.name; return @"Plaque"; }
- (ARISMediaView *) tabIcon
{
  ARISMediaView *amv = [[ARISMediaView alloc] init];
  if(tab.icon_media_id)
    [amv setMedia:[_MODEL_MEDIA_ mediaForId:tab.icon_media_id]];
  else if(plaque.icon_media_id)
    [amv setMedia:[_MODEL_MEDIA_ mediaForId:plaque.icon_media_id]];
  else
    [amv setImage:[UIImage imageNamed:@"logo_icon"]];
  return amv;
}

- (void)dealloc
{
  webView.delegate = nil;
  [webView stopLoading];
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

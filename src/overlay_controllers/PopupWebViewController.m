//
//  PopupWebViewController.m
//  ARIS
//
//  Created by Michael Tolly on 6/6/19.
//

#import "PopupWebViewController.h"
#import "AppModel.h"
#import "ARISWebView.h"
#import <Google/Analytics.h>

@interface PopupWebViewController() <ARISWebViewDelegate>
{
  NSString *content;
  
  ARISWebView *webView;
  UIActivityIndicatorView *activityIndicator;
  UIView *continueButton;
  UILabel *continueLbl;
  UIImageView *arrow;
  UIView *line;
  
  BOOL hasAppeared;
  
  id<PopupWebViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation PopupWebViewController

- (id)initWithContent:(NSString *)s delegate:(id<PopupWebViewControllerDelegate>)d
{
  if((self = [super init]))
  {
    delegate = d;
    content = s;
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
  
  self.view.backgroundColor = [UIColor ARISColorTranslucentBlack];
  
  activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
  [activityIndicator startAnimating];
  [self.view addSubview:activityIndicator];
  
  CGFloat continueHeight = 44.0;
  webView = [[ARISWebView alloc] initWithFrame:CGRectInset(CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-continueHeight), 40.0, 40.0) delegate:self];
  webView.backgroundColor = [UIColor whiteColor];
  //webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
  webView.scrollView.bounces = NO;
//  webView.scalesPageToFit = YES;
  webView.allowsInlineMediaPlayback = YES;
  webView.mediaPlaybackRequiresUserAction = NO;
  NSString *html = [NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], content];
  [webView loadHTMLString:html baseURL:nil]; // does nil work here?
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

- (BOOL) ARISWebView:(ARISWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)r navigationType:(UIWebViewNavigationType)nt
{
  return YES;
}

- (void) continueButtonTouched
{
  [self dismissSelf];
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
  [self dismissSelf];
}

- (void)ARISWebViewRequestsButtonLabel:(ARISWebView *)awv label:(NSString *)s
{
  continueLbl.text = s;
}

- (void) backButtonTouched
{
  [self dismissSelf];
}

- (void) dismissSelf
{
  [webView clear];
  [self.navigationController popToRootViewControllerAnimated:YES];
  [delegate popupRequestsDismiss];
}

- (void)dealloc
{
  webView.delegate = nil;
  [webView stopLoading];
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

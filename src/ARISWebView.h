//
//  ARISWebView.h
//  ARIS
//
//  Created by Phil Dougherty on 1/8/14.
//
//  Wraps UIWebView rather than subclassing it. Apple gets angry when
//  UIWebView is subclassed. So this manually fakes webview interface
//  and passes it along.
//

#import <UIKit/UIKit.h>

@class ARISWebView;
@protocol ARISWebViewDelegate <UIWebViewDelegate>
@optional
- (void) ARISWebViewRequestsDismissal: (ARISWebView *)awv;
- (void) ARISWebViewRequestsRefresh:   (ARISWebView *)awv;
- (void) ARISWebViewRequestsHideButton:(ARISWebView *)awv;
- (void) ARISWebViewRequestsButtonLabel:(ARISWebView *)awv label:(NSString *)s;
- (void) ARISWebViewRequestsPopup:(ARISWebView *)awv content:(NSString *)s;
//WebViewDelegate pretenders:
- (BOOL) ARISWebView:(ARISWebView *)wv shouldStartLoadWithRequest:(NSURLRequest*)r navigationType:(UIWebViewNavigationType)nt;
- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv;
- (void) ARISWebViewDidStartLoad:(ARISWebView *)wv;
@end

@interface ARISWebView : UIView

- (id) initWithFrame:(CGRect)frame delegate:(id<ARISWebViewDelegate>)d;
- (id) initWithFrame:(CGRect)frame;
- (id) initWithDelegate:(id<ARISWebViewDelegate>)d;
- (void) setFrame:(CGRect)frame;
- (void) setDelegate:(id<ARISWebViewDelegate>)d;

//WebView pretenders:
- (NSString *) stringByEvaluatingJavaScriptFromString:(NSString *)s;
- (void) stopLoading;
- (void) loadHTMLString:(NSString *)s baseURL:(NSURL *)url;
- (void) loadRequest:(NSURLRequest *)request;
- (void) loadRequest:(NSURLRequest *)request withAppendation:(NSString *)appendation;
- (UIScrollView *) scrollView;
- (void) setScalesPageToFit:(BOOL)s;
- (void) setAllowsInlineMediaPlayback:(BOOL)a;
- (void) setMediaPlaybackRequiresUserAction:(BOOL)m;

- (BOOL) hookWithParams:(NSString *)params;
- (BOOL) tickWithParams:(NSString *)params;
- (void) clear;

@end


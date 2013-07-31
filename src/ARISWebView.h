//
//  ARISWebView.h
//  ARIS
//
//  Created by Phil Dougherty on 7/30/13.
//
//

#import <UIKit/UIKit.h>
#import "StateControllerProtocol.h"

@class ARISWebView;
@protocol ARISWebViewDelegate
- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv;
- (void) ARISWebViewRequestsRefresh:(ARISWebView *)awv;
@end
@interface ARISWebView : UIWebView
- (id) initWithFrame:(CGRect)frame delegate:(id<UIWebViewDelegate,ARISWebViewDelegate,StateControllerProtocol>)d;
- (id) initWithDelegate:(id<UIWebViewDelegate,ARISWebViewDelegate,StateControllerProtocol>)d;
- (void) setDelegate:(id<UIWebViewDelegate,ARISWebViewDelegate,StateControllerProtocol>)d;

- (void) injectHTMLWithARISjs;
- (BOOL) isARISRequest:(NSURLRequest *)request;
- (BOOL) handleARISRequestIfApplicable:(NSURLRequest *)request;
- (void) loadRequest:(NSURLRequest *)request withAppendation:(NSString *)appendation;
- (void) hookWithParams:(NSString *)params;
- (void) clear;

@end

//
//  webpageViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebPage.h"
#import "AppModel.h"

@interface webpageViewController : UIViewController <UIWebViewDelegate>{
    IBOutlet	UIWebView	*webView;
    WebPage     *webPage;
    IBOutlet UIView  *blackView;
    NSObject *delegate;
    IBOutlet	UIActivityIndicatorView *activityIndicator;
}

@property(nonatomic) IBOutlet UIWebView		*webView;
@property(nonatomic) WebPage *webPage;
@property(nonatomic) NSObject  *delegate;
@property(nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic)IBOutlet UIView *blackView;

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType;
- (void) showWaitingIndicator;
- (void) dismissWaitingIndicator;
- (void)refreshConvos;

@end

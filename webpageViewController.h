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
}

@property(nonatomic, retain) IBOutlet UIWebView		*webView;
@property(nonatomic,retain) WebPage *webPage;

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType;

@end

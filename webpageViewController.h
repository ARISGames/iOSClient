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

@interface webpageViewController : UIViewController {
    IBOutlet	UIWebView	*webView;
    WebPage     *webPage;
}

@property(nonatomic, retain) IBOutlet UIWebView		*webView;
@property(nonatomic,retain) WebPage *webPage;

@end

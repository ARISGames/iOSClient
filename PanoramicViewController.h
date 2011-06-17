//
//  PanoramicViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Panoramic.h"

@interface PanoramicViewController : UIViewController {
    Panoramic *panoramic;
    IBOutlet	UIWebView	*webView;
}

@property (nonatomic,retain)Panoramic *panoramic;
@property(nonatomic, retain) IBOutlet UIWebView	*webView;
@end

//
//  WebPageViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstantiableViewController.h"

@class WebPage;
@protocol StateControllerProtocol;

@interface WebPageViewController : InstantiableViewController 

- (id) initWithWebPage:(WebPage *)w delegate:(NSObject<InstantiableViewControllerDelegate, StateControllerProtocol> *)d;

@end

//
//  WebPageViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstantiableViewController.h"

@protocol StateControllerProtocol;
@class Instance;
@interface WebPageViewController : InstantiableViewController 
- (id) initWithInstance:(Instance *)i delegate:(NSObject<InstantiableViewControllerDelegate, StateControllerProtocol> *)d;
@end

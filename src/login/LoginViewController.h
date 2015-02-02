//
//  LoginViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class User;

@protocol LoginViewControllerDelegate
@end

@interface LoginViewController : ARISViewController
- (id) initWithDelegate:(id<LoginViewControllerDelegate>)d;
@end

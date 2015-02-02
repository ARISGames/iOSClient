//
//  LoadingViewControllerViewController.h
//  ARIS
//
//  Created by Brian Thiel on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol LoadingViewControllerDelegate
@end

@interface LoadingViewController : ARISViewController

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
- (void) startLoading;

@end

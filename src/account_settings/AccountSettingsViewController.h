//
//  AccountSettingsController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol AccountSettingsViewControllerDelegate
- (void) profileEditRequested;
@end

@interface AccountSettingsViewController : ARISViewController
- (id) initWithDelegate:(id<AccountSettingsViewControllerDelegate>)d;
@end

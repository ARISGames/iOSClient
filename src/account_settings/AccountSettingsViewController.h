//
//  AccountSettingsController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountSettingsViewControllerDelegate
- (void) playerSettingsRequested;
- (void) logoutWasRequested;
@end

@interface AccountSettingsViewController : UIViewController
- (id) initWithDelegate:(id<AccountSettingsViewControllerDelegate>)d;
@end

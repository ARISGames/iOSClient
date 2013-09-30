//
//  PlayerSettingsViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol PlayerSettingsViewControllerDelegate
- (void) playerSettingsWasDismissed;
@end

@interface PlayerSettingsViewController : ARISViewController 

- (id) initWithDelegate:(id<PlayerSettingsViewControllerDelegate>)d;
- (void) resetState;

@end

//
//  GameNotificationViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol GameNotificationViewControllerDelegate
@end
@interface GameNotificationViewController : ARISViewController

- (id) initWithDelegate:(id<GameNotificationViewControllerDelegate>)d;
- (void) cutOffGameNotifications;

@end


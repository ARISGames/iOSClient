//
//  GameNotificationViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@interface GameNotificationViewController : ARISViewController

- (void) startListeningToModel;
- (void) stopListeningToModel;
- (void) cutOffGameNotifications;

@end

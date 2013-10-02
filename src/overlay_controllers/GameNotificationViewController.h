//
//  GameNotificationViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol StateControllerProtocol;
@interface GameNotificationViewController : ARISViewController

- (id) initWithDelegate:(id<StateControllerProtocol>)d;
- (void) startListeningToModel;
- (void) stopListeningToModel;
- (void) cutOffGameNotifications;

@end

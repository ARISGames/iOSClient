//
//  GameNotificationViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import <UIKit/UIKit.h>
#import "PopOverViewController.h" //Just including this in the header for its protocol... really should be separated into different file

@interface GameNotificationViewController : UIViewController <PopOverViewDelegate>

- (void) startListeningToModel;
- (void) stopListeningToModel;
- (void) cutOffGameNotifications;

@end

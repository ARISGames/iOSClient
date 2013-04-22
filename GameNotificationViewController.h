//
//  GameNotificationViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import <UIKit/UIKit.h>
#import "PopOverViewController.h"

@interface GameNotificationViewController : UIViewController <PopOverViewDelegate>
{
    UIWebView *dropDownView;
    PopOverViewController *popOverVC;
    PopOverContentView *popOverView;
    
    NSMutableArray *notifArray;
    NSMutableArray *popOverArray;
    BOOL showingDropDown;
    BOOL showingPopOver;
}

- (void) startListeningToModel;
- (void) stopListeningToModel;
- (void) cutOffGameNotifications;

@end

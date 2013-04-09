//
//  GameNotificationViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import <UIKit/UIKit.h>
#import "MTStatusBarOverlay.h"
#import "PopOverViewController.h"

@interface GameNotificationViewController : UIViewController <MTStatusBarOverlayDelegate, PopOverViewDelegate>
{
    MTStatusBarOverlay *statusBar;
    PopOverViewController *popOverVC;
    PopOverContentView *popOverView;
    
    NSMutableArray *popOverArray;
    BOOL showingPopOver;
}

- (void) startListeningToModel;
- (void) stopListeningToModel;
- (void) cutOffGameNotifications;

@end

//
//  GamePickersViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 5/3/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISContainerViewController.h"

@class Game;

@protocol GamePickersViewControllerDelegate
- (void) gamePickedForPlay:(Game *)g;
- (void) playerSettingsRequested;
- (void) logoutWasRequested;
@end

@interface GamePickersViewController : ARISContainerViewController

- (id) initWithDelegate:(id<GamePickersViewControllerDelegate>)d;

@end

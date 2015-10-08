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
- (void) profileEditRequested;
- (void) passChangeRequested;
- (void) gameDetailsRequested:(Game *)g downloaded:(BOOL)d;
@end

@interface GamePickersViewController : ARISContainerViewController

- (id) initWithDelegate:(id<GamePickersViewControllerDelegate>)d;

@end

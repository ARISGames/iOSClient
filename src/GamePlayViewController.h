//
//  GamePlayViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 5/2/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISContainerViewController.h"

@class Game;

@protocol GamePlayViewControllerDelegate
- (void) gameplayWasDismissed;
@end

@interface GamePlayViewController : ARISContainerViewController
- (id) initWithGame:(Game *)g delegate:(id<GamePlayViewControllerDelegate>)d;
@end

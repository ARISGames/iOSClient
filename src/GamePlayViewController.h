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
@end

@interface GamePlayViewController : ARISContainerViewController
- (id) initWithDelegate:(id<GamePlayViewControllerDelegate>)d;
@end

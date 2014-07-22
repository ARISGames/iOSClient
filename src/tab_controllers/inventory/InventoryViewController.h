//
//  InventoryViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/30/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"

@protocol StateControllerProtocol;
@protocol InventoryViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface InventoryViewController : ARISGamePlayTabBarViewController
- (id) initWithDelegate:(id<GamePlayTabBarViewControllerDelegate, InventoryViewControllerDelegate, StateControllerProtocol>)d;
@end

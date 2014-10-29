//
//  InventoryViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/30/13.
//
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol StateControllerProtocol;
@protocol InventoryViewControllerDelegate <GamePlayTabBarViewControllerDelegate, StateControllerProtocol>
@end

@interface InventoryViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithDelegate:(id<InventoryViewControllerDelegate>)d;
@end

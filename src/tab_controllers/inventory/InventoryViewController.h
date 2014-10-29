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

@class Tab;
@interface InventoryViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithTab:(Tab *)t delegate:(id<InventoryViewControllerDelegate>)d;
@end

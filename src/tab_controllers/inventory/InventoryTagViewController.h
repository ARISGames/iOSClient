//
//  InventoryTagViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/30/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"
#import "InventoryViewControllerDelegate.h"

@protocol StateControllerProtocol;

@interface InventoryTagViewController : ARISGamePlayTabBarViewController
- (id) initWithDelegate:(id<InventoryViewControllerDelegate, StateControllerProtocol>)d;
@end

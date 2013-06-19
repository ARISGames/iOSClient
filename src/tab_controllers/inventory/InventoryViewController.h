//
//  FilesViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"

@protocol StateControllerProtocol;

@protocol InventoryViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface InventoryViewController : ARISGamePlayTabBarViewController
- (id) initWithDelegate:(id<InventoryViewControllerDelegate, StateControllerProtocol>)d;

@end

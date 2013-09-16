//
//  InventoryViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"
#import "InventoryViewControllerDelegate.h"

@protocol StateControllerProtocol;

@interface InventoryViewController : ARISGamePlayTabBarViewController
- (id) initWithDelegate:(id<InventoryViewControllerDelegate, StateControllerProtocol>)d;
@end

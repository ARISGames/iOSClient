//
//  NearbyObjectsViewController.h
//  ARIS
//
//  Created by David J Gagnon on 2/13/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"

@protocol StateControllerProtocol;
@protocol NearbyObjectsViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
- (void) showNearbyObjectsTab;
- (void) hideNearbyObjectsTab;
@end

@interface NearbyObjectsViewController : ARISGamePlayTabBarViewController <UITableViewDataSource,UITableViewDelegate>
- (id)initWithDelegate:(id<NearbyObjectsViewControllerDelegate, StateControllerProtocol>)d;
@end

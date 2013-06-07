//
//  MapViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"

@protocol StateControllerProtocol;
@protocol MapViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface MapViewController : ARISGamePlayTabBarViewController
- (id) initWithDelegate:(id<MapViewControllerDelegate, StateControllerProtocol>)d;

@end

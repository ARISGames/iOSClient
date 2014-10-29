//
//  MapViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol StateControllerProtocol;
@protocol MapViewControllerDelegate <GamePlayTabBarViewControllerDelegate, StateControllerProtocol>
@end

@interface MapViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithDelegate:(id<MapViewControllerDelegate>)d;

@end

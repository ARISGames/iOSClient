//
//  MapViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol MapViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface MapViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithTab:(Tab *)t delegate:(id<MapViewControllerDelegate>)d;

@end

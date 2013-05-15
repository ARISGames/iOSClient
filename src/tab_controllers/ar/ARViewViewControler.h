//
//  ARViewViewControler.h
//  ARIS
//
//  Created by David J Gagnon on 12/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "ARGeoViewController.h"
#import "NearbyObjectARCoordinate.h"


@interface ARViewViewControler : ARISGamePlayTabBarViewController <UIApplicationDelegate, ARViewDelegate>
{
	NSMutableArray *locations;
	ARGeoViewController *ARviewController;
}

@property(nonatomic) NSMutableArray *locations;

- (UIView *)viewForCoordinate:(NearbyObjectARCoordinate *)coordinate;
- (void) refresh;


@end

//
//  PlaqueViewController.h
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ARISViewController.h"
#import "InstantiableViewControllerProtocol.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol StateControllerProtocol;
@protocol PlaqueViewControllerDelegate <InstantiableViewControllerDelegate, GamePlayTabBarViewControllerDelegate, StateControllerProtocol>
@end

@class Instance;
@class Tab;
@interface PlaqueViewController : ARISViewController <InstantiableViewControllerProtocol, GamePlayTabBarViewControllerProtocol>
- (id) initWithInstance:(Instance *)i delegate:(id<PlaqueViewControllerDelegate>)d;
- (id) initWithTab:(Tab *)t delegate:(id<PlaqueViewControllerDelegate>)d;
@end

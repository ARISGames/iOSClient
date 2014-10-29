//
//  AttributesViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol AttributesViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@class Tab;
@interface AttributesViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithTab:(Tab *)t delegate:(id<AttributesViewControllerDelegate>)d;
- (void) refresh;
@end

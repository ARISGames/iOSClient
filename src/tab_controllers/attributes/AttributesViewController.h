//
//  AttributesViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"

@protocol AttributesViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface AttributesViewController : ARISGamePlayTabBarViewController

- (id) initWithDelegate:(id<AttributesViewControllerDelegate>)d;
- (void) refresh;

@end

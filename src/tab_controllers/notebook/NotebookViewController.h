//
//  NotebookViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"

@protocol StateControllerProtocol;
@protocol NotebookViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface NotebookViewController : ARISGamePlayTabBarViewController
- (id) initWithDelegate:(id<NotebookViewControllerDelegate, StateControllerProtocol>)d;
@end

//
//  BogusSelectGameViewController.h
//  ARIS
//
//  Created by David J Gagnon on 6/8/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"

@protocol BogusSelectGameViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
- (void) gameDismisallWasRequested;
@end

@interface BogusSelectGameViewController : ARISGamePlayTabBarViewController

- (id) initWithDelegate:(id<BogusSelectGameViewControllerDelegate>)d;

@end

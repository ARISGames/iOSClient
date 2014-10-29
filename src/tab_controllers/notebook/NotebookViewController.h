//
//  NotebookViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol NotebookViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@class Tab;
@interface NotebookViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithTab:(Tab *)t delegate:(id<NotebookViewControllerDelegate>)d;
@end

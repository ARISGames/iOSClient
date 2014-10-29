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

@interface NotebookViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithDelegate:(id<NotebookViewControllerDelegate>)d;
@end

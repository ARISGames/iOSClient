//
//  GamePlayTabSelectorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class ARISNavigationController;

@protocol GamePlayTabSelectorViewControllerDelegate
- (void) viewControllerRequestedDisplay:(ARISNavigationController *)avc;
@end

@interface GamePlayTabSelectorViewController : ARISViewController
- (id) initWithDelegate:(id<GamePlayTabSelectorViewControllerDelegate>)d;
- (ARISNavigationController *) firstViewController;
@end

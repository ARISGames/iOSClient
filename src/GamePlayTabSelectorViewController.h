//
//  GamePlayTabSelectorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import <UIKit/UIKit.h>
@class ARISNavigationController;
@class ARISGamePlayTabBarViewController;

@protocol GamePlayTabSelectorViewControllerDelegate
- (void) viewControllerRequestedDisplay:(ARISNavigationController *)avc;
- (void) gameRequestsDismissal;
@end

@interface GamePlayTabSelectorViewController : UIViewController
- (id) initWithViewControllers:(NSMutableArray *)vcs delegate:(id<GamePlayTabSelectorViewControllerDelegate>)d;
@end

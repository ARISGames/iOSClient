//
//  GamePlayTabSelectorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import <UIKit/UIKit.h>
@class ARISNavigationController;

@protocol GamePlayTabSelectorViewControllerDelegate
- (void) viewControllerRequestedDisplay:(ARISNavigationController *)avc;
@end

@interface GamePlayTabSelectorViewController : UIViewController
- (id) initWithViewControllers:(NSArray *)vcs delegate:(id<GamePlayTabSelectorViewControllerDelegate>)d;
@end

//
//  ARISGamePlayTabBarViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 5/8/13.
//
//

#import <UIKit/UIKit.h>

@class ARISGamePlayTabBarViewController;
@protocol GameObjectProtocol;

@protocol GamePlayTabBarViewControllerDelegate
- (void) showTutorialPopupPointingToTabForViewController:(ARISGamePlayTabBarViewController *)vc title:(NSString *)title message:(NSString *)message;
- (void) dismissTutorial;
@end

@interface ARISGamePlayTabBarViewController : UIViewController
{
    int badgeCount;
}
- (void) clearBadge;
- (void) incrementBadge;

@end

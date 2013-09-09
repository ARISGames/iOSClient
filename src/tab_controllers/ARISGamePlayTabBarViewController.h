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
- (void) gamePlayTabBarViewControllerRequestsNav;
@end

@interface ARISGamePlayTabBarViewController : UIViewController
{
    NSString *tabID;
    NSString *tabIconName;
    int badgeCount;
}

@property (nonatomic, strong) NSString *tabID;
@property (nonatomic, strong) NSString *tabIconName;

- (id) initWithDelegate:(id<GamePlayTabBarViewControllerDelegate>)d;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<GamePlayTabBarViewControllerDelegate>)d;
- (void) showNav;
- (void) clearBadge;
- (void) incrementBadge;

@end

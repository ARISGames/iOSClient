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
@end

@interface ARISGamePlayTabBarViewController : UIViewController
{
    NSString *tabID;
    int badgeCount;
}

@property (nonatomic, strong) NSString *tabID;
- (void) clearBadge;
- (void) incrementBadge;

@end

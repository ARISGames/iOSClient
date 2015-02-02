//
//  GamePlayTabBarViewControllerProtocol.h
//  ARIS
//
//  Created by Phil Dougherty on 5/8/13.
//
//

@protocol GamePlayTabBarViewControllerDelegate
- (void) gamePlayTabBarViewControllerRequestsNav;
@end

@protocol GamePlayTabBarViewControllerProtocol
- (NSString *) tabId;
- (NSString *) tabTitle;
- (UIImage *) tabIcon;
- (void) showNav;
@end

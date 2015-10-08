//
//  GamePlayTabBarViewControllerProtocol.h
//  ARIS
//
//  Created by Phil Dougherty on 5/8/13.
//
//

#include "ARISMediaView.h"

@protocol GamePlayTabBarViewControllerDelegate
- (void) gamePlayTabBarViewControllerRequestsNav;
@end

@protocol GamePlayTabBarViewControllerProtocol
- (NSString *) tabId;
- (NSString *) tabTitle;
- (ARISMediaView *) tabIcon;
- (void) showNav;
@end

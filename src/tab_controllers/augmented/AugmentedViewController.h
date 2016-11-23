//
//  AugmentedViewController.h
//  ARIS
//
//  Created by Michael Tolly on 11/23/16.
//
//

#import <AVFoundation/AVFoundation.h>
#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol AugmentedViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@class Tab;
@interface AugmentedViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithTab:(Tab *)t delegate:(id<AugmentedViewControllerDelegate>)d;
@end

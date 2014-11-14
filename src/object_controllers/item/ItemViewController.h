//
//  ItemViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 10/17/13.
//
//

#import "ARISViewController.h"
#import "InstantiableViewControllerProtocol.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol ItemViewControllerDelegate <InstantiableViewControllerDelegate, GamePlayTabBarViewControllerDelegate>
@end

@class Instance;
@class Tab;
@interface ItemViewController : ARISViewController <InstantiableViewControllerProtocol, GamePlayTabBarViewControllerProtocol>
- (id) initWithInstance:(Instance *)i delegate:(id<ItemViewControllerDelegate>)d;
- (id) initWithTab:(Tab *)t delegate:(id<ItemViewControllerDelegate>)d;
@end

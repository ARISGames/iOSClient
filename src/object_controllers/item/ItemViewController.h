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

@class Item;
@class Instance;
@protocol StateControllerProtocol;

@protocol ItemViewControllerDelegate <InstantiableViewControllerDelegate, GamePlayTabBarViewControllerDelegate, StateControllerProtocol>
@end

@interface ItemViewController : ARISViewController <InstantiableViewControllerProtocol, GamePlayTabBarViewControllerProtocol>
{
  Item *item;
  Instance *instance;
}
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) Instance *instance;

- (id) initWithInstance:(Instance *)i delegate:(id<ItemViewControllerDelegate>)d;

@end

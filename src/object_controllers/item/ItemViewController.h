//
//  ItemViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 10/17/13.
//
//

#import <UIKit/UIKit.h>
#import "GameObjectViewController.h"

@class Item;
@class Instance;
@protocol StateControllerProtocol;

@protocol ItemViewControllerSource
- (BOOL) supportsDropping;
- (BOOL) item:(Item *)i droppedQty:(int)q;
- (BOOL) supportsDestroying;
- (BOOL) item:(Item *)i destroyedQty:(int)q;
- (BOOL) supportsPickingUp;
- (BOOL) item:(Item *)i pickedUpQty:(int)q;
@end

@interface ItemViewController : GameObjectViewController
{
  Item *item; 
  Instance *instance;
}
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) Instance *instance;

- (id) initWithInstance:(Instance *)i delegate:(id<GameObjectViewControllerDelegate,StateControllerProtocol>)d source:(id<ItemViewControllerSource>)s;

@end

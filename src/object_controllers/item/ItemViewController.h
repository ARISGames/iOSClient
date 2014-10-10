//
//  ItemViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 10/17/13.
//
//

#import <UIKit/UIKit.h>
#import "InstantiableViewController.h"

@class Item;
@class Instance;
@protocol StateControllerProtocol;

@interface ItemViewController : InstantiableViewController
{
  Item *item;
  Instance *instance;
}
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) Instance *instance;

- (id) initWithInstance:(Instance *)i delegate:(id<InstantiableViewControllerDelegate,StateControllerProtocol>)d;

@end

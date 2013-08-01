//
//  ItemViewController.h
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObjectViewController.h"

typedef enum {
	kItemDetailsViewing,
	kItemDetailsDropping,
	kItemDetailsDestroying,
	kItemDetailsPickingUp
} ItemDetailsModeType;

@class Item;
@protocol StateControllerProtocol;

@interface ItemViewController : GameObjectViewController
{
    Item *item;
}
@property (nonatomic, strong) Item *item;

- (id) initWithItem:(Item *)i delegate:(NSObject<GameObjectViewControllerDelegate,StateControllerProtocol> *)d source:(id)s;
- (void) updateQuantityDisplay;

@end

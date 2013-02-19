//
//  InventoryModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface InventoryModel : NSObject
{
    NSArray *currentInventory;
    int currentWeight;
    int weightCap;
}

@property(nonatomic, strong) NSArray *currentInventory;
@property(nonatomic) int currentWeight;
@property(nonatomic) int weightCap;

-(void)clearData;
-(int)removeItemFromInventory:(Item*)item qtyToRemove:(int)qty;
-(int)addItemToInventory:(Item*)item qtyToAdd:(int)qty;
-(Item *)inventoryItemForId:(int)itemId;

@end

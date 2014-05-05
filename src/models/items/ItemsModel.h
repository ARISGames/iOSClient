//
//  ItemsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "Instance.h"

@interface ItemsModel : NSObject
{
    int currentWeight;
    int weightCap;
}

@property(nonatomic, assign) int currentWeight;
@property(nonatomic, assign) int weightCap;

- (Item *) itemForId:(int)item_id;
- (NSArray *) inventory;
- (NSArray *) attributes;

- (int) takeItemFromPlayer:(Item*)item qtyToRemove:(int)qty;
- (int) giveItemToPlayer:(Item*)item qtyToAdd:(int)qty;
- (int) qtyOwnedForItem:(Item *)item;
- (void) clearPlayerData;
- (void) clearGameData;

@end

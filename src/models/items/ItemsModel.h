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
- (void) requestItems;
- (void) touchPlayerItemInstances;
- (NSArray *) inventory;
- (NSArray *) attributes;

- (int) takeItemFromPlayer:(int)item_id qtyToRemove:(int)qty;
- (int) giveItemToPlayer:(int)item_id qtyToAdd:(int)qty;
- (int) setItemsForPlayer:(int)item_id qtyToSet:(int)qty;
- (int) qtyOwnedForItem:(int)item_id;
- (int) qtyAllowedToGiveForItem:(int)item_id;
- (void) clearPlayerData;
- (void) clearGameData;

@end

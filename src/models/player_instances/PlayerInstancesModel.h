//
//  PlayerInstancesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "Instance.h"

@interface PlayerInstancesModel : NSObject
{
    long currentWeight;
}

@property(nonatomic, assign) long currentWeight;

- (void) touchPlayerInstances;
- (NSArray *) inventory;
- (NSArray *) attributes;

- (long) dropItemFromPlayer:(long)item_id qtyToRemove:(long)qty;
- (long) takeItemFromPlayer:(long)item_id qtyToRemove:(long)qty;
- (long) giveItemToPlayer:(long)item_id qtyToAdd:(long)qty;
- (long) setItemsForPlayer:(long)item_id qtyToSet:(long)qty;
- (long) qtyOwnedForItem:(long)item_id;
- (long) qtyOwnedForTag:(long)tag_id;
- (long) qtyAllowedToGiveForItem:(long)item_id;
- (void) clearPlayerData;
- (void) clearGameData;
- (BOOL) gameInfoRecvd;

@end

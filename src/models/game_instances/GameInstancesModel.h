//
//  GameInstancesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Item.h"
#import "Instance.h"

@interface GameInstancesModel : ARISModel
{
    long currentWeight;
}

@property(nonatomic, assign) long currentWeight;

- (void) touchGameInstances;
- (NSArray *) gameOwnedInstances;

- (long) takeItemFromGame:(long)item_id qtyToRemove:(long)qty;
- (long) giveItemToGame:(long)item_id qtyToAdd:(long)qty;
- (long) setItemsForGame:(long)item_id qtyToSet:(long)qty;
- (long) qtyOwnedForItem:(long)item_id;
- (long) qtyOwnedForTag:(long)tag_id;
- (long) qtyAllowedToGiveForItem:(long)item_id;

@end


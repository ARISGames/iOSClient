//
//  GroupInstancesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Item.h"
#import "Instance.h"

@interface GroupInstancesModel : ARISModel
{
    long currentWeight;
}

@property(nonatomic, assign) long currentWeight;

- (void) touchGroupInstances;
- (NSArray *) groupOwnedInstances;

- (long) takeItemFromGroup:(long)item_id qtyToRemove:(long)qty;
- (long) giveItemToGroup:(long)item_id qtyToAdd:(long)qty;
- (long) setItemsForGroup:(long)item_id qtyToSet:(long)qty;
- (long) qtyOwnedForItem:(long)item_id;
- (long) qtyOwnedForTag:(long)tag_id;
- (long) qtyAllowedToGiveForItem:(long)item_id;

@end


//
//  GroupInstancesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "GroupInstancesModel.h"
#import "AppServices.h"
#import "AppModel.h"

@interface GroupInstancesModel()
{
  NSMutableDictionary *instances;
  NSMutableArray *groupOwnedInstances;
}

@end

@implementation GroupInstancesModel

@synthesize currentWeight;

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_GROUP_INSTANCES_TOUCHED",self,@selector(groupInstancesTouched:),nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_INSTANCES_PLAYER_AVAILABLE",self,@selector(groupInstancesAvailable),nil);
  }
  return self;
}

- (void) clearPlayerData
{
  instances = [[NSMutableDictionary alloc] init];
  [self invalidateCaches];
  currentWeight = 0;
}

- (void) invalidateCaches
{
  groupOwnedInstances = nil;
}

- (void) requestGameData
{
  [self touchGroupInstances];
}
- (void) clearGameData
{
  [self clearPlayerData];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) groupInstancesTouched:(NSNotification *)notif
{
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_GROUP_INSTANCES_TOUCHED",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) touchGroupInstances
{
  [_SERVICES_ touchItemsForGroups];
}

- (void) groupInstancesAvailable
{
  NSArray *newInstances = [_MODEL_INSTANCES_ groupOwnedInstances];
  [self clearPlayerData];

  Instance *newInstance;
  for(long i = 0; i < newInstances.count; i++)
  {
    newInstance = newInstances[i];
    if(![newInstance.object_type isEqualToString:@"ITEM"] || ![newInstance.owner_type isEqualToString:@"GROUP"]) continue;

    instances[[NSNumber numberWithLong:newInstance.object_id]] = newInstance;
  }
  _ARIS_NOTIF_SEND_(@"MODEL_GROUP_INSTANCES_AVAILABLE",nil,nil);
}

- (long) dropItemFromGroup:(long)item_id qtyToRemove:(long)qty
{
  Instance *gII = instances[[NSNumber numberWithLong:item_id]];
  if(!gII) return 0; //UH OH! NO INSTANCE TO TAKE ITEM FROM! (shouldn't happen if touchItemsForGroups was called...)
  if(gII.qty < qty) qty = gII.qty;

  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ dropItem:(long)item_id qty:(long)qty];
  return [self takeItemFromGroup:item_id qtyToRemove:qty];
}

- (long) takeItemFromGroup:(long)item_id qtyToRemove:(long)qty
{
  Instance *gII = instances[[NSNumber numberWithLong:item_id]];
  if(!gII) return 0; //UH OH! NO INSTANCE TO TAKE ITEM FROM! (shouldn't happen if touchItemsForGroups was called...)
  if(gII.qty < qty) qty = gII.qty;

  return [self setItemsForGroup:item_id qtyToSet:gII.qty-qty];
}

- (long) giveItemToGroup:(long)item_id qtyToAdd:(long)qty
{
  Instance *gII = instances[[NSNumber numberWithLong:item_id]];
  if(!gII) return 0; //UH OH! NO INSTANCE TO GIVE ITEM TO! (shouldn't happen if touchItemsForGroups was called...)
  if(qty > [self qtyAllowedToGiveForItem:item_id]) qty = [self qtyAllowedToGiveForItem:item_id];

  return [self setItemsForGroup:item_id qtyToSet:gII.qty+qty];
}

- (long) setItemsForGroup:(long)item_id qtyToSet:(long)qty
{
  Instance *gII = instances[[NSNumber numberWithLong:item_id]];
  if(!gII) return 0; //UH OH! NO INSTANCE TO GIVE ITEM TO! (shouldn't happen if touchItemsForGroup was called...)

  if(qty < 0) qty = 0;
  if(qty-gII.qty > [self qtyAllowedToGiveForItem:item_id]) qty = gII.qty+[self qtyAllowedToGiveForItem:item_id];

  long oldQty = gII.qty;
  [_MODEL_INSTANCES_ setQtyForInstanceId:gII.instance_id qty:qty];
  if(qty > oldQty) [_MODEL_LOGS_ groupReceivedItemId:item_id qty:qty];
  if(qty < oldQty) [_MODEL_LOGS_ groupLostItemId:item_id qty:qty];

  return qty;
}

- (long) qtyOwnedForItem:(long)item_id
{
  return ((Instance *)instances[[NSNumber numberWithLong:item_id]]).qty;
}

- (long) qtyOwnedForTag:(long)tag_id
{
  long q = 0;
  NSArray *item_ids = [_MODEL_TAGS_ objectIdsOfType:@"ITEM" tag:tag_id];
  for(int i = 0; i < item_ids.count; i++)
    q += [self qtyOwnedForItem:((NSNumber *)item_ids[i]).longValue];
  return q;
}

- (long) qtyAllowedToGiveForItem:(long)item_id
{
  Item *i = [_MODEL_ITEMS_ itemForId:item_id];
  long amtMoreCanHold = i.max_qty_in_inventory-[self qtyOwnedForItem:item_id];
  while(_MODEL_GAME_.inventory_weight_cap > 0 &&
      (amtMoreCanHold*i.weight + currentWeight) > _MODEL_GAME_.inventory_weight_cap)
    amtMoreCanHold--;

  return amtMoreCanHold;
}

//because it's 1 to 1 (unlike player instances to attribs + inventory), very simple
- (NSArray *) groupOwnedInstances
{
  if(groupOwnedInstances) return groupOwnedInstances;

  groupOwnedInstances = [[NSMutableArray alloc] init];
  NSArray *instancearray = [instances allValues];
  for(long i = 0; i < instancearray.count; i++)
    [groupOwnedInstances addObject:[instancearray objectAtIndex:i]];
  return groupOwnedInstances;
}

- (NSString *) serializedName
{
  return @"group_instances";
}

- (NSString *) serializeModel
{
  return @"";
}

- (void) deserializeModel:(NSString *)data
{

}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

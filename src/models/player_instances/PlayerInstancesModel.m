//
//  PlayerInstancesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "PlayerInstancesModel.h"
#import "AppServices.h"
#import "AppModel.h"

@interface PlayerInstancesModel()
{
  NSMutableDictionary *playerInstances;

  NSMutableArray *inventory;
  NSMutableArray *attributes;
}

@end

@implementation PlayerInstancesModel

@synthesize currentWeight;

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_INSTANCES_TOUCHED",self,@selector(playerInstancesTouched:),nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_INSTANCES_PLAYER_AVAILABLE",self,@selector(playerInstancesAvailable),nil);
  }
  return self;
}

- (void) clearPlayerData
{
  playerInstances = [[NSMutableDictionary alloc] init];
  [self invalidateCaches];
  currentWeight = 0;
}

- (void) invalidateCaches
{
  inventory = nil;
  attributes = nil;
}

- (void) requestGameData
{
  [self touchPlayerInstances];
}
- (void) clearGameData
{
  [self clearPlayerData];
  n_game_data_received = 0;
}
- (long) nGameDataReceived
{
  return 1;
}

- (void) playerInstancesTouched:(NSNotification *)notif
{
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_PLAYER_INSTANCES_TOUCHED",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) touchPlayerInstances
{
  [_SERVICES_ touchItemsForPlayer];
}

- (void) playerInstancesAvailable
{
  NSArray *newInstances = [_MODEL_INSTANCES_ playerInstances];
  [self clearPlayerData];

  Instance *newInstance;
  for(long i = 0; i < newInstances.count; i++)
  {
    newInstance = newInstances[i];
    if(![newInstance.object_type isEqualToString:@"ITEM"] || newInstance.owner_id != _MODEL_PLAYER_.user_id) continue;

    playerInstances[[NSNumber numberWithLong:newInstance.object_id]] = newInstance;
  }
  _ARIS_NOTIF_SEND_(@"MODEL_PLAYER_INSTANCES_AVAILABLE",nil,nil);
}

- (void) calculateWeight
{
  currentWeight = 0;
  NSArray *insts = [playerInstances allValues];
  for(long i = 0; i < insts.count; i++)
  {
    Instance *inst = insts[i];
    if( [inst.object_type isEqualToString:@"ITEM"] )
    {
      Item *item = [_MODEL_ITEMS_ itemForId:inst.object_id];
      currentWeight += item.weight * inst.qty;
    }
  }
}

- (long) dropItemFromPlayer:(long)item_id qtyToRemove:(long)qty
{
  Instance *pII = playerInstances[[NSNumber numberWithLong:item_id]];
  if(!pII) return 0; //UH OH! NO INSTANCE TO TAKE ITEM FROM! (shouldn't happen if touchItemsForPlayer was called...)
  if(pII.qty < qty) qty = pII.qty;

  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ dropItem:(long)item_id qty:(long)qty];
  return [self takeItemFromPlayer:item_id qtyToRemove:qty];
}

- (long) takeItemFromPlayer:(long)item_id qtyToRemove:(long)qty
{
  Instance *pII = playerInstances[[NSNumber numberWithLong:item_id]];
  if(!pII) return 0; //UH OH! NO INSTANCE TO TAKE ITEM FROM! (shouldn't happen if touchItemsForPlayer was called...)
  if(pII.qty < qty) qty = pII.qty;

  return [self setItemsForPlayer:item_id qtyToSet:pII.qty-qty];
}

- (long) giveItemToPlayer:(long)item_id qtyToAdd:(long)qty
{
  Instance *pII = playerInstances[[NSNumber numberWithLong:item_id]];
  if(!pII) return 0; //UH OH! NO INSTANCE TO GIVE ITEM TO! (shouldn't happen if touchItemsForPlayer was called...)
  if(qty > [self qtyAllowedToGiveForItem:item_id]) qty = [self qtyAllowedToGiveForItem:item_id];

  return [self setItemsForPlayer:item_id qtyToSet:pII.qty+qty];
}

- (long) setItemsForPlayer:(long)item_id qtyToSet:(long)qty
{
  Instance *pII = playerInstances[[NSNumber numberWithLong:item_id]];
  if(!pII) return 0; //UH OH! NO INSTANCE TO GIVE ITEM TO! (shouldn't happen if touchItemsForPlayer was called...)

  if(qty < 0) qty = 0;
  if(qty-pII.qty > [self qtyAllowedToGiveForItem:item_id]) qty = pII.qty+[self qtyAllowedToGiveForItem:item_id];

  long oldQty = pII.qty;
  [_MODEL_INSTANCES_ setQtyForInstanceId:pII.instance_id qty:qty];
  if(qty > oldQty) [_MODEL_LOGS_ playerReceivedItemId:item_id qty:qty];
  if(qty < oldQty) [_MODEL_LOGS_ playerLostItemId:item_id qty:qty];

  return qty;
}

- (long) qtyOwnedForItem:(long)item_id
{
  return ((Instance *)playerInstances[[NSNumber numberWithLong:item_id]]).qty;
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
  [self calculateWeight];

  Item *i = [_MODEL_ITEMS_ itemForId:item_id];
  long amtMoreCanHold = i.max_qty_in_inventory-[self qtyOwnedForItem:item_id];
  while(_MODEL_GAME_.inventory_weight_cap > 0 &&
        (amtMoreCanHold*i.weight + currentWeight) > _MODEL_GAME_.inventory_weight_cap)
    amtMoreCanHold--;

  return amtMoreCanHold;
}

- (NSArray *) inventory
{
  if(inventory) return inventory;

  inventory = [[NSMutableArray alloc] init];
  NSArray *instancearray = [playerInstances allValues];
  for(long i = 0; i < instancearray.count; i++)
  {
    Item *item = ((Item *)((Instance *)[instancearray objectAtIndex:i]).object);
    if([item.type isEqualToString:@"NORMAL"] || [item.type isEqualToString:@"URL"])
      [inventory addObject:[instancearray objectAtIndex:i]];
  }
  return inventory;
}

- (NSArray *) attributes
{
  if(attributes) return attributes;

  attributes = [[NSMutableArray alloc] init];
  NSArray *instancearray = [playerInstances allValues];
  for(long i = 0; i < instancearray.count; i++)
  {
    if([((Item *)((Instance *)[instancearray objectAtIndex:i]).object).type isEqualToString:@"ATTRIB"])
      [attributes addObject:[instancearray objectAtIndex:i]];
  }
  return attributes;
}

- (NSString *) serializedName
{
  return @"player_instances";
}

- (NSString *) serializeModel
{
  NSArray *instances_a = [playerInstances allValues];
  Instance *i_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"instances\":["];
  for(long i = 0; i < instances_a.count; i++)
  {
    i_o = instances_a[i];
    [r appendString:[i_o serialize]];
    if(i != instances_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeModel:(NSString *)data
{

}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

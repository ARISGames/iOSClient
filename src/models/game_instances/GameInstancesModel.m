//
//  GameInstancesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "GameInstancesModel.h"
#import "AppServices.h"
#import "AppModel.h"

@interface GameInstancesModel()
{
  NSMutableDictionary *instances;
  NSMutableArray *gameOwnedInstances;
  long game_info_recvd;
}

@end

@implementation GameInstancesModel

@synthesize currentWeight;

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
        _ARIS_NOTIF_LISTEN_(@"SERVICES_GAME_INSTANCES_TOUCHED",self,@selector(gameInstancesTouched:),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_INSTANCES_PLAYER_AVAILABLE",self,@selector(gameInstancesAvailable),nil);
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
  gameOwnedInstances = nil;
}

- (void) clearGameData
{
    [self clearPlayerData];
    game_info_recvd = 0;
}

- (BOOL) gameInfoRecvd
{
  return game_info_recvd >= 1;
}

- (void) gameInstancesTouched:(NSNotification *)notif
{
    game_info_recvd++;
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_INSTANCES_TOUCHED",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) touchGameInstances
{
    [_SERVICES_ touchItemsForGame];
}

- (void) gameInstancesAvailable
{
    NSArray *newInstances = [_MODEL_INSTANCES_ gameOwnedInstances];
    [self clearPlayerData];

    Instance *newInstance;
    for(long i = 0; i < newInstances.count; i++)
    {
        newInstance = newInstances[i];
        if(![newInstance.object_type isEqualToString:@"ITEM"] || ![newInstance.owner_type isEqualToString:@"GAME"]) continue;

        instances[[NSNumber numberWithLong:newInstance.object_id]] = newInstance;
    }
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_INSTANCES_AVAILABLE",nil,nil);
}

- (long) dropItemFromGame:(long)item_id qtyToRemove:(long)qty
{
    Instance *gII = instances[[NSNumber numberWithLong:item_id]];
    if(!gII) return 0; //UH OH! NO INSTANCE TO TAKE ITEM FROM! (shouldn't happen if touchItemsForGame was called...)
    if(gII.qty < qty) qty = gII.qty;

    [_SERVICES_ dropItem:(long)item_id qty:(long)qty];
    return [self takeItemFromGame:item_id qtyToRemove:qty];
}

- (long) takeItemFromGame:(long)item_id qtyToRemove:(long)qty
{
  Instance *gII = instances[[NSNumber numberWithLong:item_id]];
  if(!gII) return 0; //UH OH! NO INSTANCE TO TAKE ITEM FROM! (shouldn't happen if touchItemsForGame was called...)
  if(gII.qty < qty) qty = gII.qty;

  return [self setItemsForGame:item_id qtyToSet:gII.qty-qty];
}

- (long) giveItemToGame:(long)item_id qtyToAdd:(long)qty
{
  Instance *gII = instances[[NSNumber numberWithLong:item_id]];
  if(!gII) return 0; //UH OH! NO INSTANCE TO GIVE ITEM TO! (shouldn't happen if touchItemsForGame was called...)
  if(qty > [self qtyAllowedToGiveForItem:item_id]) qty = [self qtyAllowedToGiveForItem:item_id];

  return [self setItemsForGame:item_id qtyToSet:gII.qty+qty];
}

- (long) setItemsForGame:(long)item_id qtyToSet:(long)qty
{
  Instance *gII = instances[[NSNumber numberWithLong:item_id]];
  if(!gII) return 0; //UH OH! NO INSTANCE TO GIVE ITEM TO! (shouldn't happen if touchItemsForGame was called...)

  if(qty < 0) qty = 0;
  if(qty-gII.qty > [self qtyAllowedToGiveForItem:item_id]) qty = gII.qty+[self qtyAllowedToGiveForItem:item_id];

  long oldQty = gII.qty;
  [_MODEL_INSTANCES_ setQtyForInstanceId:gII.instance_id qty:qty];
  if(qty > oldQty) [_MODEL_LOGS_ gameReceivedItemId:item_id qty:qty];
  if(qty < oldQty) [_MODEL_LOGS_ gameLostItemId:item_id qty:qty];

  return qty;
}

- (long) qtyOwnedForItem:(long)item_id
{
    return ((Instance *)instances[[NSNumber numberWithLong:item_id]]).qty;
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
- (NSArray *) gameOwnedInstances
{
  if(gameOwnedInstances) return gameOwnedInstances;

  gameOwnedInstances = [[NSMutableArray alloc] init];
  NSArray *instancearray = [instances allValues];
  for(long i = 0; i < instancearray.count; i++)
    [gameOwnedInstances addObject:[instancearray objectAtIndex:i]];
  return gameOwnedInstances;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

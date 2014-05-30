//
//  ItemsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c, 
// we can't know what data we're invalidating by replacing a ptr

#import "ItemsModel.h"
#import "AppServices.h"
#import "AppModel.h"

@interface ItemsModel()
{
    NSMutableDictionary *items;
    NSMutableDictionary *playerItemInstances;

    NSMutableArray *inventory;
    NSMutableArray *attributes;
}

@end

@implementation ItemsModel

@synthesize currentWeight;
@synthesize weightCap;

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
        _ARIS_NOTIF_LISTEN_(@"SERVICES_ITEMS_RECEIVED",self,@selector(itemsReceived:),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_INSTANCES_AVAILABLE",self,@selector(playerInstancesAvailable),nil);
    }
    return self;
}

- (void) clearPlayerData
{
    playerItemInstances = [[NSMutableDictionary alloc] init];
    currentWeight = 0;
}

- (void) clearGameData
{
    [self clearPlayerData];
    items = [[NSMutableDictionary alloc] init];
    weightCap = 0;
}

- (void) itemsReceived:(NSNotification *)notif
{
    [self updateItems:[notif.userInfo objectForKey:@"items"]];
}

- (void) updateItems:(NSArray *)newItems
{
    Item *newItem;
    NSNumber *newItemId;
    for(int i = 0; i < newItems.count; i++)
    {
      newItem = [newItems objectAtIndex:i];
      newItemId = [NSNumber numberWithInt:newItem.item_id];
      if(![items objectForKey:newItemId]) [items setObject:newItem forKey:newItemId];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_ITEMS_AVAILABLE",nil,nil);   
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_RECEIVED",nil,nil);      
}

- (void) requestItems
{
    [_SERVICES_ fetchItems]; 
}

- (void) playerInstancesAvailable
{
    NSArray *newInstances = [_MODEL_INSTANCES_ playerInstances];
    [playerItemInstances removeAllObjects];
    
    Instance *newInstance;
    for(int i = 0; i < newInstances.count; i++)
    {
        newInstances = newInstances[i];
        if(![newInstance.object_type isEqualToString:@"ITEM"] || newInstance.owner_id != _MODEL_PLAYER_.user_id) continue;
        
        playerItemInstances[[NSNumber numberWithInt:newInstance.object_id]] = newInstance;
    }
}

- (int) takeItemFromPlayer:(int)item_id qtyToRemove:(int)qty
{
  Instance *pII = playerItemInstances[[NSNumber numberWithInt:item_id]];
  if(!pII) return 0;
  if(pII.qty < qty) qty = pII.qty;
    
  pII.qty -= qty;
  return qty;
  //DONT FORGET TO UPDATE SERVER!!!
}

- (int) giveItemToPlayer:(int)item_id qtyToAdd:(int)qty
{
  Instance *pII = playerItemInstances[[NSNumber numberWithInt:item_id]];
  if(!pII) return 0; //UH OH! NEED TO CREATE INSTANCE TO GIVE ITEM TO!
  if(qty > [self qtyAllowedToGiveForItem:item_id]) qty = [self qtyAllowedToGiveForItem:item_id];
    
  pII.qty += qty;
  return qty;
  //DONT FORGET TO UPDATE SERVER!!! 
}

- (int) setItemsForPlayer:(int)item_id qtyToSet:(int)qty
{
  Instance *pII = playerItemInstances[[NSNumber numberWithInt:item_id]];
  if(!pII) return 0; //UH OH! NEED TO CREATE INSTANCE TO GIVE ITEM TO!
  if(qty < 0) qty = 0;
  if(qty-pII.qty > [self qtyAllowedToGiveForItem:item_id]) qty = [self qtyAllowedToGiveForItem:item_id];
    
  pII.qty += qty;
  return qty;
  //DONT FORGET TO UPDATE SERVER!!!  
}

- (Item *) itemForId:(int)item_id
{
  return [items objectForKey:[NSNumber numberWithInt:item_id]];
}

- (int) qtyOwnedForItem:(int)item_id
{
    return ((Instance *)playerItemInstances[[NSNumber numberWithInt:item_id]]).qty;
}

- (int) qtyAllowedToGiveForItem:(int)item_id
{
    Item *i = [self itemForId:item_id]; 
    int amtMoreCanHold = i.max_qty_in_inventory-[self qtyOwnedForItem:item_id];
    while(weightCap != 0 && 
          (amtMoreCanHold*i.weight + currentWeight) > weightCap)
        amtMoreCanHold--; 
    
    return amtMoreCanHold;
}

- (NSArray *) inventory
{
  if(inventory) return inventory;

  inventory = [[NSMutableArray alloc] init];
  NSArray *instancearray = [playerItemInstances allValues];
  for(int i = 0; i < instancearray.count; i++)
  {
      if([((Item *)((Instance *)[instancearray objectAtIndex:i]).object).type isEqualToString:@"NORMAL"]) 
      [inventory addObject:[instancearray objectAtIndex:i]];
  }
  return inventory;
}

- (NSArray *) attributes
{
  if(attributes) return attributes;

  attributes = [[NSMutableArray alloc] init];
  NSArray *instancearray = [playerItemInstances allValues];
  for(int i = 0; i < instancearray.count; i++)
  {
      if([((Item *)((Instance *)[instancearray objectAtIndex:i]).object).type isEqualToString:@"ATTRIBUTE"]) 
          [attributes addObject:[instancearray objectAtIndex:i]]; 
  }
  return attributes;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);               
}

@end

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

@interface ItemsModel()
{
    NSMutableDictionary *items;
    NSMutableDictionary *instances;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameItemsReceived:)       name:@"GameItemsReceived"       object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerInstancesReceived:) name:@"PlayerInstancesReceived" object:nil];
    }
    return self;
}

- (void) clearPlayerData
{
    instances = [[NSMutableDictionary alloc] init];
    currentWeight = 0;
}

- (void) clearGameData
{
    [self clearPlayerData];
    items = [[NSMutableDictionary alloc] init];
    weightCap = 0;
}

- (void) gameItemsReceived:(NSNotification *)notif
{
    [self updateItems:[notif.userInfo objectForKey:@"items"]];
}

- (void) updateItems:(NSArray *)newItems
{
    Item *newItem;
    NSNumber *newItemId;
    for(int i = 0; i < [newItems count]; i++)
    {
      newItem = [newItems objectAtIndex:i];
      newItemId = [NSNumber numberWithInt:newItem.item_id];
      if(![items objectForKey:newItemId]) [items setObject:newItem forKey:newItemId];
    }
}

- (void) playerInstancesReceived:(NSNotification *)notification
{
    [self updateInstances:[notification.userInfo objectForKey:@"instances"]];
}

- (void) updateInstances:(NSArray *)newInstances
{
    //Invalidate caches
    attributes = nil;
    inventory = nil;

    NSMutableArray *itemDeltas = [[NSMutableArray alloc] init];

    Instance *newInstance;
    Item *item;
    NSNumber *item_id;
    Instance *oldInstance;
    for(int i = 0; i < [newInstances count]; i++)
    {
        newInstance = [newInstances objectAtIndex:i];
        item = newInstance.object;
        item_id = [NSNumber numberWithInt:item.item_id];
        oldInstance = [instances objectForKey:item_id];
        int delta = 0;
        if(oldInstance)
        {
          delta = newInstance.qty - oldInstance.qty;
          oldInstance.qty = newInstance.qty;
        }
        else
        {
          delta = newInstance.qty;
          [instances setObject:newInstance forKey:item_id];
        }

        if(delta != 0) [itemDeltas addObject:@{item_id:[NSNumber numberWithInt:delta]}];
    }

    /*
    self.currentWeight = 0;
    for (Instance *instance in instances)
        self.currentWeight += instance.weight*instance.qty;
     */

    if([itemDeltas count] > 0)
    {
        _ARIS_NOTIF_SEND_(@"NewInstancesAvailable",self,@{@"deltas":itemDeltas});
    }
}

- (int) takeItemFromPlayer:(int)item_id qtyToRemove:(int)qty
{
  //Generate fake newly parsed instances *NOTE- fake instances must be COPIES, not just pointers to old instances (lest we just change qty in-place)*
  NSArray *instancesArray = [instances allValues];
  NSMutableArray *instancesCopy = [[NSMutableArray alloc] init];
  Item *item = [self itemForId:item_id]; 
  Instance *copy;
  for(int i = 0; i < [instancesArray count]; i++)
  {
    copy = [[instancesArray objectAtIndex:i] copy];
    //alter qty of fake
    if(copy.object == item) copy.qty -= qty;
    if(copy.qty < 0) copy.qty = 0;
    [instancesCopy addObject:copy];
  }
  [self updateInstances:instancesCopy];
}

- (int) giveItemToPlayer:(int)item_id qtyToAdd:(int)qty
{
  //Generate fake newly parsed instances *NOTE- fake instances must be COPIES, not just pointers to old instances (lest we just change qty in-place)*
  NSArray *instancesArray = [instances allValues];
  NSMutableArray *instancesCopy = [[NSMutableArray alloc] init];
  Item *item = [self itemForId:item_id];
  Instance *copy;
  for(int i = 0; i < [instancesArray count]; i++)
  {
    copy = [[instancesArray objectAtIndex:i] copy];
    //alter qty of fake
    if(copy.object == item) copy.qty += qty;
    if(copy.qty > item.max_qty_in_inventory) copy.qty = item.max_qty_in_inventory;
    [instancesCopy addObject:copy];
  }
  [self updateInstances:instancesCopy];
}

- (int) setItemsForPlayer:(int)item_id qtyToSet:(int)qty
{
  //Generate fake newly parsed instances *NOTE- fake instances must be COPIES, not just pointers to old instances (lest we just change qty in-place)*
  NSArray *instancesArray = [instances allValues];
  NSMutableArray *instancesCopy = [[NSMutableArray alloc] init];
  Item *item = [self itemForId:item_id]; 
  Instance *copy;
  for(int i = 0; i < [instancesArray count]; i++)
  {
    copy = [[instancesArray objectAtIndex:i] copy];
    //alter qty of fake
    if(copy.object == item) copy.qty = qty;
    [instancesCopy addObject:copy];
  }
  [self updateInstances:instancesCopy]; 
}

- (Item *) itemForId:(int)item_id
{
  return [items objectForKey:[NSNumber numberWithInt:item_id]];
}

- (int) qtyOwnedForItem:(int)item_id
{
    Item *i = [self itemForId:item_id];
    return ((Instance *)[instances objectForKey:[NSNumber numberWithInt:i.item_id]]).qty;
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
  NSArray *instancearray = [instances allValues];
  for(int i = 0; i < [instancearray count]; i++)
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
  NSArray *instancearray = [instances allValues];
  for(int i = 0; i < [instancearray count]; i++)
  {
      if([((Item *)((Instance *)[instancearray objectAtIndex:i]).object).type isEqualToString:@"ATTRIBUTE"]) 
          [attributes addObject:[instancearray objectAtIndex:i]]; 
  }
  return attributes;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

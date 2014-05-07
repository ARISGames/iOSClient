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
    self.items = [[NSMutableDictionary alloc] init];
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
      newItemId = [NSNumber numberWithInt:newItem.item_id]
      if(![self.items objectForKey:newItemId]) [self.items addObject:newItem forKey:newItemId];
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
          [instances addObject:newInstance forKey:item_id];
        }

        if(delta != 0) [itemDeltas addObject:@{item_id:[NSNumber numberWithInt:delta]}];
    }

    self.currentWeight = 0;
    for (Item *item in instances)
        self.currentWeight += item.weight*item.qty;

    if([deltas count] > 0)
    {
        NSLog(@"NSNotification: NewInstancesAvailable");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewInstancesAvailable" object:self userInfo:@{@"deltas":deltas}]];
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
  return [instances objectForKey:[NSNumber numberWithInt:item.item_id]].qty;
}

- (NSArray *) inventory
{
  if(inventory) return inventory;

  inventory = [[NSMutableArray alloc] init];
  for(int i = 0; i < [instances count]; i++)
  {
    if([((Item *)[instances objectAtIndex:i].object).type isEqualToString:@"NORMAL"])
      [inventory addObject:[instances objectAtIndex:i]];
  }
  return inventory;
}

- (NSArray *) attributes
{
  if(attributes) return attributes;

  attributes = [[NSMutableArray alloc] init];
  for(int i = 0; i < [instances count]; i++)
  {
    if([((Item *)[instances objectAtIndex:i].object).type isEqualToString:@"NORMAL"])
      [attributes addObject:[instances objectAtIndex:i]];
  }
  return attributes;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

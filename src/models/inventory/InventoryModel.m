//
//  InventoryModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import "InventoryModel.h"

@implementation InventoryModel

@synthesize currentInventory;
@synthesize currentWeight;
@synthesize weightCap;

-(id)init
{
    self = [super init];
    if(self)
    {
        [self clearData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestPlayerInventoryReceived:) name:@"LatestPlayerInventoryReceived" object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)clearData
{
    [self updateInventory:[[NSArray alloc] init]];
    currentWeight = 0;
    weightCap = 0;
}

-(void)latestPlayerInventoryReceived:(NSNotification *)notification
{
    [self updateInventory:[notification.userInfo objectForKey:@"inventory"]];
}

-(void)updateInventory:(NSArray *)inventory
{
    NSMutableArray *newlyAcquiredItems = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *newlyLostItems     = [[NSMutableArray alloc] initWithCapacity:5];
    NSDictionary   *itemDeltaDict; //{"item":item,"delta":delta}

    //Gained Items
    for(Item *newItem in inventory)
    {
        BOOL match = NO;
        int delta = 0;
        for (Item *existingItem in self.currentInventory)
        {
            if (newItem.itemId == existingItem.itemId)
            {
                match = YES;
                delta = newItem.qty - existingItem.qty;
            }
        }
        
        if(delta > 0) //Delta < 0 will be taken care of in next set of loops
        {
            itemDeltaDict = [[NSDictionary alloc] initWithObjectsAndKeys:newItem,@"item",[NSNumber numberWithInt:delta],@"delta", nil];
            [newlyAcquiredItems addObject:itemDeltaDict];
        }
        else if(!match) //Totally new item
        { 
            itemDeltaDict = [[NSDictionary alloc] initWithObjectsAndKeys:newItem,@"item",[NSNumber numberWithInt:newItem.qty],@"delta", nil];
            [newlyAcquiredItems addObject:itemDeltaDict];
        }
    }
    
    //Lost Items
    for (Item *existingItem in self.currentInventory)
    {
        BOOL match = NO;
        int delta = 0;
        for (Item *newItem in inventory)
        {
            if (newItem.itemId == existingItem.itemId)
            {
                match = YES;
                delta = existingItem.qty - newItem.qty;
            }
        }
        
        if(delta > 0)
        {
            existingItem.qty -= delta;
            itemDeltaDict = [[NSDictionary alloc] initWithObjectsAndKeys:existingItem,@"item",[NSNumber numberWithInt:delta],@"delta", nil];
            [newlyLostItems addObject:itemDeltaDict];
        }
        else if(!match) //Totally lost item
        {
            delta = existingItem.qty;
            existingItem.qty = 0;
            itemDeltaDict = [[NSDictionary alloc] initWithObjectsAndKeys:existingItem,@"item",[NSNumber numberWithInt:delta],@"delta", nil];
            [newlyLostItems addObject:itemDeltaDict];
        }
    }
    
    self.currentWeight = 0;
    for (Item *item in inventory)
        self.currentWeight += item.weight*item.qty;
    
    self.currentInventory = inventory;
    
    if([newlyAcquiredItems count] > 0)
    {
        NSDictionary *iDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyAcquiredItems,@"newlyAcquiredItems",
                               inventory,@"allItems",
                               nil];
        NSLog(@"NSNotification: NewlyAcquiredItemsAvailable");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyAcquiredItemsAvailable" object:self userInfo:iDict]];
    }
    if([newlyLostItems count] > 0)
    {
        NSDictionary *iDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyLostItems,@"newlyLostItems",
                               inventory,@"allItems",
                               nil];
        NSLog(@"NSNotification: NewlyLostItemsAvailable");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyLostItemsAvailable" object:self userInfo:iDict]];
    }
}

-(int)removeItemFromInventory:(Item*)item qtyToRemove:(int)qty
{
	NSLog(@"InventoryModel: removing an item from the local inventory");
    NSMutableArray *newInventory = [[NSMutableArray alloc] initWithCapacity:[self.currentInventory count]];
    for(int i = 0; i < [self.currentInventory count]; i++)
        [newInventory addObject:[((Item *)[self.currentInventory objectAtIndex:i]) copy]];
        
    Item* tmpItem;
    for(int i = 0; i < [newInventory count]; i++)
    {
        tmpItem = (Item *)[newInventory objectAtIndex:i];
        if(tmpItem.itemId == item.itemId)
        {
            tmpItem.qty -= qty;
            if(tmpItem.qty < 1) [newInventory removeObjectAtIndex:i];
            
            [self updateInventory:newInventory];
            return (tmpItem.qty < 0) ? 0 : tmpItem.qty;
        }
    }
    return 0;
}

-(int)addItemToInventory:(Item*)item qtyToAdd:(int)qty
{
	NSLog(@"InventoryModel: removing an item from the local inventory");
    NSMutableArray *newInventory = [[NSMutableArray alloc] initWithCapacity:[self.currentInventory count]];
    for(int i = 0; i < [self.currentInventory count]; i++)
        [newInventory addObject:[((Item *)[self.currentInventory objectAtIndex:i]) copy]];
    
    Item* tmpItem;
    for(int i = 0; i < [newInventory count]; i++)
    {
        tmpItem = (Item *)[newInventory objectAtIndex:i];
        if(tmpItem.itemId == item.itemId)
        {
            tmpItem.qty += qty;
            if(tmpItem.qty > tmpItem.maxQty) tmpItem.qty = tmpItem.maxQty;
            
            [self updateInventory:newInventory];
            return tmpItem.qty;
        }
    }
    
    item.qty = qty;
    if(item.qty > item.maxQty) item.qty = item.maxQty;
    [newInventory addObject:item];
    [self updateInventory:newInventory];
    return item.qty;
}

-(Item *)inventoryItemForId:(int)itemId
{
    for(int i = 0; i < [currentInventory count]; i++)
        if(((Item *)[currentInventory objectAtIndex:i]).itemId == itemId) return [currentInventory objectAtIndex:i];
    return nil;
}

@end

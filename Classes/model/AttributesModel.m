//
//  AttributesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import "AttributesModel.h"

@implementation AttributesModel

@synthesize currentAttributes;

-(id)init
{
    self = [super init];
    if(self)
    {
        [self clearData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestPlayerAttributesReceived:) name:@"LatestPlayerAttributesReceived" object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)clearData
{
    [self updateAttributes:[[NSArray alloc] init]];
}

-(void)latestPlayerAttributesReceived:(NSNotification *)notification
{
    [self updateAttributes:[notification.userInfo objectForKey:@"attributes"]];
}

-(void)updateAttributes:(NSArray *)attributes
{    
    NSMutableArray *newlyAcquiredAttributes = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *newlyLostAttributes =     [[NSMutableArray alloc] initWithCapacity:5];
    NSDictionary *attributeDeltaDict; //Could just be a struct for speed, but whatever
    
    //Gained Attributes
    for (Item *newAttribute in attributes)
    {
        BOOL match = NO;
        int delta = 0;
        for (Item *existingAttribute in self.currentAttributes)
        {
            if (newAttribute.itemId == existingAttribute.itemId)
            {
                match = YES;
                delta = newAttribute.qty - existingAttribute.qty;
            }
        }
        
        if(delta > 0) //Delta < 0 will be taken care of in next set of loops
        {
            attributeDeltaDict = [[NSDictionary alloc] initWithObjectsAndKeys:newAttribute,@"attribute",[NSNumber numberWithInt:delta],@"delta", nil];
            [newlyAcquiredAttributes addObject:attributeDeltaDict];
        }
        else if(!match) //Totally new attribute
        {
            attributeDeltaDict = [[NSDictionary alloc] initWithObjectsAndKeys:newAttribute,@"attribute",[NSNumber numberWithInt:newAttribute.qty],@"delta", nil];
            [newlyAcquiredAttributes addObject:attributeDeltaDict];
        }
    }
    
    //Lost Attributes
    for (Item *existingAttribute in self.currentAttributes)
    {
        BOOL match = NO;
        int delta = 0;
        for (Item *newAttribute in attributes)
        {
            if (newAttribute.itemId == existingAttribute.itemId)
            {
                match = YES;
                delta = existingAttribute.qty - newAttribute.qty;
            }
        }
        
        if(delta > 0)
        {
            existingAttribute.qty -= delta;
            attributeDeltaDict = [[NSDictionary alloc] initWithObjectsAndKeys:existingAttribute,@"attribute",[NSNumber numberWithInt:delta],@"delta", nil];
            [newlyLostAttributes addObject:attributeDeltaDict];
        }
        else if(!match) //Totally lost attribute
        {
            delta = existingAttribute.qty;
            existingAttribute.qty = 0;
            attributeDeltaDict = [[NSDictionary alloc] initWithObjectsAndKeys:existingAttribute,@"attribute",[NSNumber numberWithInt:delta],@"delta", nil];
            [newlyLostAttributes addObject:attributeDeltaDict];
        }
    }
    
    self.currentAttributes = attributes;
    
    if([newlyAcquiredAttributes count] > 0)
    {
        NSDictionary *iDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyAcquiredAttributes,@"newlyAcquiredAttributes",
                               attributes,@"allAttributes",
                               nil];
        NSLog(@"NSNotification: NewlyAcquiredAttributesAvailable");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyAcquiredAttributesAvailable" object:self userInfo:iDict]];
    }
    if([newlyLostAttributes count] > 0)
    {
        NSDictionary *iDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyLostAttributes,@"newlyLostAttributes",
                               attributes,@"allAttributes",
                               nil];
        NSLog(@"NSNotification: NewlyLostAttributesAvailable");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyLostAttributesAvailable" object:self userInfo:iDict]];
    }
}

-(int)removeItemFromAttributes:(Item*)item qtyToRemove:(int)qty
{
	NSLog(@"AttributesModel: removing an item from the local attributes");
    NSMutableArray *newAttributes = [[NSMutableArray alloc] initWithCapacity:[self.currentAttributes count]];
    for(int i = 0; i < [self.currentAttributes count]; i++)
        [newAttributes addObject:[((Item *)[self.currentAttributes objectAtIndex:i]) copy]];

    Item* tmpItem;
    for(int i = 0; i < [newAttributes count]; i++)
    {
        tmpItem = (Item *)[newAttributes objectAtIndex:i];
        if(tmpItem.itemId == item.itemId)
        {
            tmpItem.qty -= qty;
            if(tmpItem.qty < 1) [newAttributes removeObjectAtIndex:i];
            
            [self updateAttributes:newAttributes];
            return (tmpItem.qty < 0) ? 0 : tmpItem.qty;
        }
    }
    return 0;
}

-(int)addItemToAttributes:(Item*)item qtyToAdd:(int)qty
{
	NSLog(@"AttributesModel: adding an item from the local attributes");
    NSMutableArray *newAttributes = [[NSMutableArray alloc] initWithCapacity:[self.currentAttributes count]];
    for(int i = 0; i < [self.currentAttributes count]; i++)
        [newAttributes addObject:[((Item *)[self.currentAttributes objectAtIndex:i]) copy]];
    
    Item* tmpItem;
    for(int i = 0; i < [newAttributes count]; i++)
    {
        tmpItem = (Item *)[newAttributes objectAtIndex:i];
        if(tmpItem.itemId == item.itemId)
        {
            tmpItem.qty += qty;
            if(tmpItem.qty > tmpItem.maxQty) tmpItem.qty = tmpItem.maxQty;
            
            [self updateAttributes:newAttributes];
            return tmpItem.qty;
        }
    }
    
    item.qty = qty;
    if(item.qty > item.maxQty) item.qty = item.maxQty;
    [newAttributes addObject:item];
    [self updateAttributes:newAttributes];
    return item.qty;
}

-(Item *)attributesItemForId:(int)itemId
{
    for(int i = 0; i < [currentAttributes count]; i++)
        if(((Item *)[currentAttributes objectAtIndex:i]).itemId == itemId) return [currentAttributes objectAtIndex:i];
    return nil;
}

@end

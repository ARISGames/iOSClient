//
//  Item.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Item.h"
#import "ItemViewController.h"
#import "NSDictionary+ValidParsers.h"

@implementation ItemTag
@synthesize name;
@synthesize media_id;
@end

@implementation Item

@synthesize itemId;
@synthesize name;
@synthesize idescription;
@synthesize itemType;
@synthesize mediaId;
@synthesize iconMediaId;
@synthesize qty;
@synthesize maxQty;
@synthesize infiniteQty;
@synthesize weight;
@synthesize dropable;
@synthesize destroyable;
@synthesize url;
@synthesize tags;

- (Item *) init
{
    if(self = [super init])
    {
        self.itemId = 0;
        self.name = NSLocalizedString(@"ItemKey", @"");
        self.idescription = NSLocalizedString(@"DescriptionKey", @"");
        self.itemType = ItemTypeNormal;
        self.mediaId = 0;
        self.iconMediaId = 0;
        self.qty = 0;
        self.infiniteQty = NO; 
        self.maxQty = 1;
        self.weight = 0;
        self.dropable = NO;
        self.destroyable = NO;
        self.url = @"";
        self.tags = [[NSMutableArray alloc] init];
    }
    return self;
}

- (Item *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.itemId       = [dict validIntForKey:@"item_id"];
        self.name         = [dict validObjectForKey:@"name"];
        self.idescription = [dict validObjectForKey:@"description"];
        if     ([[dict validStringForKey:@"type"] isEqualToString:@"NORMAL"]) self.itemType = ItemTypeNormal;
        else if([[dict validStringForKey:@"type"] isEqualToString:@"ATTRIB"]) self.itemType = ItemTypeAttribute;
        else if([[dict validStringForKey:@"type"] isEqualToString:@"URL"])    self.itemType = ItemTypeWebPage;
        self.mediaId      = [dict validIntForKey:@"media_id"];
        self.iconMediaId  = [dict validIntForKey:@"icon_media_id"];
        self.qty          = [dict validIntForKey:@"qty"];
        self.infiniteQty  = self.qty < 0;
        self.maxQty       = [dict validIntForKey:@"max_qty_in_inventory"];
        self.weight       = [dict validIntForKey:@"weight"];
        self.dropable     = [dict validBoolForKey:@"dropable"];
        self.destroyable  = [dict validBoolForKey:@"destroyable"];
        self.url          = [dict validObjectForKey:@"url"];
        self.tags = [[NSMutableArray alloc] initWithCapacity:10];
        NSArray *rawtags = [dict validObjectForKey:@"tags"];
        for(int i = 0; i < [rawtags count]; i++)
        {
            ItemTag *t = [[ItemTag alloc] init];
            t.name = [((NSDictionary *)[rawtags objectAtIndex:i]) validStringForKey:@"tag"];
            t.media_id = [((NSDictionary *)[rawtags objectAtIndex:i]) validIntForKey:@"media_id"];
            [self.tags addObject:t];
        }
    }
    return self;
}

- (GameObjectType) type
{
    return GameObjectItem;
}

- (ItemViewController *) viewControllerForDelegate:(NSObject<GameObjectViewControllerDelegate,StateControllerProtocol> *)d fromSource:(id<ItemViewControllerSource>)s
{
    if(self.qty == 0) self.qty = 1;
	return [[ItemViewController alloc] initWithItem:self delegate:d source:s];
}

- (Item *) copy
{
    Item *c = [[Item alloc] init];
    c.itemId = self.itemId;
    c.name = self.name;
    c.idescription = self.idescription;
    c.itemType = self.itemType;
    c.mediaId = self.mediaId;
    c.iconMediaId = self.iconMediaId;
    c.qty = self.qty;
    c.infiniteQty = self.infiniteQty; 
    c.maxQty = self.maxQty;
    c.weight = self.weight;
    c.dropable = self.dropable;
    c.destroyable = self.destroyable;
    c.url = self.url;
    c.tags = self.tags;
    return c;
}

- (int) compareTo:(Item *)ob
{
	return (ob.itemId == self.itemId);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Item- Id:%d\tName:%@\tType:%u\tQty:%d",self.itemId,self.name,self.itemType,self.qty];
}

@end

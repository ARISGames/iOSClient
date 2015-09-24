//
//  Item.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Item.h"
#import "Media.h"
#import "NSDictionary+ValidParsers.h"

@implementation Item

@synthesize item_id;
@synthesize name;
@synthesize desc;
@synthesize icon_media_id;
@synthesize media_id;
@synthesize droppable;
@synthesize destroyable;
@synthesize max_qty_in_inventory;
@synthesize weight;
@synthesize url;
@synthesize type;
@synthesize delta_notification;

- (id) init
{
    if(self = [super init])
    {
        self.item_id = 0;
        self.name = @"Item";
        self.desc = @"";
        self.icon_media_id = 0;
        self.media_id = 0;
        self.droppable = NO;
        self.destroyable = NO;
        self.max_qty_in_inventory = 99999999;
        self.weight = 0;
        self.url = @"";
        self.type = @"NORMAL";
        self.delta_notification = 1;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.item_id              = [dict validIntForKey:@"item_id"];
    self.name                 = [dict validStringForKey:@"name"];
    self.desc                 = [dict validStringForKey:@"description"];
    self.icon_media_id        = [dict validIntForKey:@"icon_media_id"];
    self.media_id             = [dict validIntForKey:@"media_id"];
    self.droppable            = [dict validBoolForKey:@"droppable"];
    self.destroyable          = [dict validBoolForKey:@"destroyable"];
    self.max_qty_in_inventory = [dict validIntForKey:@"max_qty_in_inventory"];
    if(self.max_qty_in_inventory < 0) self.max_qty_in_inventory = 999999; //poor man's infinity
    self.weight               = [dict validIntForKey:@"weight"];
    self.url                  = [dict validStringForKey:@"url"];
    self.type                 = [dict validStringForKey:@"type"];
    self.delta_notification   = [dict validBoolForKey:@"delta_notification"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:[NSString stringWithFormat:@"%ld",self.item_id]];
  [r appendString:self.name];
  [r appendString:self.desc];
  [r appendString:[NSString stringWithFormat:@"%ld",self.icon_media_id]];
  [r appendString:[NSString stringWithFormat:@"%ld",self.media_id]];
  [r appendString:[NSString stringWithFormat:@"%d",self.droppable]];
  [r appendString:[NSString stringWithFormat:@"%d",self.destroyable]];
  [r appendString:[NSString stringWithFormat:@"%ld",self.max_qty_in_inventory]];
  [r appendString:[NSString stringWithFormat:@"%ld",self.weight]];
  [r appendString:self.url];
  [r appendString:self.type];
  [r appendString:[NSString stringWithFormat:@"%d",self.delta_notification]];
  return r;
}

- (Item *) copy
{
  Item *c = [[Item alloc] init];

  c.item_id              = self.item_id;
  c.name                 = self.name;
  c.desc                 = self.desc;
  c.icon_media_id        = self.icon_media_id;
  c.media_id             = self.media_id;
  c.droppable            = self.droppable;
  c.destroyable          = self.destroyable;
  c.max_qty_in_inventory = self.max_qty_in_inventory;
  c.weight               = self.weight;
  c.url                  = self.url;
  c.type                 = self.type;
  c.delta_notification   = self.delta_notification;

  return c;
}

- (long) icon_media_id
{
    if(!icon_media_id) return DEFAULT_ITEM_ICON_MEDIA_ID;
    return icon_media_id;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Item- Id:%ld\tName:%@\tType:%@",self.item_id,self.name,self.type];
}

@end


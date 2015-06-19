//
//  Event.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "NSDictionary+ValidParsers.h"

@implementation Event

@synthesize event_id;
@synthesize event_package_id;
@synthesize event;
@synthesize content_id;
@synthesize qty;
@synthesize script;

- (id) init
{
  if(self = [super init])
  {
    self.event_id = 0;
    self.event_package_id = 0;
    self.event = @"GIVE_ITEM_PLAYER";
    self.content_id = 0;
    self.qty = 0;
    self.script = @"";
  }
  return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.event_id         = [dict validIntForKey:@"event_id"];
    self.event_package_id = [dict validIntForKey:@"event_package_id"];
    self.event            = [dict validStringForKey:@"event"];
    self.content_id       = [dict validIntForKey:@"content_id"];
    self.qty              = [dict validIntForKey:@"qty"];
    self.script           = [dict validStringForKey:@"script"];
  }
  return self;
}

- (id) copy
{
  Event *o = [[Event alloc] init];
  o.event_id = self.event_id;
  o.event_package_id = self.event_package_id;
  o.event = self.event;
  o.content_id = self.content_id;
  o.qty = self.qty;
  o.script = self.script;
  return o;
}

- (long) compareTo:(Event *)ob
{
  return (ob.event_id == self.event_id);
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"Event- Id:%ld\tevent:%@",self.event_id,self.event];
}

@end

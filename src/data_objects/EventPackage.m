//
//  EventPackage.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventPackage.h"
#import "NSDictionary+ValidParsers.h"

@implementation EventPackage

@synthesize event_package_id;

- (id) init
{
  if(self = [super init])
  {
    self.event_package_id = 0;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.event_package_id = [dict validIntForKey:@"event_package_id"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:[NSString stringWithFormat:@"%ld",self.event_package_id]];
  return r;
}

- (id) copy
{
  EventPackage *o = [[EventPackage alloc] init];
  o.event_package_id = self.event_package_id;
  return o;
}

- (long) compareTo:(EventPackage *)ob
{
  return (ob.event_package_id == self.event_package_id);
}

- (NSString *) name
{
  return @"Event";
}

- (long) icon_media_id
{
  return 0;
}

- (NSString *) description
{
  return [NSString stringWithFormat:@"EventPackage- Id:%ld",self.event_package_id];
}

@end


//
//  Log.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Log.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation Log

@synthesize log_id;
@synthesize event_type;
@synthesize content_id;
@synthesize qty;
@synthesize location;

- (id) init
{
  if(self = [super init])
  {
    self.log_id = 0;
    self.event_type = @"MOVE";
    self.content_id = 0;
    self.qty = 0;
    self.location = nil;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.log_id = [dict validIntForKey:@"user_log_id"];
    self.event_type = [dict validStringForKey:@"event_type"];
    self.content_id = [dict validIntForKey:@"content_id"];
    self.qty = [dict validIntForKey:@"qty"];
    self.location = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"latitude"] longitude:[dict validDoubleForKey:@"longitude"]];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.log_id] forKey:@"log_id"];
  [d setObject:self.event_type forKey:@"event_type"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.content_id] forKey:@"content_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.qty] forKey:@"qty"];
  [d setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.latitude] forKey:@"latitude"];
  [d setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.longitude] forKey:@"longitude"];
  return [NSString JSONFromFlatStringDict:d];
}

@end


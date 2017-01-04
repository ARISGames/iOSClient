//
//  ARTarget.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ARTarget.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation ARTarget

@synthesize ar_target_id;
@synthesize name;
@synthesize vuforia_index;

- (id) init
{
  if(self = [super init])
  {
    self.ar_target_id = 0;
    self.name = @"";
    self.vuforia_index = 0;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.ar_target_id = [dict validIntForKey:@"ar_target_id"];
    self.name = [dict validStringForKey:@"name"];
    self.vuforia_index = [dict validIntForKey:@"vuforia_index"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.ar_target_id] forKey:@"ar_target_id"];
  [d setObject:name forKey:@"name"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.vuforia_index] forKey:@"vuforia_index"];
  return [NSString JSONFromFlatStringDict:d];
}

@end

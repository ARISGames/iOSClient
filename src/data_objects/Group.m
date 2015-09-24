//
//  Group.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Group.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation Group

@synthesize group_id;
@synthesize name;

- (id) init
{
  if(self = [super init])
  {
    self.group_id = 0;
    self.name = @"";
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.group_id = [dict validIntForKey:@"group_id"];
    self.name = [dict validStringForKey:@"name"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.group_id] forKey:@"group_id"];
  [d setObject:self.name forKey:@"name"];
  return [NSString JSONFromFlatStringDict:d];
}

//To comply w/ instantiable protocol. should get default image later.
- (long) icon_media_id
{
  return 0;
}

@end


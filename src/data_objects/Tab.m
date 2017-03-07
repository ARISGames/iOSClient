//
//  Tab.m
//  ARIS
//
//  Created by Brian Thiel on 8/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Tab.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation Tab

@synthesize tab_id;
@synthesize type;
@synthesize name;
@synthesize icon_media_id;
@synthesize content_id;
@synthesize info;
@synthesize sort_index;
@synthesize requirement_root_package_id;
@synthesize showNotesOnMap;

- (id) init
{
  if(self = [super init])
  {
    self.tab_id = 0;
    self.type = @"MAP";
    self.name = self.type;
    self.icon_media_id = 0;
    self.content_id = 0;
    self.info = @"";
    self.sort_index = 0;
    self.requirement_root_package_id = 0;
    self.showNotesOnMap = false;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.tab_id                      = [dict validIntForKey:@"tab_id"];
    self.type                        = [dict validStringForKey:@"type"];
    self.name                        = [dict validStringForKey:@"name"];
    self.icon_media_id               = [dict validIntForKey:@"icon_media_id"];
    self.content_id                  = [dict validIntForKey:@"content_id"];
    self.info                        = [dict validStringForKey:@"info"];
    self.sort_index                  = [dict validIntForKey:@"sort_index"];
    self.requirement_root_package_id = [dict validIntForKey:@"requirement_root_package_id"];
    self.showNotesOnMap              = false;
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.tab_id] forKey:@"tab_id"];
  [d setObject:self.type forKey:@"type"];
  [d setObject:self.name forKey:@"name"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.icon_media_id] forKey:@"icon_media_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.content_id] forKey:@"content_id"];
  [d setObject:self.info forKey:@"info"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.sort_index] forKey:@"sort_index"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.requirement_root_package_id] forKey:@"requirement_root_package_id"];
  return [NSString JSONFromFlatStringDict:d];
}

- (NSString *) keyString
{
    return [NSString stringWithFormat:@"%ld%@%@%ld",self.tab_id,self.type,self.name,self.content_id];
}

@end


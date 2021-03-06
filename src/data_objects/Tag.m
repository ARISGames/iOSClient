//
//  Tag.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation Tag

@synthesize tag_id;
@synthesize tag;
@synthesize media_id;
@synthesize visible;
@synthesize curated;
@synthesize sort_index;

- (id) init
{
  if(self = [super init])
  {
    self.tag_id = 0;
    self.tag = @"Tag";
    self.media_id = 0;
    self.visible = 1;
    self.curated = 1;
    self.sort_index = 0;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.tag_id         = [dict validIntForKey:@"tag_id"];
    self.tag            = [dict validStringForKey:@"tag"];
    self.media_id       = [dict validIntForKey:@"media_id"];
    self.visible        = [dict validIntForKey:@"visible"];
    self.curated        = [dict validIntForKey:@"curated"];
    self.sort_index     = [dict validIntForKey:@"sort_index"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.tag_id] forKey:@"tag_id"];
  [d setObject:self.tag forKey:@"tag"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.media_id] forKey:@"media_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.visible] forKey:@"visible"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.curated] forKey:@"curated"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.sort_index] forKey:@"sort_index"];
  return [NSString JSONFromFlatStringDict:d];
}

- (id) copy
{
  Tag *w = [[Tag alloc] init];
  w.tag_id = self.tag_id;
  w.tag = self.tag;
  w.media_id = self.media_id;
  w.visible = self.visible;
  w.curated = self.curated;
  w.sort_index = self.sort_index;
  return w;
}

- (long) compareTo:(Tag *)ob
{
  return (ob.tag_id == self.tag_id);
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"Tag- Id:%ld\ttag:%@",self.tag_id,self.tag];
}

@end


//
//  Plaque.m
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Plaque.h"
#import "Media.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation Plaque

@synthesize plaque_id;
@synthesize name;
@synthesize desc;
@synthesize icon_media_id;
@synthesize media_id;
@synthesize event_package_id;
@synthesize back_button_enabled;
@synthesize continue_function;

- (id) init
{
    if(self = [super init])
    {
        self.plaque_id = 0;
        self.name = @"Plaque";
        self.desc = @"Text";
        self.icon_media_id = 0;
        self.media_id = 0;
        self.event_package_id = 0;
        self.back_button_enabled = YES;
        self.continue_function = @"EXIT";
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.plaque_id           = [dict validIntForKey:@"plaque_id"];
    self.name                = [dict validStringForKey:@"name"];
    self.desc                = [dict validStringForKey:@"description"];
    self.media_id            = [dict validIntForKey:@"media_id"];
    self.icon_media_id       = [dict validIntForKey:@"icon_media_id"];
    self.event_package_id    = [dict validIntForKey:@"event_package_id"];
    self.back_button_enabled = [dict validBoolForKey:@"back_button_enabled"];
    self.continue_function   = [dict validStringForKey:@"continue_function"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.plaque_id] forKey:@"plaque_id"];
  [d setObject:self.name forKey:@"name"];
  [d setObject:self.desc forKey:@"desc"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.media_id] forKey:@"media_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.icon_media_id] forKey:@"icon_media_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.event_package_id] forKey:@"event_package_id"];
  [d setObject:[NSString stringWithFormat:@"%d",self.back_button_enabled] forKey:@"back_button_enabled"];
  [d setObject:self.continue_function forKey:@"continue_function"];
  return [NSString JSONFromFlatStringDict:d];
}

- (long) icon_media_id
{
  if(!icon_media_id) return DEFAULT_PLAQUE_ICON_MEDIA_ID;
  return icon_media_id;
}

- (NSString *) description
{
  return [NSString stringWithFormat:@"Plaque- Id:%ld\tName:%@\tDesc:%@\t",self.plaque_id,self.name,self.desc];
}

@end


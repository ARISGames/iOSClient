//
//  Dialog.m
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Dialog.h"
#import "Media.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation Dialog

@synthesize dialog_id;
@synthesize name;
@synthesize desc;
@synthesize icon_media_id;
@synthesize intro_dialog_script_id;
@synthesize back_button_enabled;

- (id) init
{
  if(self = [super init])
  {
    self.dialog_id = 0;
    self.name = @"Dialog";
    self.desc = @"";
    self.icon_media_id = 0;
    self.intro_dialog_script_id = 0;
    self.back_button_enabled = YES;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.dialog_id              = [dict validIntForKey:@"dialog_id"];
    self.name                   = [dict validStringForKey:@"name"];
    self.desc                   = [dict validStringForKey:@"description"];
    self.icon_media_id          = [dict validIntForKey:@"icon_media_id"];
    self.intro_dialog_script_id = [dict validIntForKey:@"intro_dialog_script_id"];
    self.back_button_enabled    = [dict validBoolForKey:@"back_button_enabled"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.dialog_id] forKey:@"dialog_id"];
  [d setObject:self.name forKey:@"name"];
  [d setObject:self.desc forKey:@"description"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.icon_media_id] forKey:@"icon_media_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.intro_dialog_script_id] forKey:@"intro_dialog_script_id"];
  [d setObject:[NSString stringWithFormat:@"%d",self.back_button_enabled] forKey:@"back_button_enabled"];
  return [NSString JSONFromFlatStringDict:d];
}

- (Dialog *) copy
{
  Dialog *c = [[Dialog alloc] init];
  c.dialog_id              = self.dialog_id;
  c.name                   = self.name;
  c.desc                   = self.desc;
  c.icon_media_id          = self.icon_media_id;
  c.intro_dialog_script_id = self.intro_dialog_script_id;
  c.back_button_enabled    = self.back_button_enabled;
  return c;
}

- (long) compareTo:(Dialog *)ob
{
  return (ob.dialog_id == self.dialog_id);
}

- (NSString *) description
{
  return [NSString stringWithFormat:@"Dialog- Id:%ld\tName:%@\t",self.dialog_id,self.name];
}

- (long) icon_media_id
{
    if(!icon_media_id) return DEFAULT_DIALOG_ICON_MEDIA_ID;
    return icon_media_id;
}

@end


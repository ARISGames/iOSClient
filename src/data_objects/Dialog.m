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

@implementation Dialog

@synthesize dialog_id;
@synthesize name;
@synthesize desc;
@synthesize icon_media_id;
@synthesize intro_dialog_script_id;
@synthesize enable_back_button;

- (id) init
{
  if(self = [super init])
  {
    self.dialog_id = 0;
    self.name = @"Dialog";
    self.desc = @"";
    self.icon_media_id = 0;
    self.intro_dialog_script_id = 0;
    self.enable_back_button = 1;
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
    self.enable_back_button     = [dict validIntForKey:@"enable_back_button"];
  }
  return self;
}

- (Dialog *) copy
{
  Dialog *c = [[Dialog alloc] init];
  c.dialog_id              = self.dialog_id;
  c.name                   = self.name;
  c.desc                   = self.desc;
  c.icon_media_id          = self.icon_media_id;
  c.intro_dialog_script_id = self.intro_dialog_script_id;
  c.enable_back_button     = self.enable_back_button;
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

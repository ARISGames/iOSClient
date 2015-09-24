//
//  DialogOption.m
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "DialogOption.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation DialogOption

@synthesize dialog_option_id;
@synthesize dialog_id;
@synthesize parent_dialog_script_id;
@synthesize prompt;
@synthesize link_type;
@synthesize link_id;
@synthesize link_info;
@synthesize sort_index;
@synthesize requirement_root_package_id;

- (id) init
{
  if(self = [super init])
  {
    self.dialog_option_id = 0;
    self.dialog_id = 0;
    self.parent_dialog_script_id = 0;
    self.prompt = @"";
    self.link_type = @"EXIT";
    self.link_id = 0;
    self.link_info = @"";
    self.sort_index = 0;
    self.requirement_root_package_id = 0;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.dialog_option_id            = [dict validIntForKey:@"dialog_option_id"];
    self.dialog_id                   = [dict validIntForKey:@"dialog_id"];
    self.parent_dialog_script_id     = [dict validIntForKey:@"parent_dialog_script_id"];
    self.prompt                      = [dict validStringForKey:@"prompt"];
    self.link_type                   = [dict validStringForKey:@"link_type"];
    self.link_id                     = [dict validIntForKey:@"link_id"];
    self.link_info                   = [dict validStringForKey:@"link_info"];
    self.sort_index                  = [dict validIntForKey:@"sort_index"];
    self.requirement_root_package_id = [dict validIntForKey:@"requirement_root_package_id"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.dialog_option_id] forKey:@"dialog_option_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.dialog_id] forKey:@"dialog_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.parent_dialog_script_id] forKey:@"parent_dialog_script_id"];
  [d setObject:self.prompt forKey:@"prompt"];
  [d setObject:self.link_type forKey:@"link_type"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.link_id] forKey:@"link_id"];
  [d setObject:self.link_info forKey:@"link_info"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.sort_index] forKey:@"sort_index"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.requirement_root_package_id] forKey:@"requirement_root_package_id"];
  return [NSString JSONFromFlatStringDict:d];
}

- (DialogOption *) copy
{
  DialogOption *c = [[DialogOption alloc] init];
  c.dialog_option_id            = self.dialog_option_id;
  c.dialog_id                   = self.dialog_id;
  c.parent_dialog_script_id     = self.parent_dialog_script_id;
  c.prompt                      = self.prompt;
  c.link_type                   = self.link_type;
  c.link_id                     = self.link_id;
  c.link_info                   = self.link_info;
  c.sort_index                  = self.sort_index;
  c.requirement_root_package_id = self.requirement_root_package_id;
  return c;
}

- (long) compareTo:(DialogOption *)ob
{
  return (ob.dialog_option_id == self.dialog_option_id);
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"DialogOption- Id:%ld\tPrompt:%@\t",self.dialog_option_id,self.prompt];
}

@end


//
//  DialogOption.m
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "DialogOption.h"
#import "NSDictionary+ValidParsers.h"

@implementation DialogOption

@synthesize dialog_option_id;
@synthesize dialog_id;
@synthesize parent_dialog_script_id;
@synthesize prompt;
@synthesize link_type;
@synthesize link_id;
@synthesize sort_index;

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
    self.sort_index = 0;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.dialog_option_id        = [dict validIntForKey:@"dialog_option_id"];
    self.dialog_id               = [dict validIntForKey:@"dialog_id"]; 
    self.parent_dialog_script_id = [dict validIntForKey:@"parent_dialog_script_id"];
    self.prompt                  = [dict validStringForKey:@"prompt"]; 
    self.link_type               = [dict validStringForKey:@"link_type"]; 
    self.link_id                 = [dict validIntForKey:@"link_id"]; 
    self.sort_index              = [dict validIntForKey:@"sort_index"]; 
  }
  return self;
}

- (DialogOption *) copy
{
  DialogOption *c = [[DialogOption alloc] init];
  c.dialog_option_id        = self.dialog_option_id;
  c.dialog_id               = self.dialog_id; 
  c.parent_dialog_script_id = self.parent_dialog_script_id;
  c.prompt                  = self.prompt; 
  c.link_type               = self.link_type;
  c.link_id                 = self.link_id;
  c.sort_index              = self.sort_index;
  return c;
}

- (int) compareTo:(DialogOption *)ob
{
  return (ob.dialog_option_id == self.dialog_option_id);
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"DialogOption- Id:%d\tPrompt:%@\t",self.dialog_option_id,self.prompt];
}

@end

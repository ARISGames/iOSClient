//
//  DialogScript.m
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "DialogScript.h"
#import "NSDictionary+ValidParsers.h"

@implementation DialogScript

@synthesize dialog_script_id;
@synthesize dialog_id;
@synthesize dialog_character_id;
@synthesize text;
@synthesize event_package_id;

- (id) init
{
  if(self = [super init])
  {
    self.dialog_script_id = 0;
    self.dialog_id = 0;
    self.dialog_character_id = 0;
    self.text = @"";
    self.event_package_id = 0;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.dialog_script_id        = [dict validIntForKey:@"dialog_script_id"];
    self.dialog_id               = [dict validIntForKey:@"dialog_id"];
    self.dialog_character_id     = [dict validIntForKey:@"dialog_character_id"];
    self.text                    = [dict validStringForKey:@"text"];
    self.event_package_id        = [dict validIntForKey:@"event_package_id"];
  }
  return self;
}

- (DialogScript *) copy
{
  DialogScript *c = [[DialogScript alloc] init];
  c.dialog_script_id        = self.dialog_script_id;
  c.dialog_id               = self.dialog_id;
  c.dialog_character_id     = self.dialog_character_id;
  c.text                    = self.text;
  c.event_package_id        = self.event_package_id;
  return c;
}

- (long) compareTo:(DialogScript *)ob
{
  return (ob.dialog_script_id == self.dialog_script_id);
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"DialogScript- Id:%ld\tText:%@\t",self.dialog_script_id,self.text];
}

@end

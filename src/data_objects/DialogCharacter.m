//
//  DialogCharacter.m
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "DialogCharacter.h"
#import "NSDictionary+ValidParsers.h"

@implementation DialogCharacter

@synthesize dialog_character_id;
@synthesize name;
@synthesize title;
@synthesize media_id;

- (id) init
{
    if(self = [super init])
    {
        self.dialog_character_id = 0;
        self.name = @"DialogCharacter";
        self.title = @"";
        self.media_id = 0;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.dialog_character_id = [dict validIntForKey:@"dialog_character_id"];
    self.name                = [dict validStringForKey:@"name"];
    self.title               = [dict validStringForKey:@"title"];
    self.media_id            = [dict validIntForKey:@"media_id"]; 
  }
  return self;
}

- (DialogCharacter *) copy
{
  DialogCharacter *c = [[DialogCharacter alloc] init];
  c.dialog_character_id = self.dialog_character_id;
  c.name                = self.name;
  c.title               = self.title;
  c.media_id            = self.media_id;
  return c;
}

- (long)compareTo:(DialogCharacter *)ob
{
  return (ob.dialog_character_id == self.dialog_character_id);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"DialogCharacter- Id:%ld\tName:%@\t",self.dialog_character_id,self.name];
}

@end


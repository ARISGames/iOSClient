//
//  Requirement.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Requirement.h"
#import "NSDictionary+ValidParsers.h"

//ROOT
@implementation RequirementRootPackage

@synthesize requirement_root_package_id;
@synthesize name;

- (id) init
{
  if(self = [super init])
  {
    self.requirement_root_package_id = 0;
    self.name = @"";
  }
  return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.requirement_root_package_id = [dict validIntForKey:@"requirement_root_package_id"];
    self.name                        = [dict validObjectForKey:@"name"];
  }
  return self;
}

@end


//AND
@implementation RequirementAndPackage

@synthesize requirement_and_package_id;
@synthesize requirement_root_package_id;
@synthesize name;

- (id) init
{
  if(self = [super init])
  {
    self.requirement_and_package_id = 0;
    self.requirement_root_package_id = 0;
    self.name = @"";
  }
  return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.requirement_and_package_id = [dict validIntForKey:@"requirement_and_package_id"];
    self.requirement_root_package_id = [dict validIntForKey:@"requirement_root_package_id"];
    self.name                        = [dict validObjectForKey:@"name"];
  }
  return self;
}

@end


//ATOM
@implementation RequirementAtom

@synthesize requirement_atom_id;
@synthesize requirement_and_package_id;
@synthesize bool_operator;
@synthesize requirement;
@synthesize content_id;
@synthesize distance;
@synthesize qty;
@synthesize latitude;
@synthesize longitude;

- (id) init
{
  if(self = [super init])
  {
    self.requirement_atom_id = 0;
    self.requirement_and_package_id = 0;
    self.bool_operator = 0;
    self.requirement = @"";
    self.content_id = 0;
    self.distance = 0;
    self.qty = 0;
    self.latitude = 0;
    self.longitude = 0;
  }
  return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.requirement_atom_id        = [dict validIntForKey:@"requirement_atom_id"];
    self.requirement_and_package_id = [dict validIntForKey:@"requirement_and_package_id"];
    self.bool_operator              = [dict validBoolForKey:@"bool_operator"];
    self.requirement                = [dict validStringForKey:@"requirement"];
    self.content_id                 = [dict validIntForKey:@"content_id"];
    self.distance                   = [dict validIntForKey:@"distance"];
    self.qty                        = [dict validIntForKey:@"qty"];
    self.latitude                   = [dict validDoubleForKey:@"latitude"];
    self.longitude                  = [dict validDoubleForKey:@"longitude"];
  }
  return self;
}

@end

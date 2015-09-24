//
//  Requirement.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Requirement.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

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

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.requirement_root_package_id] forKey:@"requirement_root_package_id"];
  [d setObject:self.name forKey:@"name"];
  return [NSString JSONFromFlatStringDict:d];
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

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.requirement_and_package_id] forKey:@"requirement_and_package_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.requirement_root_package_id] forKey:@"requirement_root_package_id"];
  [d setObject:self.name forKey:@"name"];
  return [NSString JSONFromFlatStringDict:d];
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

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.requirement_atom_id] forKey:@"requirement_atom_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.requirement_and_package_id] forKey:@"requirement_and_package_id"];
  [d setObject:[NSString stringWithFormat:@"%d",self.bool_operator] forKey:@"bool_operator"];
  [d setObject:self.requirement forKey:@"requirement"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.content_id] forKey:@"content_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.distance] forKey:@"distance"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.qty] forKey:@"qty"];
  [d setObject:[NSString stringWithFormat:@"%f",self.latitude] forKey:@"latitude"];
  [d setObject:[NSString stringWithFormat:@"%f",self.longitude] forKey:@"longitude"];
  return [NSString JSONFromFlatStringDict:d];
}

@end

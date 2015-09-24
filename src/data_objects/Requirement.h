//
//  Requirement.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//ROOT
@interface RequirementRootPackage : NSObject
{
  long requirement_root_package_id;
  NSString *name;
}

@property(readwrite, assign) long requirement_root_package_id;
@property(nonatomic, strong) NSString *name;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;

@end


//AND
@interface RequirementAndPackage : NSObject
{
  long requirement_and_package_id;
  long requirement_root_package_id;
  NSString *name;
}

@property(readwrite, assign) long requirement_and_package_id;
@property(readwrite, assign) long requirement_root_package_id;
@property(nonatomic, strong) NSString *name;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;

@end


//ATOM
@interface RequirementAtom : NSObject
{
  long requirement_atom_id;
  long requirement_and_package_id;
  BOOL bool_operator;
  NSString *requirement;
  long content_id;
  long distance;
  long qty;
  double latitude;
  double longitude;
}

@property(readwrite, assign) long requirement_atom_id;
@property(readwrite, assign) long requirement_and_package_id;
@property(readwrite, assign) BOOL bool_operator;
@property(readwrite, strong) NSString *requirement;
@property(readwrite, assign) long content_id;
@property(readwrite, assign) long distance;
@property(readwrite, assign) long qty;
@property(readwrite, assign) double latitude;
@property(readwrite, assign) double longitude;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;

@end


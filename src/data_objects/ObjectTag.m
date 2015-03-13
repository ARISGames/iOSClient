//
//  ObjectTag.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectTag.h"
#import "NSDictionary+ValidParsers.h"

@implementation ObjectTag

@synthesize object_tag_id;
@synthesize object_type;
@synthesize object_id;
@synthesize tag_id;

- (id) init
{
    if(self = [super init])
    {
        self.object_tag_id = 0;
        self.object_type = @"Tag";
        self.object_id = 0;
        self.tag_id = 0;
    }
    return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.object_tag_id = [dict validIntForKey:@"object_tag_id"];
        self.object_type   = [dict validObjectForKey:@"object_type"];
        self.object_id     = [dict validIntForKey:@"object_id"];
        self.tag_id        = [dict validIntForKey:@"tag_id"];
    }
    return self;
}

- (id) copy
{
    ObjectTag *o = [[ObjectTag alloc] init];
    o.object_tag_id = self.object_tag_id;
    o.object_type = self.object_type;
    o.object_id = self.object_id;
    o.tag_id = self.tag_id;
    return o;
}

- (long) compareTo:(ObjectTag *)ob
{
	return (ob.object_tag_id == self.object_tag_id);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ObjectTag- Id:%ld\ttag:%@",self.object_tag_id,self.object_type];
}

@end

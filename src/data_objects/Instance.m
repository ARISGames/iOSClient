//
//  Instance.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Instance.h"
#import "NSDictionary+ValidParsers.h"

@implementation Instance

@synthesize instance_id;
@synthesize object_type;
@synthesize object_id;
@synthesize owner_id;
@synthesize qty;
@synthesize infinite_qty;

- (id) init
{
    if(self = [super init])
    {
        self.instance_id = 0;
        self.owner_id = 0; 
        self.qty = 0;
        self.infinite_qty = NO;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.instance_id = [dict validIntForKey:@"instance_id"];
        self.object_type = [dict validStringForKey:@"object_type"];
        self.object_id   = [dict validIntForKey:@"object_id"]; 
        self.owner_id = [dict validIntForKey:@"owner_id"];
        self.qty = [dict validIntForKey:@"qty"]; 
        self.infinite_qty = [dict validBoolForKey:@"infinite_qty"];
    }
    return self;
}

- (void) mergeDataFromInstance:(Instance *)i
{
    self.instance_id = i.instance_id;
    self.object_type = i.object_type;
    self.object_id = i.object_id; 
    self.owner_id = i.owner_id;
    self.qty = i.qty; 
    self.infinite_qty = i.infinite_qty; 
}

- (Instance *) copy
{
    Instance *c = [[Instance alloc] init];
    
    c.instance_id = self.instance_id;
    c.object_type = self.object_type;
    c.object_id = self.object_id; 
    c.owner_id = self.owner_id;
    c.qty = self.qty; 
    c.infinite_qty = self.infinite_qty; 
    
    return c;
}

- (id<InstantiableProtocol>) object
{
    //big ol switch statement on object_type fetching from appropriate model
    return nil;
}

@end

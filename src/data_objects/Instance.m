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
@synthesize object;
@synthesize qty;
@synthesize infiniteQty;

- (id) init
{
    if(self = [super init])
    {
        self.instance_id = 0;
        self.object = nil;
        self.qty = 0;
        self.infiniteQty = NO;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.instance_id = [dict validIntForKey:@"instance_id"];
        //self.object = [dict validIntForKey:@""];
        self.qty = [dict validIntForKey:@"qty"];
        self.infiniteQty = [dict validBoolForKey:@"infinite_qty"];
    }
    return self;
}

@end

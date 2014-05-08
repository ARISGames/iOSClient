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
@synthesize type;
@synthesize object;
@synthesize qty;
@synthesize infinite_qty;

- (id) init
{
    if(self = [super init])
    {
        self.instance_id = 0;
        self.object = nil;
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
        //self.object = [dict validIntForKey:@""];
        self.qty = [dict validIntForKey:@"qty"];
        self.infinite_qty = [dict validBoolForKey:@"infinite_qty"];
    }
    return self;
}

- (GameObjectViewController *) viewControllerForDelegate:(id<GameObjectViewControllerDelegate>)d fromSource:(id)s;
{
    //return [[ItemViewController alloc] initWithItem:self delegate:d source:s]; 
    return nil;
}

- (Instance *) copy
{
    Instance *c = [[Instance alloc] init];
    
    c.instance_id = self.instance_id;
    c.object = self.object;
    c.qty = self.qty;
    c.infinite_qty = self.infinite_qty; 
    
    return c;
}

@end

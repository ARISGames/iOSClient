//
//  Trigger.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Trigger.h"
#import "NSDictionary+ValidParsers.h"

@implementation Trigger

@synthesize trigger_id;
@synthesize name;
@synthesize instance_id;
@synthesize scene_id;
@synthesize type;
@synthesize location;
@synthesize distance;
@synthesize wiggle;
@synthesize show_title;
@synthesize code;

- (id) init
{
    if(self = [super init])
    {
        self.trigger_id = 0;
        self.name = @"";
        self.instance_id = 0;
        self.scene_id = 0;
        self.type = @"IMMEDIATE";
        self.location = nil;
        self.distance = 10;
        self.wiggle = NO;
        self.show_title = NO;
        self.code = @"";
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.trigger_id = [dict validIntForKey:@"trigger_id"];
        self.name = [dict validStringForKey:@"name"];
        self.instance_id = [dict validIntForKey:@"instance_id"];
        self.scene_id = [dict validIntForKey:@"scene_id"];
        self.type = [dict validStringForKey:@"type"];
        self.location = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"latitude"] longitude:[dict validDoubleForKey:@"longitude"]];
        self.distance = [dict validIntForKey:@"distance"];
        self.wiggle = [dict validBoolForKey:@"wiggle"];
        self.show_title = [dict validBoolForKey:@"show_title"];
        self.code = [dict validStringForKey:@"code"];
    }
    return self;
}

- (void) mergeDataFromTrigger:(Trigger *)t
{
    self.trigger_id = t.trigger_id;
    self.name = t.name;
    self.instance_id = t.instance_id;
    self.scene_id = t.scene_id;
    self.type = t.type;
    self.location = t.location;
    self.distance = t.distance;
    self.wiggle = t.wiggle;
    self.show_title = t.show_title;
    self.code = t.code;
}

@end


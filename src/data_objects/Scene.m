//
//  Scene.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Scene.h"
#import "NSDictionary+ValidParsers.h"

@implementation Scene

@synthesize scene_id;
@synthesize name; 
@synthesize instance;
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
        self.scene_id = 0;
        self.name = @""; 
        self.instance = nil;
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
        self.scene_id = [dict validIntForKey:@"scene_id"];
        self.name = [dict validStringForKey:@"name"];
        //self.instance = [dict validObjectForKey:@"instance"];
        self.type = [dict validStringForKey:@"type"];
        self.location = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"latitude"] longitude:[dict validDoubleForKey:@"longitude"]]; 
        self.distance = [dict validIntForKey:@"distance"];
        self.wiggle = [dict validBoolForKey:@"wiggle"];
        self.show_title = [dict validBoolForKey:@"show_title"];
        self.code = [dict validStringForKey:@"code"];
    }
    return self;
}

@end


//
//  Trigger.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Trigger.h"
#import "AppModel.h"
#import "NSDictionary+ValidParsers.h"

@implementation Trigger

@synthesize trigger_id;
@synthesize instance_id;
@synthesize scene_id;
@synthesize type;
@synthesize title;
@synthesize icon_media_id;
@synthesize location;
@synthesize distance;
@synthesize infinite_distance;
@synthesize wiggle;
@synthesize show_title;
@synthesize code;
@synthesize mapCircle;

- (id) init
{
    if(self = [super init])
    {
        self.trigger_id = 0;
        self.instance_id = 0; 
        self.scene_id = 0;
        self.type = @"IMMEDIATE";
        self.title = @"";
        self.icon_media_id = 0; 
        self.location = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
        self.distance = 10;
        self.infinite_distance = NO; 
        self.wiggle = NO;
        self.show_title = NO;
        self.code = @"";
        self.mapCircle = [MKCircle circleWithCenterCoordinate:self.location.coordinate radius:(self.infinite_distance ? 0 : self.distance)];
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.trigger_id = [dict validIntForKey:@"trigger_id"];
        self.instance_id = [dict validIntForKey:@"instance_id"]; 
        self.scene_id = [dict validIntForKey:@"scene_id"];
        self.type = [dict validStringForKey:@"type"];
        self.title = [dict validStringForKey:@"title"];
        self.icon_media_id = [dict validIntForKey:@"icon_media_id"]; 
        self.location = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"latitude"] longitude:[dict validDoubleForKey:@"longitude"]];
        self.distance = [dict validIntForKey:@"distance"];
        self.infinite_distance = self.distance < 0 || self.distance > 100000; 
        self.wiggle = [dict validBoolForKey:@"wiggle"];
        self.show_title = [dict validBoolForKey:@"show_title"];
        self.code = [dict validStringForKey:@"code"];
        self.mapCircle = [MKCircle circleWithCenterCoordinate:self.location.coordinate radius:(self.infinite_distance ? 0 : self.distance)]; 
    }
    return self;
}

- (void) mergeDataFromTrigger:(Trigger *)t
{
    self.trigger_id = t.trigger_id;
    self.instance_id = t.instance_id; 
    self.scene_id = t.scene_id;
    self.type = t.type;
    self.title = t.title;
    self.icon_media_id = t.icon_media_id; 
    self.location = t.location;
    self.distance = t.distance;
    self.infinite_distance = self.infinite_distance;
    self.wiggle = t.wiggle;
    self.show_title = t.show_title;
    self.code = t.code;
    self.mapCircle = t.mapCircle; 
}

//returns icon_media of instance if self's isn't set
- (int) icon_media_id
{
    if(self.icon_media_id) return self.icon_media_id;
    return [_MODEL_INSTANCES_ instanceForId:self.instance_id].icon_media_id;
}

//MKAnnotation stuff
- (CLLocationCoordinate2D) coordinate
{
    return location.coordinate;
}

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    //no
}

//returns title of instance if self's isn't set
- (NSString *) title
{
    if(self.title && ![self.title isEqualToString:@""]) return self.title;
    return [_MODEL_INSTANCES_ instanceForId:self.instance_id].name; 
}

- (NSString *) subtitle
{
    return @"Subtitle!"; 
}

@end

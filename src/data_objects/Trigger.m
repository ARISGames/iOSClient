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
@synthesize requirement_root_package_id;
@synthesize instance_id;
@synthesize scene_id;
@synthesize type;
@synthesize name;
@synthesize title;
@synthesize icon_media_id;
@synthesize location;
@synthesize distance;
@synthesize infinite_distance;
@synthesize wiggle;
@synthesize show_title;
@synthesize hidden;
@synthesize trigger_on_enter;
@synthesize qr_code;
@synthesize seconds;
@synthesize time_left;

- (id) init
{
  if(self = [super init])
  {
    trigger_id = 0;
    requirement_root_package_id = 0;
    instance_id = 0;
    scene_id = 0;
    type = @"IMMEDIATE";
    name = @"";
    title = @"";
    icon_media_id = 0;
    location = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    distance = 10;
    infinite_distance = NO;
    wiggle = NO;
    show_title = NO;
    hidden = NO;
    trigger_on_enter = NO;
    qr_code = @"";
    seconds = 0;
    time_left = 0;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    trigger_id                  = [dict validIntForKey:@"trigger_id"];
    requirement_root_package_id = [dict validIntForKey:@"requirement_root_package_id"];
    instance_id                 = [dict validIntForKey:@"instance_id"];
    scene_id                    = [dict validIntForKey:@"scene_id"];
    type                        = [dict validStringForKey:@"type"];
    name                        = [dict validStringForKey:@"name"];
    title                       = [dict validStringForKey:@"title"];
    icon_media_id               = [dict validIntForKey:@"icon_media_id"];
    location                    = [dict validLocationForLatKey:@"latitude" lonKey:@"longitude"];
    distance                    = [dict validIntForKey:@"distance"];
    infinite_distance           = [dict validIntForKey:@"infinite_distance"] || distance < 0 || distance > 100000;
    wiggle                      = [dict validBoolForKey:@"wiggle"];
    show_title                  = [dict validBoolForKey:@"show_title"];
    hidden                      = [dict validBoolForKey:@"hidden"];
    trigger_on_enter            = [dict validBoolForKey:@"trigger_on_enter"];
    qr_code                     = [dict validStringForKey:@"qr_code"];
    seconds                     = [dict validIntForKey:@"seconds"];
    time_left                   = seconds;
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:[NSString stringWithFormat:@"%ld",trigger_id]];
  [r appendString:[NSString stringWithFormat:@"%ld",requirement_root_package_id]];
  [r appendString:[NSString stringWithFormat:@"%ld",instance_id]];
  [r appendString:[NSString stringWithFormat:@"%ld",scene_id]];
  [r appendString:type];
  [r appendString:name];
  [r appendString:title];
  [r appendString:[NSString stringWithFormat:@"%ld",icon_media_id]];
  [r appendString:[NSString stringWithFormat:@"%f",location.coordinate.latitude]];
  [r appendString:[NSString stringWithFormat:@"%f",location.coordinate.longitude]];
  [r appendString:[NSString stringWithFormat:@"%ld",distance]];
  [r appendString:[NSString stringWithFormat:@"%d",infinite_distance]];
  [r appendString:[NSString stringWithFormat:@"%d",wiggle]];
  [r appendString:[NSString stringWithFormat:@"%d",show_title]];
  [r appendString:[NSString stringWithFormat:@"%d",hidden]];
  [r appendString:[NSString stringWithFormat:@"%d",trigger_on_enter]];
  [r appendString:qr_code];
  return r;
}

- (BOOL) mergeDataFromTrigger:(Trigger *)t //returns whether or not an update occurred
{
  BOOL e = [self trigIsEqual:t];
  trigger_id        = t.trigger_id;
  requirement_root_package_id = t.requirement_root_package_id;
  instance_id       = t.instance_id;
  scene_id          = t.scene_id;
  type              = t.type;
  name              = t.name;
  title             = t.title;
  icon_media_id     = t.icon_media_id;
  location          = t.location;
  distance          = t.distance;
  infinite_distance = t.infinite_distance;
  wiggle            = t.wiggle;
  show_title        = t.show_title;
  hidden            = t.hidden;
  trigger_on_enter  = t.trigger_on_enter;
  qr_code           = t.qr_code;
  seconds           = t.seconds;
  if(time_left > seconds) time_left = seconds;
  return e;
}

//returns icon_media of instance if self's isn't set
- (long) icon_media_id
{
  if(icon_media_id) return icon_media_id;
  return [_MODEL_INSTANCES_ instanceForId:instance_id].icon_media_id;
}

- (BOOL) trigIsEqual:(Trigger *)t
{
  return
    (trigger_id                    == t.trigger_id                    &&
     requirement_root_package_id   == t.requirement_root_package_id   &&
     instance_id                   == t.instance_id                   &&
     scene_id                      == t.scene_id                      &&
     [type isEqualToString:t.type]                                    &&
     [name isEqualToString:t.name]                                    &&
     [title isEqualToString:t.title]                                  &&
     self.icon_media_id            == t.icon_media_id                 && //must use 'self' to parallel fallthrough to parent
     location.coordinate.latitude  == t.location.coordinate.latitude  &&
     location.coordinate.longitude == t.location.coordinate.longitude &&
     distance                      == t.distance                      &&
     infinite_distance             == t.infinite_distance             &&
     wiggle                        == t.wiggle                        &&
     show_title                    == t.show_title                    &&
     hidden                        == t.hidden                        &&
     trigger_on_enter              == t.trigger_on_enter              &&
     [qr_code isEqualToString:t.qr_code])                             &&
     seconds                       == t.seconds;
     //time_left                     == t.time_left //
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
  Instance *i;
  if(title && ![title isEqualToString:@""]) return title;
  else if((i = [_MODEL_INSTANCES_ instanceForId:instance_id]) && i.name) return i.name;
  return @"";
}

- (NSString *) subtitle
{
  return @"Subtitle!";
}

@end


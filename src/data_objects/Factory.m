//
//  Factory.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Factory.h"
#import "AppModel.h"
#import "NSDictionary+ValidParsers.h"

@implementation Factory

@synthesize factory_id;
@synthesize game_id;
@synthesize name;
@synthesize desc;
@synthesize object_type;
@synthesize object_id;
@synthesize seconds_per_production;
@synthesize production_probability;
@synthesize max_production;
@synthesize produce_expiration_time;
@synthesize produce_expire_on_view;
@synthesize production_bound_type;
@synthesize location_bound_type;
@synthesize min_production_distance;
@synthesize max_production_distance;
@synthesize production_timestamp;
@synthesize requirement_root_package_id;

@synthesize trigger_distance;
@synthesize trigger_title;
@synthesize trigger_icon_media_id;
@synthesize trigger_location;
@synthesize trigger_infinite_distance;
@synthesize trigger_wiggle;
@synthesize trigger_show_title;
@synthesize trigger_hidden;
@synthesize trigger_on_enter;
@synthesize trigger_requirement_root_package_id;
@synthesize trigger_scene_id;

- (id) init
{
  if(self = [super init])
  {
    factory_id = 0;
    game_id = 0;
    name = @"";
    desc = @"";
    object_type = @"";//PLAQUE,ITEM,DIALOG,WEB_PAGE
    object_id = 0;
    seconds_per_production = 0;
    production_probability = 0;
    max_production = 0;
    produce_expiration_time = 0;
    produce_expire_on_view = 0;
    production_bound_type = @"TOTAL";//PER_PLAYER,TOTAL
    location_bound_type = @"PLAYER";//PLAYER,LOCATION
    min_production_distance = 0;
    max_production_distance = 0;
    production_timestamp = 0;
    requirement_root_package_id = 0;

    trigger_distance = 0;
    trigger_title = @"";
    trigger_icon_media_id = 0;
    trigger_location = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    trigger_infinite_distance = 0;
    trigger_wiggle = 0;
    trigger_show_title = 0;
    trigger_hidden = 0;
    trigger_on_enter = 0;
    trigger_requirement_root_package_id = 0;
    trigger_scene_id = 0;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    factory_id                          = [dict validIntForKey:@"factory_id"];
    game_id                             = [dict validIntForKey:@"game_id"];
    name                                = [dict validStringForKey:@"name"];
    desc                                = [dict validStringForKey:@"desc"];
    object_type                         = [dict validStringForKey:@"object_type"];
    object_id                           = [dict validIntForKey:@"object_id"];
    seconds_per_production              = [dict validIntForKey:@"seconds_per_production"];
    production_probability              = [dict validDoubleForKey:@"production_probability"];
    max_production                      = [dict validIntForKey:@"max_production"];
    produce_expiration_time             = [dict validIntForKey:@"produce_expiration_time"];
    produce_expire_on_view              = [dict validBoolForKey:@"produce_expire_on_view"];
    production_bound_type               = [dict validStringForKey:@"production_bound_type"];
    location_bound_type                 = [dict validStringForKey:@"location_bound_type"];
    min_production_distance             = [dict validIntForKey:@"min_production_distance"];
    max_production_distance             = [dict validIntForKey:@"max_production_distance"];
    production_timestamp                = [dict validDateForKey:@"production_timestamp"];
    requirement_root_package_id         = [dict validIntForKey:@"requirement_root_package_id"];

    trigger_distance                    = [dict validIntForKey:@"trigger_distance"];
    trigger_title                       = [dict validStringForKey:@"trigger_title"];
    trigger_icon_media_id               = [dict validIntForKey:@"trigger_icon_media_id"];
    trigger_location                    = [dict validLocationForLatKey:@"trigger_latitude" lonKey:@"trigger_longitude"];
    trigger_infinite_distance           = [dict validIntForKey:@"trigger_infinite_distance"];
    trigger_wiggle                      = [dict validBoolForKey:@"trigger_wiggle"];
    trigger_show_title                  = [dict validBoolForKey:@"trigger_show_title"];
    trigger_hidden                      = [dict validBoolForKey:@"trigger_hidden"];
    trigger_on_enter                    = [dict validBoolForKey:@"trigger_on_enter"];
    trigger_requirement_root_package_id = [dict validIntForKey:@"trigger_requirement_root_package_id"];
    trigger_scene_id                    = [dict validIntForKey:@"trigger_scene_id"];
  }
  return self;
}

- (void) mergeDataFromFactory:(Factory *)f
{
  factory_id                          = f.factory_id;
  game_id                             = f.game_id;
  name                                = f.name;
  desc                                = f.desc;
  object_type                         = f.object_type;
  object_id                           = f.object_id;
  seconds_per_production              = f.seconds_per_production;
  production_probability              = f.production_probability;
  max_production                      = f.max_production;
  produce_expiration_time             = f.produce_expiration_time;
  produce_expire_on_view              = f.produce_expire_on_view;
  production_bound_type               = f.production_bound_type;
  location_bound_type                 = f.location_bound_type;
  min_production_distance             = f.min_production_distance;
  max_production_distance             = f.max_production_distance;
  production_timestamp                = f.production_timestamp;
  requirement_root_package_id         = f.requirement_root_package_id;

  trigger_distance                    = f.trigger_distance;
  trigger_title                       = f.trigger_title;
  trigger_icon_media_id               = f.trigger_icon_media_id;
  trigger_location                    = f.trigger_location;
  trigger_infinite_distance           = f.trigger_infinite_distance;
  trigger_wiggle                      = f.trigger_wiggle;
  trigger_show_title                  = f.trigger_show_title;
  trigger_hidden                      = f.trigger_hidden;
  trigger_on_enter                    = f.trigger_on_enter;
  trigger_requirement_root_package_id = f.trigger_requirement_root_package_id;
  trigger_scene_id                    = f.trigger_scene_id;
}

@end


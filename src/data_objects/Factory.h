//
//  Factory.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Factory : NSObject
{
  long factory_id;
  long game_id;
  NSString *name;
  NSString *desc;
  NSString *object_type;
  long object_id;
  long seconds_per_production;
  double production_probability;
  long max_production;
  long produce_expiration_time;
  BOOL produce_expire_on_view;
  NSString *production_bound_type;
  NSString *location_bound_type;
  long min_production_distance;
  long max_production_distance;
  NSDate *production_timestamp;
  long requirement_root_package_id;

  long trigger_distance;
  NSString *trigger_title;
  long trigger_icon_media_id;
  CLLocation *trigger_location;
  BOOL trigger_infinite_distance;
  BOOL trigger_wiggle;
  BOOL trigger_show_title;
  BOOL trigger_hidden;
  BOOL trigger_on_enter;
  long trigger_requirement_root_package_id;
  long trigger_scene_id;
}

@property (nonatomic, assign) long factory_id;
@property (nonatomic, assign) long game_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *object_type;
@property (nonatomic, assign) long object_id;
@property (nonatomic, assign) long seconds_per_production;
@property (nonatomic, assign) double production_probability;
@property (nonatomic, assign) long max_production;
@property (nonatomic, assign) long produce_expiration_time;
@property (nonatomic, assign) BOOL produce_expire_on_view;
@property (nonatomic, copy) NSString *production_bound_type;
@property (nonatomic, copy) NSString *location_bound_type;
@property (nonatomic, assign) long min_production_distance;
@property (nonatomic, assign) long max_production_distance;
@property (nonatomic, strong) NSDate *production_timestamp;
@property (nonatomic, assign) long requirement_root_package_id;

@property (nonatomic, assign) long trigger_distance;
@property (nonatomic, copy) NSString *trigger_title;
@property (nonatomic, assign) long trigger_icon_media_id;
@property (nonatomic, strong) CLLocation *trigger_location;
@property (nonatomic, assign) BOOL trigger_infinite_distance;
@property (nonatomic, assign) BOOL trigger_wiggle;
@property (nonatomic, assign) BOOL trigger_show_title;
@property (nonatomic, assign) BOOL trigger_hidden;
@property (nonatomic, assign) BOOL trigger_on_enter;
@property (nonatomic, assign) long trigger_requirement_root_package_id;
@property (nonatomic, assign) long trigger_scene_id;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;
- (void) mergeDataFromFactory:(Factory *)f;

@end


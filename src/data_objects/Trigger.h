//
//  Trigger.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//<MKAnnotation> enforces 'coordinate', 'title', and 'subtitle' accessors
//which are derived on the fly from the raw data, and 'setCoordinate' mutator, which we ignore
@interface Trigger : NSObject <MKAnnotation>
{
  long trigger_id;
  long requirement_root_package_id;
  long instance_id;
  long scene_id;
  NSString *type;
  NSString *name;
  NSString *title;
  long icon_media_id;
  CLLocation *location;
  long distance;
  BOOL infinite_distance;
  BOOL wiggle;
  BOOL show_title;
  BOOL hidden;
  BOOL trigger_on_enter;
  NSString *qr_code;
  long seconds;
  long time_left; //client only!
}

@property (nonatomic, assign) long trigger_id;
@property (nonatomic, assign) long requirement_root_package_id;
@property (nonatomic, assign) long instance_id;
@property (nonatomic, assign) long scene_id;
@property (nonatomic, copy)   NSString *type;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, assign) long icon_media_id;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) long distance;
@property (nonatomic, assign) BOOL infinite_distance;
@property (nonatomic, assign) BOOL wiggle;
@property (nonatomic, assign) BOOL show_title;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) BOOL trigger_on_enter;
@property (nonatomic, copy)   NSString *qr_code;
@property (nonatomic, assign) long seconds;
@property (nonatomic, assign) long time_left;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;
- (BOOL) mergeDataFromTrigger:(Trigger *)t;
- (BOOL) trigIsEqual:(Trigger *)t;

@end


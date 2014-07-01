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
    int trigger_id;
    int instance_id; 
    int scene_id;
    NSString *type; 
    NSString *title; 
    int icon_media_id; 
    CLLocation *location;
    int distance;
    BOOL infinite_distance;
    BOOL wiggle;
    BOOL show_title;
    NSString *code; 
    
    MKCircle *mapCircle; //I would just extend this directly, but MKCircle has immutable properties :(
}

@property (nonatomic, assign) int trigger_id;
@property (nonatomic, assign) int instance_id;
@property (nonatomic, assign) int scene_id;
@property (nonatomic, copy)   NSString *type; 
@property (nonatomic, copy)   NSString *title; 
@property (nonatomic, assign) int icon_media_id;
@property (nonatomic, strong)   CLLocation *location;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) BOOL infinite_distance;
@property (nonatomic, assign) BOOL wiggle;
@property (nonatomic, assign) BOOL show_title;
@property (nonatomic, copy)   NSString *code; 

@property (nonatomic, strong)   MKCircle *mapCircle; 

- (id) initWithDictionary:(NSDictionary *)dict;
- (void) mergeDataFromTrigger:(Trigger *)t;

@end

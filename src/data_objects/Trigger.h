//
//  Trigger.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Trigger : NSObject
{
    int trigger_id;
    NSString *name; 
    int instance_id;
    int scene_id;
    NSString *type; 
    CLLocation *location;
    int distance;
    BOOL wiggle;
    BOOL show_title;
    NSString *code; 
}

@property (nonatomic, assign) int trigger_id;
@property (nonatomic, strong) NSString *name; 
@property (nonatomic, assign) int instance_id;
@property (nonatomic, assign) int scene_id;
@property (nonatomic, strong) NSString *type; 
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) BOOL wiggle;
@property (nonatomic, assign) BOOL show_title;
@property (nonatomic, strong) NSString *code; 

- (id) initWithDictionary:(NSDictionary *)dict;
- (void) mergeDataFromTrigger:(Trigger *)t;

@end

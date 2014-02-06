//
//  Location.h
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GameObjectProtocol.h"

@interface Location : NSObject <MKAnnotation>
{
    int locationId;
	NSString *name;
	CLLocation *latlon;
    id<GameObjectProtocol> gameObject;
	int errorRange;
    int qty;
	BOOL hidden;
	BOOL forcedDisplay;
	BOOL allowsQuickTravel;
    BOOL showTitle;
    BOOL wiggle;
    BOOL deleteWhenViewed;
    
    //MKAnnotation stuff
    CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
    
    //Overlay stuff- really really need to clean up this class.
    MKCircle *nearbyOverlay;
}

@property (nonatomic, assign) int locationId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) CLLocation *latlon;
@property (nonatomic, strong) id<GameObjectProtocol> gameObject;
@property (nonatomic, assign) int errorRange;
@property (nonatomic, assign) int qty;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) BOOL forcedDisplay;
@property (nonatomic, assign) BOOL allowsQuickTravel;
@property (nonatomic, assign) BOOL showTitle;
@property (nonatomic, assign) BOOL wiggle;
@property (nonatomic, assign) BOOL deleteWhenViewed;

//MKAnnotation stuff
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) MKCircle *nearbyOverlay;

- (Location *) initWithDictionary:(NSDictionary *)dict;
- (BOOL) compareTo:(Location *)other;

@end

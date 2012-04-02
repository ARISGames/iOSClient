//
//  Annotation.h
//  ARIS
//
//  Created by Brian Deith on 7/21/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Media.h"
#import "NearbyObjectProtocol.h"
#import "Location.h"

@interface Annotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
	int iconMediaId;
	nearbyObjectKind kind;
	Location *location;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) nearbyObjectKind kind;
@property (nonatomic) Location *location;


- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end

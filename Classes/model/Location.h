//
//  Location.h
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NearbyObjectProtocol.h"

@interface Location : NSObject <NearbyObjectProtocol> {
	int iconMediaId;
	NSString *name;
	CLLocation *location;
	double error;
	NSString *objectType;
	nearbyObjectKind kind; //for the protocol
	int objectId;
	bool hidden;
    bool hasBeenViewed;
	bool forcedDisplay;	
	bool allowsQuickTravel;
	int qty;
    id delegate;
    int wiggle;
    int deleteWhenViewed;
}

@property(readwrite, assign) int locationId;
@property(copy, readwrite) NSString *name;
@property(readwrite, assign) int iconMediaId;

@property(copy, readwrite) CLLocation *location;
@property(readwrite) double error;
@property(copy, readwrite) NSString *objectType;
@property(readonly) nearbyObjectKind kind;
- (nearbyObjectKind) kind;
@property(unsafe_unretained, readonly) NSObject<NearbyObjectProtocol> *object;

@property(readwrite) int objectId;
@property(readwrite) bool hidden;
@property(readwrite) bool hasBeenViewed;
@property(readwrite) bool forcedDisplay;
@property(readwrite) bool allowsQuickTravel;
@property(readwrite) int qty;
@property(readwrite) int wiggle;
@property(readwrite) int deleteWhenViewed;
@property(nonatomic)id delegate;
- (void) display;
- (BOOL)compareTo: (Location *)other;

@end

//
//  NearbyObjectProtocol.h
//  ARIS
//
//  Created by Brian Deith on 5/15/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

enum {
	NearbyObjectNil			= 0,
	NearbyObjectNPC			= 1,
	NearbyObjectItem		= 2,
	NearbyObjectNode		= 3,
	NearbyObjectPlayer		= 4,
    NearbyObjectWebPage     = 5,
    NearbyObjectPanoramic   = 6,
    NearbyObjectNote        = 7,
};
typedef UInt32 nearbyObjectKind;

@protocol NearbyObjectProtocol
- (NSString *)		 name;
- (nearbyObjectKind) kind;
- (BOOL)		     forcedDisplay;
- (void)		     display;
- (int)				 iconMediaId;
- (int)              fromLocationId;
- (int)              locationId;

- (void) setLocationId:(int) locationId;

@end

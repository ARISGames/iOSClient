//
//  NearbyObjectProtocol.h
//  ARIS
//
//  Created by Brian Deith on 5/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

enum {
	NearbyObjectNPC			= 1,
	NearbyObjectItem		= 2,
	NearbyObjectNode		= 3
};
typedef UInt32 nearbyObjectKind;


@protocol NearbyObjectProtocol
- (NSString *)name; 
- (nearbyObjectKind)kind;
- (BOOL)forcedDisplay;
- (void)display;
@end

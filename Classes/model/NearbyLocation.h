//
//  NearbyLocation.h
//  ARIS
//
//  Created by David Gagnon on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"

@interface NearbyLocation : NSObject <NearbyObjectProtocol> {
	NSString *name;
	nearbyObjectKind kind;
	BOOL forcedDisplay;
	
	int locationId;
//	bool forceView;
	NSString *type;
	NSString *iconURL;
	NSString *URL;
}


@property(copy, readwrite) NSString *name;
@property(readwrite, assign) nearbyObjectKind kind;
@property(readonly, assign) BOOL forcedDisplay;

@property(readwrite, assign) int locationId;
- (void) setForcedDisplay:(NSString *)fromStringValue;

@property(copy, readonly) NSString *type;
- (void)setType:(NSString *) fromStringValue;

@property(copy, readwrite) NSString *iconURL;
@property(copy, readwrite) NSString *URL;


@end

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
	NSString *type;
	NSString *iconURL;
	NSString *URL;
}


@property(copy, readwrite) NSString *name;
@property(readwrite, assign) nearbyObjectKind kind;
@property(readwrite, assign) BOOL forcedDisplay;

@property(readwrite, assign) int locationId;
@property(copy, readwrite) NSString *type;
@property(copy, readwrite) NSString *iconURL;
@property(copy, readwrite) NSString *URL;


@end

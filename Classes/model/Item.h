//
//  Item.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"
#import "QRCodeProtocol.h"

@interface Item : NSObject <NearbyObjectProtocol,QRCodeProtocol> {
	NSString *name;
	nearbyObjectKind kind;
	BOOL forcedDisplay;
	
	int itemId;
	int locationId; //null if in the player's inventory
	NSString *description;
	NSString *type;
	NSString *mediaURL;
	NSString *iconURL;
}

@property(copy, readwrite) NSString *name;
@property(readwrite, assign) nearbyObjectKind kind;
- (nearbyObjectKind) kind;
@property(readwrite, assign) BOOL forcedDisplay;

@property(readonly, assign) int itemId;
@property(readonly, assign) int locationId;
- (void) setItemId:(NSString *)fromStringValue;
- (void) setLocationId:(NSString *)fromStringValue;

@property(copy, readwrite) NSString *description;
@property(copy, readwrite) NSString *type;
@property(copy, readwrite) NSString *mediaURL;
@property(copy, readwrite) NSString *iconURL;

- (void) display;

@end

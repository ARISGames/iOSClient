//
//  Item.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"
#import "QRCodeProtocol.h"

@interface Item : NSObject <NearbyObjectProtocol,QRCodeProtocol> {
	int itemId;
	NSString *name;
	int mediaId;
	int iconMediaId;
	int locationId; //null if in the player's inventory
	NSString *description;	
	BOOL forcedDisplay;
	BOOL dropable;
	BOOL destroyable;
	nearbyObjectKind kind;
}

@property(copy, readwrite) NSString *name;
@property(readwrite, assign) nearbyObjectKind kind;
- (nearbyObjectKind) kind;
@property(readwrite, assign) BOOL forcedDisplay;
@property(readwrite, assign) int itemId;
@property(readwrite, assign) int locationId;
@property(readwrite, assign) int mediaId;
@property(copy, readwrite) NSString *description;
@property(readwrite, assign) int iconMediaId;
@property (readwrite, assign) BOOL dropable;
@property (readwrite, assign) BOOL destroyable;

- (void) display;


@end

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
	//int locationId; //null if in the player's inventory
	int qty;
	int maxQty;
    int weight;
	NSString *description;	
    BOOL isAttribute;
	BOOL forcedDisplay;
	BOOL dropable;
	BOOL destroyable;
    BOOL hasViewed;
	nearbyObjectKind kind;
    NSString *url;
    NSString *type;
    int creatorId;
}

@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *type;

@property(readwrite, assign) nearbyObjectKind kind;
- (nearbyObjectKind) kind;
@property(readwrite, assign) BOOL forcedDisplay;
@property(readwrite, assign) BOOL hasViewed;
@property(readwrite, assign) int itemId;
@property(readwrite, assign) int creatorId;

@property(readwrite, assign) int locationId;
@property(readwrite, assign) int mediaId;

@property(readwrite, assign) int weight;
@property(readwrite, assign) int qty;
@property(readwrite, assign) int maxQty;
@property(copy, readwrite) NSString *description;
@property(readwrite, assign) int iconMediaId;
@property (readwrite, assign) BOOL dropable;
@property (readwrite, assign) BOOL destroyable;
@property (readwrite, assign) BOOL isAttribute;

@property (nonatomic) NSString *url;


- (void) display;
- (Item *)   copyItem;


@end

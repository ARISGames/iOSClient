//
//  NPC.h
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"
#import "QRCodeProtocol.h"
#import "NodeOption.h"

@interface Npc : NSObject  <NearbyObjectProtocol,QRCodeProtocol>{
	nearbyObjectKind kind;
	int npcId;
	NSString *name;
	NSString *greeting;
	NSString *closing;
	NSString *description;
	int	mediaId;
	int iconMediaId;
	CLLocation *location;
	BOOL forcedDisplay; //We only need this for the proto, might be good to define a new one
}

@property(readwrite, assign) nearbyObjectKind kind;
- (nearbyObjectKind) kind;
@property(readwrite, assign) int npcId;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *greeting;
@property(copy, readwrite) NSString *closing;
@property(copy, readwrite) NSString *description;
@property(readwrite, assign) int mediaId;
@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) int locationId;

@property(readwrite, assign) BOOL forcedDisplay; //see note above


- (void) display;





@end

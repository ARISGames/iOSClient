//
//  NPC.h
//  ARIS
//
//  Created by Kevin Harris on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"

@interface NPC : NSObject {
	NSString *name;
	nearbyObjectKind kind;
	BOOL forcedDisplay;
	
	NSString *description;
	NSString *mediaURL;
	NSInteger npcID;
	NSMutableArray *options;	
}

@property(readwrite, copy) NSString *name;
@property(readwrite, assign) nearbyObjectKind kind;
@property(readwrite, assign) BOOL forcedDisplay;

@property(readwrite, copy) NSString *description;
@property(readwrite, copy) NSString *mediaURL;
@property(readwrite) NSInteger npcID;
@property(readonly) NSMutableArray *options;

- (void)display;

@end

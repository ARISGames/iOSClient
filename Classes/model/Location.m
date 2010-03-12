//
//  Location.m
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "Item.h"
#import "Node.h"
#import "Npc.h"


@implementation Location

@synthesize locationId;
@synthesize name;
@synthesize iconMediaId;
@synthesize location;
@synthesize error;
@synthesize objectType;
@synthesize objectId;
@synthesize hidden;
@synthesize forcedDisplay;
@synthesize qty;

-(nearbyObjectKind) kind {
	nearbyObjectKind returnValue = NearbyObjectNil;
	if ([self.objectType isEqualToString:@"Node"]) returnValue = NearbyObjectNode;
	if ([self.objectType isEqualToString:@"Npc"]) returnValue = NearbyObjectNPC;
	if ([self.objectType isEqualToString:@"Item"]) returnValue = NearbyObjectItem;
	if ([self.objectType isEqualToString:@"Player"]) returnValue = NearbyObjectPlayer;
	return returnValue;
}

- (void)display {
	ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	AppModel *model = [appDelegate appModel];
	
	if (self.kind == NearbyObjectItem) {
		Item *item = [model fetchItem:objectId]; 
		item.locationId = self.locationId;
		[item display];	
	}
	
	if (self.kind == NearbyObjectNode) {
		Node *node = [model fetchNode:objectId]; 
		[node display];	
	}
	
	if (self.kind == NearbyObjectNPC) {
		Npc *npc = [model fetchNpc:objectId]; 
		[npc display];	
	}
}

- (void)dealloc {
	[name release];
    [super dealloc];
}

@end

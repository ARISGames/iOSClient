//
//  NearbyLocation.m
//  ARIS
//
//  Created by David Gagnon on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NearbyLocation.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
//#import "GenericWebViewController.h"
#import "NodeViewController.h"

@implementation NearbyLocation

@synthesize name;
@synthesize kind;
@synthesize forcedDisplay;

@synthesize locationId;
//@synthesize forceView;
@synthesize type;
@synthesize iconURL;
@synthesize URL;

- (void)setForcedDisplay: (NSString *)fromStringValue {
	forcedDisplay = [fromStringValue boolValue];
}

- (void)setType:(NSString *) fromStringValue {
	type = fromStringValue;
	if ([fromStringValue isEqualToString:@"node"]) kind = NearbyObjectNode;
	else if ([fromStringValue isEqualToString:@"npc"]) kind = NearbyObjectNPC;
}

- (void) display{
	NSLog(@"NearbyLocation (Web Style): Display Self Requested");
	
	ARISAppDelegate *delegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	switch (self.kind) {
		case NearbyObjectNode:
			[[delegate appModel] fetchNode:URL];
			break;
		case NearbyObjectNPC:
			[[delegate appModel] fetchConversations:URL];
			break;
		default:
			NSLog(@"WARNING NearbyLocation: Unhandled kind %d", self.kind);
			break;
	}
}

- (void)dealloc {
	[name release];
	[type release];
	[iconURL release];
	[URL release];
    [super dealloc];
}

@end

//
//  NPC.m
//  ARIS
//
//  Created by Kevin Harris on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NPC.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "ConversationController.h"

@implementation NPC
@synthesize name, kind, forcedDisplay, description, mediaURL, npcID, options;

- (id)init {
	self = [super init];
    if ( self ) {
		self.kind = NearbyObjectNPC;
		options = [[NSMutableArray alloc] initWithCapacity:3];
    }
	
    return self;
}

- (void)display {
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	ConversationController *conversationController = [[ConversationController alloc] initWithNibName:@"Conversations"
																							  bundle:[NSBundle mainBundle]];
	[conversationController retain];
	conversationController.npc = self;
	[appDelegate displayNearbyObjectView:conversationController];
}

@end

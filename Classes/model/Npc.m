//
//  NPC.m
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "DialogViewController.h"
#import "Npc.h"

@implementation Npc
@synthesize npcId;
@synthesize name;
@synthesize greeting;
@synthesize description;
@synthesize mediaId;
@synthesize kind;
@synthesize forcedDisplay;
@synthesize numberOfOptions;
@synthesize options;


-(nearbyObjectKind) kind {
	return NearbyObjectNPC;
}

- (Npc *)init {
	self = [super init];
    if (self) {
		options = [[NSMutableArray alloc] init];
    }
	
    return self;	
}

- (NSInteger) numberOfOptions {
	return [options count];
}

- (void) addOption:(NodeOption *)newOption{
	[options addObject:newOption];
}

- (void) display{
	NSLog(@"Npc: Display Self Requested");
	DialogViewController *dialogController = [[DialogViewController alloc] initWithNibName:@"Dialog"
																					bundle:[NSBundle mainBundle]];
	[dialogController beginWithNPC:self];
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate displayNearbyObjectView:dialogController];
	[dialogController release];
}


- (void) dealloc {
	[name release];
	[description release];
	[greeting release];
	[options release];
	[location release];
	[super dealloc];
}
 

@end

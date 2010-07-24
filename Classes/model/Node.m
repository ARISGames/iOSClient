//
//  Node.m
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Node.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "NodeViewController.h"

@implementation Node
@synthesize nodeId, name, text, mediaId, kind, forcedDisplay, numberOfOptions, options;
@synthesize answerString, nodeIfCorrect, nodeIfIncorrect;

-(nearbyObjectKind) kind { return NearbyObjectNode; }

- (Node *) init {
    if (self = [super init]) {
		kind = NearbyObjectNode;
		options = [[NSMutableArray alloc] init];
    }
	
    return self;	
}


- (void) display{
	NSLog(@"Node: Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;

	NodeViewController *nodeViewController = [[NodeViewController alloc] initWithNibName:@"Node" bundle: [NSBundle mainBundle]];
	nodeViewController.node = self; //currentNode;
	nodeViewController.appModel = appModel;
	
	[appDelegate displayNearbyObjectView:nodeViewController];
	[nodeViewController release];
}

- (NSInteger) numberOfOptions {
	return [options count];
}

- (void) addOption:(NodeOption *)newOption{
	[options addObject:newOption];
}


- (void) dealloc {
	[name release];
	[text release];
	[options release];
	[answerString release];
	[super dealloc];
}
 


@end

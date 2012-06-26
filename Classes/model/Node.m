//
//  Node.m
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Node.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "NodeViewController.h"

@implementation Node
@synthesize nodeId, name, text, mediaId, iconMediaId, kind, forcedDisplay, numberOfOptions, options;
@synthesize answerString, nodeIfCorrect, nodeIfIncorrect, locationId;

-(nearbyObjectKind) kind { return NearbyObjectNode; }

- (Node *) init {
    if (self = [super init]) {
		kind = NearbyObjectNode;
		options = [[NSMutableArray alloc] init];
    }
    return self;	
}

- (int) iconMediaId {
	return 3; 
}

- (void) display{
	NSLog(@"Node: Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];

	NodeViewController *nodeViewController = [[NodeViewController alloc] initWithNibName:@"Node" bundle: [NSBundle mainBundle]];
	nodeViewController.node = self; //currentNode;
	
	[appDelegate displayNearbyObjectView:nodeViewController];
}

- (NSInteger) numberOfOptions {
	return [options count];
}

- (void) addOption:(NodeOption *)newOption{
	[options addObject:newOption];
}


 


@end

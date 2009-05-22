//
//  Node.m
//  ARIS
//
//  Created by Kevin Harris on 5/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "Node.h"
#import "NodeViewController.h"
#import "Option.h"

@implementation Node

@synthesize name, numberOfOptions, kind, forcedDisplay, description, options;

- (Node *)init {
	self = [super init];
    if (self) {
		options = [[NSArray alloc] initWithObjects:
			[[Option alloc] init],
			[[Option alloc] init],
			[[Option alloc] init],
		 nil];
		kind = NearbyObjectNode;
    }
	
    return self;	
}


- (void)display {
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
	
	if ([appDelegate isPushedViewControllerA:[NodeViewController class]]) {
		NodeViewController *nodeViewController = (NodeViewController *)appDelegate.pushedViewController;
		nodeViewController.node = self;
		[nodeViewController refreshView];
	}
	else {
		NodeViewController *nodeViewController = [[NodeViewController alloc] initWithNibName:@"Node"
																					  bundle:[NSBundle mainBundle]];
		[nodeViewController retain];
	
		nodeViewController.node = self; //currentNode;
		nodeViewController.appModel = appModel;
	
		[appDelegate displayNearbyObjectView:nodeViewController];
	}
}

- (void) setOptionOneText:(NSString *)fromStringValue {
	[self setOption:@selector(setText:) atIndex:0 fromStringValue:fromStringValue];
}

- (void) setOptionOneId:(NSString *)fromStringValue {
	[self setOption:@selector(setNodeId:) atIndex:0 fromStringValue:fromStringValue];
}

- (void) setOptionTwoText:(NSString *)fromStringValue {
	[self setOption:@selector(setText:) atIndex:1 fromStringValue:fromStringValue];
}

- (void) setOptionTwoId:(NSString *)fromStringValue {
	[self setOption:@selector(setNodeId:) atIndex:1 fromStringValue:fromStringValue];
}

- (void) setOptionThreeText:(NSString *)fromStringValue {
	[self setOption:@selector(setText:) atIndex:2 fromStringValue:fromStringValue];
}

- (void) setOptionThreeId:(NSString *)fromStringValue {
	[self setOption:@selector(setNodeId:) atIndex:2 fromStringValue:fromStringValue];
}

- (void) setOption:(SEL)selector atIndex:(NSUInteger)index fromStringValue:(NSString *)value {
	if ([value isEqualToString:@""]) return;
	
	Option *option = [options objectAtIndex:index];
	if (selector == @selector(setText:)) {
		option.text = value;
	}
	else if (selector == @selector(setNodeId:)) {
		option.nodeId = [value intValue];
	}
	else {
		@throw([NSException exceptionWithName:@"InvalidOption" 
									   reason:@"Selector not valid in Node::setOption:"
									 userInfo:nil]);
	}
	numberOfOptions = index + 1;
}

@end

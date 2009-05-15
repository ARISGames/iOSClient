//
//  Item.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "ItemDetailsViewController.h"


@implementation Item

@synthesize name;
@synthesize kind;
@synthesize forcedDisplay;

@synthesize itemId;
@synthesize locationId;
@synthesize description;
@synthesize type;
@synthesize mediaURL;
@synthesize iconURL;


- (void) display{
	NSLog(@"Item: Display Self Requested");
	ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] 
															initWithNibName:@"ItemDetailsView" bundle:[NSBundle mainBundle]];
	//itemDetailsViewController.appModel = appModel;
	itemDetailsViewController.item = self;
	itemDetailsViewController.inInventory = NO;
	
	//Put the view on the screen
	//[[self navigationController] pushViewController:itemDetailsViewController animated:YES];
}

- (void)dealloc {
	[name release];
	[description release];
	[type release];
	[mediaURL release];
	[iconURL release];
    [super dealloc];
}

@end

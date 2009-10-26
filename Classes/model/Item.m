//
//  Item.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "ItemDetailsViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"


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

- (void) setItemId:(NSString *)fromStringValue {
	itemId = [fromStringValue intValue];
}

- (void) setLocationId:(NSString *)fromStringValue {
	locationId = [fromStringValue intValue];
}

-(nearbyObjectKind) kind {
	return NearbyObjectItem;
}

- (void) display{
	NSLog(@"Item: Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
		
	ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] 
															initWithNibName:@"ItemDetailsView" bundle:[NSBundle mainBundle]];
	itemDetailsViewController.item = self;
	itemDetailsViewController.navigationItem.title = name;
	itemDetailsViewController.inInventory = NO;
	itemDetailsViewController.appModel = appModel;

	//Have AppDelegate display
	[appDelegate displayNearbyObjectView:itemDetailsViewController];

	
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

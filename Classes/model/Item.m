//
//  Item.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
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
@synthesize mediaId;
@synthesize locationId;
@synthesize description;
@synthesize iconMediaId;

@synthesize dropable;
@synthesize	destroyable;

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
	[itemDetailsViewController release];
	
}

- (BOOL)isEqual:(id)anObject {
	if (![anObject isKindOfClass:[Item class]]) return NO;
	Item *anItem = (Item*)anObject;
	if (anItem.itemId == self.itemId) return YES;
	return NO;
}

- (NSUInteger)hash {
	return itemId;
}


- (void)dealloc {
	[name release];
	[description release];
    [super dealloc];
}
 

@end

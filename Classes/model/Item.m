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

@synthesize name,url;
@synthesize kind,creatorId;
@synthesize forcedDisplay, hasViewed, isTradeable;

@synthesize itemId;
@synthesize mediaId;
@synthesize iconMediaId;
@synthesize locationId;
@synthesize weight,type;
@synthesize qty,maxQty;
@synthesize description;

@synthesize dropable;
@synthesize	destroyable,isAttribute;


-(nearbyObjectKind) kind {
	return NearbyObjectItem;
}

-(int)iconMediaId {
	if (iconMediaId == 0) return 2;
	else return iconMediaId;
}

- (void) display{
	NSLog(@"Item: Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
	ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] 
															initWithNibName:@"ItemDetailsView" bundle:[NSBundle mainBundle]];
	itemDetailsViewController.item = self;
	itemDetailsViewController.navigationItem.title = name;
	itemDetailsViewController.inInventory = NO;

	//Have AppDelegate display
	[[RootViewController sharedRootViewController] displayNearbyObjectView:itemDetailsViewController];
	
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

-(Item *)copyItem
{
    Item *itemCopy = [[Item alloc] init];
    itemCopy.itemId = self.itemId;
	itemCopy.name = self.name;
	itemCopy.mediaId = self.mediaId;
	itemCopy.iconMediaId = self.iconMediaId;
	itemCopy.qty = self.qty;
	itemCopy.maxQty = self.maxQty;
    itemCopy.weight = self.weight;
	itemCopy.description = self.description;	
    itemCopy.isAttribute = self.isAttribute;
	itemCopy.forcedDisplay = self.forcedDisplay;
	itemCopy.dropable = self.dropable;
	itemCopy.destroyable = self.destroyable;
    itemCopy.hasViewed = self.hasViewed;
	itemCopy.kind = self.kind;
    itemCopy.url = self.url;
    itemCopy.type = self.type;
    itemCopy.creatorId = self.creatorId;
    return itemCopy;
}

@end

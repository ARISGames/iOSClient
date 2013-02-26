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
@synthesize idescription;

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

-(Item *)copy
{
    Item *c = [[Item alloc] init];
    c.itemId        = self.itemId;
	c.name          = self.name;
	c.mediaId       = self.mediaId;
	c.iconMediaId   = self.iconMediaId;
	c.qty           = self.qty;
	c.maxQty        = self.maxQty;
    c.weight        = self.weight;
	c.idescription  = self.idescription;
    c.isAttribute   = self.isAttribute;
	c.forcedDisplay = self.forcedDisplay;
	c.dropable      = self.dropable;
	c.destroyable   = self.destroyable;
    c.hasViewed     = self.hasViewed;
	c.kind          = self.kind;
    c.url           = self.url;
    c.type          = self.type;
    c.creatorId     = self.creatorId;
    return c;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Item- Id:%d\tName:%@\tAttribute:%d\tQty:%d",self.itemId,self.name,self.isAttribute,self.qty];
}

@end

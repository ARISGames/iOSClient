//
//  Item.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Item.h"


@implementation Item

@synthesize itemId;
@synthesize name;
@synthesize description;
@synthesize type;
@synthesize mediaURL;
@synthesize iconURL;

- (void)dealloc {
	[name release];
	[description release];
	[type release];
	[mediaURL release];
	[iconURL release];
    [super dealloc];
}

@end

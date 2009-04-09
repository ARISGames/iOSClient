//
//  NearbyLocation.m
//  ARIS
//
//  Created by David Gagnon on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NearbyLocation.h"


@implementation NearbyLocation

@synthesize locationId;
@synthesize name;
@synthesize type;
@synthesize iconURL;
@synthesize URL;

- (void)dealloc {
	[name release];
	[type release];
	[iconURL release];
	[URL release];
    [super dealloc];
}

@end

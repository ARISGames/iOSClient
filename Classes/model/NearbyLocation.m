//
//  NearbyLocation.m
//  ARIS
//
//  Created by David Gagnon on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NearbyLocation.h"


@implementation NearbyLocation

@synthesize name;
@synthesize kind;
@synthesize forcedDisplay;

@synthesize locationId;
@synthesize forceView;
@synthesize type;
@synthesize iconURL;
@synthesize URL;

- (void) display{
	NSLog(@"NearbyLocation (Web Style): Display Self Requested");

}

- (void)dealloc {
	[name release];
	[type release];
	[iconURL release];
	[URL release];
    [super dealloc];
}

@end

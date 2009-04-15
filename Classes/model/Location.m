//
//  Location.m
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Location.h"


@implementation Location

@synthesize locationId;
@synthesize name;
@synthesize latitude;
@synthesize longitude;
@synthesize hidden;

- (void)dealloc {
	[name release];
    [super dealloc];
}

@end

//
//  Quest.m
//  ARIS
//
//  Created by David J Gagnon on 9/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Quest.h"


@implementation Quest

@synthesize questId;
@synthesize name;
@synthesize description;
@synthesize iconMediaId;


- (void) dealloc {
	[name release];
	[description release];
	[super dealloc];
}


@end

//
//  Quest.m
//  ARIS
//
//  Created by David J Gagnon on 9/3/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Quest.h"


@implementation Quest

@synthesize questId;
@synthesize name;
@synthesize description;
@synthesize iconMediaId;
@synthesize isNullQuest;


- (void) dealloc {
	[name release];
	[description release];
	[super dealloc];
}


@end

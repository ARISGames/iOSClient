//
//  Game.m
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "Game.h"

@implementation Game

@synthesize gameId;
@synthesize name;
@synthesize site;
@synthesize pcMediaId;

- (void)dealloc {
	[name release];
    [super dealloc];
}

@end

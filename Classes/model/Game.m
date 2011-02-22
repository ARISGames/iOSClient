//
//  Game.m
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "Game.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
 
@implementation Game

@synthesize gameId;
@synthesize name;
@synthesize description;
@synthesize pcMediaId;
@synthesize iconMediaId;
@synthesize numPlayers;
@synthesize location;
@synthesize distanceFromPlayer;
@synthesize authors;
@synthesize launchNodeId;
@synthesize completeNodeId;
@synthesize completedQuests;
@synthesize totalQuests;

- (void)dealloc {
	[name release];
	[description release];
	[authors release];
	[location release];	
    [super dealloc];
}

- (NSComparisonResult)compareDistanceFromPlayer:(Game*)otherGame{
	if (self.distanceFromPlayer < otherGame.distanceFromPlayer) return NSOrderedAscending;
	else if (self.distanceFromPlayer > otherGame.distanceFromPlayer) return NSOrderedDescending;
	else return NSOrderedSame;
}

@end

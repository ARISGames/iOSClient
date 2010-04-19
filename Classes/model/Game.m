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
@synthesize site;
@synthesize pcMediaId;
@synthesize location;

- (void)dealloc {
	[name release];
    [super dealloc];
}

- (NSComparisonResult)compareDistanceFromPlayer:(Game*)otherGame{
	if (self.distanceFromPlayer < otherGame.distanceFromPlayer) return NSOrderedAscending;
	else if (self.distanceFromPlayer > otherGame.distanceFromPlayer) return NSOrderedDescending;
	else return NSOrderedSame;
}

- (double)distanceFromPlayer {
	AppModel *appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
	if (appModel.playerLocation) return [self.location getDistanceFrom:appModel.playerLocation];
	else return 0;
}


@end

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
@synthesize inventoryWeightCap;
@synthesize name;
@synthesize description;
@synthesize distanceFromPlayer;
@synthesize rating;
@synthesize comments;
@synthesize authors;
@synthesize pcMediaId;
@synthesize mediaUrl;
@synthesize iconMediaUrl;
@synthesize numPlayers;
@synthesize location;
@synthesize launchNodeId;
@synthesize completeNodeId;
@synthesize completedQuests;
@synthesize totalQuests;
@synthesize numReviews;
@synthesize calculatedScore,isLocational, activeQuests;
@synthesize iconMedia,currentWeight,allowsPlayerTags,splashMedia;
- (id) init{
	if ((self = [super init])) {
		self.comments = [NSMutableArray arrayWithCapacity:5];
        
	}
	return self;
}



- (NSComparisonResult)compareDistanceFromPlayer:(Game*)otherGame{
	if (self.distanceFromPlayer < otherGame.distanceFromPlayer) return NSOrderedAscending;
	else if (self.distanceFromPlayer > otherGame.distanceFromPlayer) return NSOrderedDescending;
	else return NSOrderedSame;
}

- (NSComparisonResult)compareCalculatedScore:(Game*)otherGame{
	if (self.calculatedScore > otherGame.calculatedScore) return NSOrderedAscending;
	else if (self.calculatedScore < otherGame.calculatedScore) return NSOrderedDescending;
	else return NSOrderedSame;    
}

- (NSComparisonResult)compareTitle:(Game*)otherGame{
    return [self.name compare:otherGame.name]; 
}


@end

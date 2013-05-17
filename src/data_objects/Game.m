//
//  Game.m
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "Game.h"
#import "AppModel.h"
#import "AppServices.h"
 
@implementation Game

@synthesize gameId;
@synthesize inventoryModel;
@synthesize attributesModel;
@synthesize questsModel;
@synthesize locationsModel;
@synthesize mapType;
@synthesize hasBeenPlayed;
@synthesize name;
@synthesize gdescription;
@synthesize distanceFromPlayer;
@synthesize rating;
@synthesize comments;
@synthesize authors;
@synthesize pcMediaId;
@synthesize numPlayers;
@synthesize playerCount;
@synthesize location;
@synthesize launchNodeId;
@synthesize completeNodeId;
@synthesize numReviews, reviewedByUser;
@synthesize calculatedScore,isLocational, showPlayerLocation, iconMedia;
@synthesize allowsPlayerTags,splashMedia,allowNoteComments,allowNoteLikes,allowShareNoteToMap,allowShareNoteToList,allowTrading;

- (id)init
{
	if ((self = [super init]))
    {
		self.comments = [NSMutableArray arrayWithCapacity:5];
        self.reviewedByUser = NO;
	}
	return self;
}

- (void) getReadyToPlay
{
    self.inventoryModel  = [[InventoryModel  alloc] init];
    self.attributesModel = [[AttributesModel alloc] init];
    self.questsModel     = [[QuestsModel     alloc] init];
    self.locationsModel  = [[LocationsModel  alloc] init];
}

- (NSComparisonResult)compareDistanceFromPlayer:(Game*)otherGame{
	if      (self.distanceFromPlayer < otherGame.distanceFromPlayer) return NSOrderedAscending;
	else if (self.distanceFromPlayer > otherGame.distanceFromPlayer) return NSOrderedDescending;
	else                                                             return NSOrderedSame;
}

- (NSComparisonResult)compareCalculatedScore:(Game*)otherGame{
	if      (self.calculatedScore > otherGame.calculatedScore) return NSOrderedAscending;
	else if (self.calculatedScore < otherGame.calculatedScore) return NSOrderedDescending;
	else                                                       return NSOrderedSame;    
}

- (NSComparisonResult)compareTitle:(Game*)otherGame
{
    return [self.name compare:otherGame.name]; 
}

- (void) clearLocalModels
{
    [self.inventoryModel  clearData];
    [self.attributesModel clearData];
    [self.questsModel     clearData];
    [self.locationsModel  clearData];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Game- Id:%d\tName:%@",self.gameId,self.name];
}

@end

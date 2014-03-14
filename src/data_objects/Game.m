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
@synthesize name;
@synthesize desc;

@synthesize itemList;
@synthesize nodeList;
@synthesize npcList;
@synthesize webpageList;
@synthesize panoramicList;

@synthesize notesModel;
@synthesize inventoryModel;
@synthesize attributesModel;
@synthesize questsModel;
@synthesize locationsModel;
@synthesize overlaysModel;

@synthesize mapType;
@synthesize hasBeenPlayed;
@synthesize distanceFromPlayer;
@synthesize rating;
@synthesize comments;
@synthesize authors;
@synthesize pcMediaId;
@synthesize playerCount;
@synthesize location;
@synthesize launchNodeId;
@synthesize completeNodeId;
@synthesize numReviews;
@synthesize calculatedScore;
@synthesize isLocational;
@synthesize showPlayerLocation;
@synthesize iconMedia;
@synthesize allowsPlayerTags;
@synthesize splashMedia;
@synthesize allowNoteComments;
@synthesize allowNoteLikes;
@synthesize allowShareNoteToMap;
@synthesize allowShareNoteToList;
@synthesize latitude;
@synthesize longitude;
@synthesize zoomLevel;

- (id)init
{
	if(self = [super init])
    {
		self.comments = [NSMutableArray arrayWithCapacity:5];
	}
	return self;
}

- (void) getReadyToPlay
{
    self.notesModel      = [[NotesModel      alloc] init];
    self.inventoryModel  = [[InventoryModel  alloc] init];
    self.attributesModel = [[AttributesModel alloc] init];
    self.questsModel     = [[QuestsModel     alloc] init];
    self.locationsModel  = [[LocationsModel  alloc] init];
    self.overlaysModel   = [[OverlaysModel   alloc] init];
}

- (void) endPlay //to remove models while retaining the game stub for lists and such
{
    self.notesModel      = nil;
    self.inventoryModel  = nil;
    self.attributesModel = nil;
    self.questsModel     = nil;
    self.locationsModel  = nil; 
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

- (Npc *) npcForNpcId:(int)nId
{    
	return [self.npcList objectForKey:[NSNumber numberWithInt:nId]];
}

- (Node *) nodeForNodeId:(int)nId
{
	return [self.nodeList objectForKey:[NSNumber numberWithInt:nId]];
}

- (WebPage *) webpageForWebpageId:(int)wId
{
	return [self.webpageList objectForKey:[NSNumber numberWithInt:wId]];
}

- (Panoramic *) panoramicForPanoramicId:(int)pId
{
    return [self.panoramicList objectForKey:[NSNumber numberWithInt:pId]];
}

- (Item *) itemForItemId:(int)iId
{
	return [self.itemList objectForKey:[NSNumber numberWithInt:iId]];
}

- (void) clearLocalModels
{
    [self.notesModel      clearData];
    [self.inventoryModel  clearData];
    [self.attributesModel clearData];
    [self.questsModel     clearData];
    [self.locationsModel  clearData];
    [self.overlaysModel   clearData];
    [self.itemList      removeAllObjects];
    [self.nodeList      removeAllObjects];
    [self.npcList       removeAllObjects];
    [self.webpageList   removeAllObjects];
    [self.panoramicList removeAllObjects]; 
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Game- Id:%d\tName:%@",self.gameId,self.name];
}

- (void) dealloc
{
    
}

@end

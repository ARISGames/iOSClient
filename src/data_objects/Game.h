//
//  Game.h
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "InventoryModel.h"
#import "AttributesModel.h"
#import "QuestsModel.h"
#import "LocationsModel.h"
#import "Media.h"
#import "AsyncMediaImageView.h"


@interface Game : NSObject
{
	int gameId;

    InventoryModel  *inventoryModel;
    AttributesModel *attributesModel;
    QuestsModel     *questsModel;
    LocationsModel  *locationsModel;
    
    NSString *mapType;

	NSString *name;
	NSString *gdescription;
	NSString *authors;
    int rating;
    NSMutableArray *comments;
	double distanceFromPlayer;
	CLLocation *location;	
	int numPlayers;	
    int playerCount;
	int pcMediaId;
	int iconMediaId;
	int launchNodeId;
	int completeNodeId;
	int numReviews;
    BOOL reviewedByUser;
    int calculatedScore;
    BOOL hasBeenPlayed;
    BOOL isLocational;
    BOOL showPlayerLocation;
    BOOL allowsPlayerTags;
    BOOL allowShareNoteToMap;
    BOOL allowShareNoteToList;
    BOOL allowNoteComments;
    BOOL allowNoteLikes;
    BOOL allowTrading;
    Media *iconMedia;
    Media *splashMedia;

}

@property (readwrite, assign) int gameId;

@property (nonatomic, strong) InventoryModel *inventoryModel;
@property (nonatomic, strong) AttributesModel *attributesModel;
@property (nonatomic, strong) QuestsModel *questsModel;
@property (nonatomic, strong) LocationsModel *locationsModel;

@property (nonatomic, strong) NSString *mapType;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *gdescription;
@property (nonatomic, strong) NSString *authors;
@property (readwrite, assign) int rating;
@property (nonatomic, strong) NSMutableArray *comments;
@property (readwrite, assign) double distanceFromPlayer;
@property (nonatomic, strong) CLLocation *location;
@property (readwrite, assign) int pcMediaId;
@property (readwrite, assign) int numPlayers;
@property (readwrite, assign) int playerCount;
@property (readwrite, assign) int launchNodeId;
@property (readwrite, assign) int completeNodeId;
@property (readwrite, assign) int numReviews;
@property (readwrite) BOOL reviewedByUser;
@property (readwrite) BOOL hasBeenPlayed;
@property (readwrite) BOOL isLocational;
@property (readwrite) BOOL showPlayerLocation;
@property (readwrite) BOOL allowsPlayerTags;
@property (readwrite) BOOL allowShareNoteToMap;
@property (readwrite) BOOL allowShareNoteToList;
@property (readwrite) BOOL allowNoteComments;
@property (readwrite) BOOL allowNoteLikes;
@property (readwrite) BOOL allowTrading;

@property (readwrite, assign) int calculatedScore;
@property (nonatomic, strong) Media *iconMedia;
@property (nonatomic, strong) Media *splashMedia;

- (void) getReadyToPlay;
- (NSComparisonResult)compareDistanceFromPlayer:(Game*)otherGame;
- (NSComparisonResult)compareCalculatedScore:(Game*)otherGame;
- (NSComparisonResult)compareTitle:(Game*)otherGame;
- (void) clearLocalModels;

@end

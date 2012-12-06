//
//  Game.h
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Media.h"
#import "AsyncMediaImageView.h"


@interface Game : NSObject {
	int gameId;
    int inventoryWeightCap;
    int currentWeight;

	NSString *name;
	NSString *description;
	NSString *authors;
    int rating;
    NSMutableArray *comments;
	double distanceFromPlayer;
	CLLocation *location;	
	int numPlayers;	
    int playerCount;
	int pcMediaId;
	int iconMediaId;
    NSURL *iconMediaUrl;
    NSURL *mediaUrl;
	int launchNodeId;
	int completeNodeId;
	int completedQuests;
    int activeQuests;
	int totalQuests;
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

@property (readwrite, assign) int inventoryWeightCap;
@property (readwrite, assign) int currentWeight;

@property (readwrite, assign) int gameId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *description;
@property (nonatomic) NSString *authors;
@property (readwrite, assign) int rating;
@property (nonatomic) NSMutableArray *comments;
@property (readwrite, assign) double distanceFromPlayer;
@property (nonatomic) CLLocation *location;
@property (readwrite, assign) int pcMediaId;
@property (nonatomic) NSURL *iconMediaUrl;
@property (nonatomic) NSURL *mediaUrl;
@property (readwrite, assign) int numPlayers;
@property (readwrite, assign) int playerCount;
@property (readwrite, assign) int launchNodeId;
@property (readwrite, assign) int completeNodeId;
@property (readwrite, assign) int completedQuests;
@property (readwrite, assign) int activeQuests;
@property (readwrite, assign) int totalQuests;
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
@property (nonatomic) Media *iconMedia;
@property (nonatomic) Media *splashMedia;


- (NSComparisonResult)compareDistanceFromPlayer:(Game*)otherGame;
- (NSComparisonResult)compareCalculatedScore:(Game*)otherGame;
- (NSComparisonResult)compareTitle:(Game*)otherGame;


@end

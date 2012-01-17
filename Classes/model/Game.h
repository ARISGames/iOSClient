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
#import "AsyncImageView.h"


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
	int pcMediaId;
	int iconMediaId;
    NSString *iconMediaUrl;
    NSString *mediaUrl;
	int launchNodeId;
	int completeNodeId;
	int completedQuests;
    int activeQuests;
	int totalQuests;
	int numReviews;
    int calculatedScore;
    BOOL isLocational;
    BOOL allowsPlayerTags;
    Media *iconMedia;
}

@property(readwrite, assign) int inventoryWeightCap;
@property(readwrite, assign) int currentWeight;

@property(readwrite, assign) int gameId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) NSString *authors;
@property(readwrite, assign) int rating;
@property(nonatomic, retain) NSMutableArray *comments;
@property(readwrite, assign) double distanceFromPlayer;
@property(nonatomic, retain) CLLocation *location;
@property(readwrite, assign) int pcMediaId;
@property(nonatomic, retain) NSString *iconMediaUrl;
@property(nonatomic, retain) NSString *mediaUrl;
@property(readwrite, assign) int numPlayers;
@property(readwrite, assign) int launchNodeId;
@property(readwrite, assign) int completeNodeId;
@property(readwrite, assign) int completedQuests;
@property(readwrite, assign) int activeQuests;
@property(readwrite, assign) int totalQuests;
@property(readwrite, assign) int numReviews;
@property (readwrite) BOOL isLocational;
@property (readwrite) BOOL allowsPlayerTags;

@property(readwrite, assign) int calculatedScore;
@property(nonatomic, retain) Media *iconMedia;


- (NSComparisonResult)compareDistanceFromPlayer:(Game*)otherGame;
- (NSComparisonResult)compareCalculatedScore:(Game*)otherGame;
- (NSComparisonResult)compareTitle:(Game*)otherGame;


@end

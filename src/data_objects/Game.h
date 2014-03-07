//
//  Game.h
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NotesModel.h"
#import "InventoryModel.h"
#import "AttributesModel.h"
#import "QuestsModel.h"
#import "LocationsModel.h"
#import "Media.h"
#import "OverlaysModel.h"

@class Item;
@class Npc;
@class Node;
@class WebPage;
@class Panoramic;

@interface Game : NSObject
{
	int gameId;
   	NSString *name;
	NSString *desc; 

    NSMutableDictionary *itemList;
    NSMutableDictionary *nodeList;
    NSMutableDictionary *npcList;
    NSMutableDictionary *webpageList;
    NSMutableDictionary *panoramicList;
    
    NotesModel      *notesModel;
    InventoryModel  *inventoryModel; 
    AttributesModel *attributesModel;
    QuestsModel     *questsModel;
    LocationsModel  *locationsModel;
    OverlaysModel   *overlaysModel;
    
    NSString *mapType;
    Media *iconMedia;
    Media *splashMedia; 

	NSString *authors;
    int rating;
    NSMutableArray *comments;
	double distanceFromPlayer;
	CLLocation *location;	
    int playerCount;
	int pcMediaId;
	int iconMediaId;
	int launchNodeId;
	int completeNodeId;
	int numReviews;
    int calculatedScore;
    BOOL hasBeenPlayed;
    BOOL isLocational;
    BOOL showPlayerLocation;
    BOOL allowsPlayerTags;
    BOOL allowShareNoteToMap;
    BOOL allowShareNoteToList;
    BOOL allowNoteComments;
    BOOL allowNoteLikes;
    
    double latitude;
    double longitude; 
    double zoomLevel;  
}

@property (readwrite, assign) int gameId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;

@property (nonatomic, strong) NSMutableDictionary *itemList;
@property (nonatomic, strong) NSMutableDictionary *nodeList;
@property (nonatomic, strong) NSMutableDictionary *npcList;
@property (nonatomic, strong) NSMutableDictionary *webpageList;
@property (nonatomic, strong) NSMutableDictionary *panoramicList;

@property (nonatomic, strong) NotesModel *notesModel;
@property (nonatomic, strong) InventoryModel *inventoryModel;
@property (nonatomic, strong) AttributesModel *attributesModel;
@property (nonatomic, strong) QuestsModel *questsModel;
@property (nonatomic, strong) LocationsModel *locationsModel;
@property (nonatomic, strong) OverlaysModel *overlaysModel;

@property (nonatomic, strong) NSString *mapType;

@property (nonatomic, strong) NSString *authors;
@property (readwrite, assign) int rating;
@property (nonatomic, strong) NSMutableArray *comments;
@property (readwrite, assign) double distanceFromPlayer;
@property (nonatomic, strong) CLLocation *location;
@property (readwrite, assign) int pcMediaId;
@property (readwrite, assign) int playerCount;
@property (readwrite, assign) int launchNodeId;
@property (readwrite, assign) int completeNodeId;
@property (readwrite, assign) int numReviews;
@property (readwrite, assign) BOOL hasBeenPlayed;
@property (readwrite, assign) BOOL isLocational;
@property (readwrite, assign) BOOL showPlayerLocation;
@property (readwrite, assign) BOOL allowsPlayerTags;
@property (readwrite, assign) BOOL allowShareNoteToMap;
@property (readwrite, assign) BOOL allowShareNoteToList;
@property (readwrite, assign) BOOL allowNoteComments;
@property (readwrite, assign) BOOL allowNoteLikes;

@property (readwrite, assign) double latitude;
@property (readwrite, assign) double longitude;
@property (readwrite, assign) double zoomLevel;

@property (readwrite, assign) int calculatedScore;
@property (nonatomic, strong) Media *iconMedia;
@property (nonatomic, strong) Media *splashMedia;

- (void) getReadyToPlay;
- (NSComparisonResult)compareDistanceFromPlayer:(Game*)otherGame;
- (NSComparisonResult)compareCalculatedScore:(Game*)otherGame;
- (NSComparisonResult)compareTitle:(Game*)otherGame;
- (void) clearLocalModels;

- (Npc *) npcForNpcId:(int)mId;
- (Node *) nodeForNodeId:(int)mId;
- (WebPage *) webpageForWebpageId:(int)mId;
- (Panoramic *) panoramicForPanoramicId:(int)mId;
- (Item *) itemForItemId:(int)mId;

@end

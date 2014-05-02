//
//  AppModel.h
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreData/CoreData.h>

@class Game;
@class Player;
@class Media;
@class Location;
@class Item;
@class Node;
@class Npc;
@class WebPage;

@class ARISServiceGraveyard;
@class MediaModel;
@class Overlay;

@interface AppModel : NSObject
{
	NSURL *serverURL;
    BOOL showGamesInDevelopment;
    BOOL showPlayerOnMap;
    
    BOOL disableLeaveGame;
    int skipGameDetails;
    
	Game *currentGame;
    Player *player;
    CLLocation *deviceLocation;
    
    int fallbackGameId;
    
    NSMutableArray *oneGameGameList;
	NSMutableArray *nearbyGameList;
	NSMutableArray *anywhereGameList;
    NSMutableArray *popularGameList;
    NSMutableArray *recentGamelist;
    NSMutableArray *searchGameList;
    
	NSMutableArray *nearbyLocationsList;
    
    BOOL overlayIsVisible;
    
    BOOL hidePlayers;
    
    //CORE Data
    NSManagedObjectContext *mediaManagedObjectContext;
    NSManagedObjectContext *requestsManagedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    ARISServiceGraveyard *servicesGraveyard;
    MediaModel *mediaModel;
    
    CMMotionManager *motionManager;
}

@property (nonatomic, strong) NSURL *serverURL;
@property (readwrite) BOOL showGamesInDevelopment;
@property (readwrite) BOOL showPlayerOnMap;
@property (readwrite) BOOL disableLeaveGame;
@property (readwrite) int  skipGameDetails;

@property (readwrite) BOOL hidePlayers;

@property (readwrite) BOOL overlayIsVisible;

@property (readwrite) int fallbackGameId;//Used only to recover from crashes

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) Game *currentGame;
@property (nonatomic, strong) CLLocation *deviceLocation;

@property (nonatomic, strong) NSMutableArray *oneGameGameList;
@property (nonatomic, strong) NSMutableArray *nearbyGameList;
@property (nonatomic, strong) NSMutableArray *anywhereGameList;
@property (nonatomic, strong) NSMutableArray *searchGameList;
@property (nonatomic, strong) NSMutableArray *popularGameList;
@property (nonatomic, strong) NSMutableArray *recentGameList;	

@property (nonatomic, strong) NSMutableArray *nearbyLocationsList;	

// CORE Data
@property (nonatomic, readonly) NSManagedObjectContext *mediaManagedObjectContext;
@property (nonatomic, readonly) NSManagedObjectContext *requestsManagedObjectContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) ARISServiceGraveyard *servicesGraveyard;
@property (nonatomic, strong) MediaModel *mediaModel;

@property (nonatomic, strong) CMMotionManager *motionManager;

+ (AppModel *) sharedAppModel;

- (void) resetAllGameLists;
- (void) resetAllPlayerLists;

- (void) commitPlayerLogin:(Player *)p;
- (void) setPlayerLocation:(CLLocation *)newLocation;

- (void) initUserDefaults;
- (void) saveUserDefaults;
- (void) loadUserDefaults;
- (void) commitCoreDataContexts;
- (NSString *) applicationDocumentsDirectory;

- (Media *) mediaForMediaId:(int)mId;

@end

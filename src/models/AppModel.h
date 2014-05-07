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

#define _MODEL_ [AppModel sharedAppModel]
#define _MODEL_GAME_ [AppModel sharedAppModel].currentGame
#define _MODEL_PLAYER_ [AppModel sharedAppModel].player
#define _MODEL_PLAQUES_ [AppModel sharedAppModel].currentGame.plaquesModel
#define _MODEL_ITEMS_ [AppModel sharedAppModel].currentGame.itemsModel
#define _MODEL_NPCS_ [AppModel sharedAppModel].currentGame.npcsModel
#define _MODEL_ITEMS_ [AppModel sharedAppModel].currentGame.itemsModel
#define _MODEL_WEBPAGES_ [AppModel sharedAppModel].currentGame.webPagesModel
#define _MODEL_MEDIA_ [AppModel sharedAppModel].mediaModel

@class Game;
@class User;
@class Media;
@class Location;

@class Plaque;
@class Item;
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
    User *player;
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

@property (nonatomic, strong) User *player;
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

- (void) commitPlayerLogin:(User *)p;
- (void) setPlayerLocation:(CLLocation *)newLocation;

- (void) initUserDefaults;
- (void) saveUserDefaults;
- (void) loadUserDefaults;
- (void) commitCoreDataContexts;
- (NSString *) applicationDocumentsDirectory;

@end

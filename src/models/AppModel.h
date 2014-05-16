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
#define _MODEL_PLAYER_ [AppModel sharedAppModel].player
#define _MODEL_GAME_ [AppModel sharedAppModel].game
#define _MODEL_PLAQUES_ [AppModel sharedAppModel].game.plaquesModel
#define _MODEL_ITEMS_ [AppModel sharedAppModel].game.itemsModel
#define _MODEL_NPCS_ [AppModel sharedAppModel].game.npcsModel
#define _MODEL_WEBPAGES_ [AppModel sharedAppModel].game.webPagesModel
#define _MODEL_MEDIA_ [AppModel sharedAppModel].mediaModel

#import "Game.h"
#import "User.h"
#import "PlaquesModel.h"
#import "ItemsModel.h"
#import "NpcsModel.h"
#import "WebPagesModel.h"
#import "MediaModel.h"

@class ARISServiceGraveyard;
@class MediaModel;

@interface AppModel : NSObject
{
  NSURL *serverURL;
  BOOL showGamesInDevelopment;
  BOOL showPlayerOnMap;

  BOOL disableLeaveGame;
  int skipGameDetails;
  int fallbackGameId;
  BOOL hidePlayers;

  User *player;
  Game *game;
  CLLocation *deviceLocation;

  NSMutableArray *oneGameGameList;
  NSMutableArray *nearbyGameList;
  NSMutableArray *anywhereGameList;
  NSMutableArray *popularGameList;
  NSMutableArray *recentGameList;
  NSMutableArray *searchGameList;

  //CORE Data
  NSManagedObjectContext *mediaManagedObjectContext;
  NSManagedObjectContext *requestsManagedObjectContext;
  NSPersistentStoreCoordinator *persistentStoreCoordinator;
  ARISServiceGraveyard *servicesGraveyard;
  MediaModel *mediaModel;

  CMMotionManager *motionManager;
}

@property(nonatomic, strong) NSURL *serverURL;
@property(nonatomic, assign) BOOL showGamesInDevelopment;
@property(nonatomic, assign) BOOL showPlayerOnMap;

@property(nonatomic, assign) BOOL disableLeaveGame;
@property(nonatomic, assign) int skipGameDetails;
@property(nonatomic, assign) int fallbackGameId;
@property(nonatomic, assign) BOOL hidePlayers;

@property(nonatomic, strong) User *player;
@property(nonatomic, strong) Game *game;
@property(nonatomic, strong) CLLocation *deviceLocation;

@property(nonatomic, strong) NSMutableArray *oneGameGameList;
@property(nonatomic, strong) NSMutableArray *nearbyGameList;
@property(nonatomic, strong) NSMutableArray *anywhereGameList;
@property(nonatomic, strong) NSMutableArray *popularGameList;
@property(nonatomic, strong) NSMutableArray *recentGameList;
@property(nonatomic, strong) NSMutableArray *searchGameList;

  //CORE Data
@property(nonatomic, strong) NSManagedObjectContext *mediaManagedObjectContext;
@property(nonatomic, strong) NSManagedObjectContext *requestsManagedObjectContext;
@property(nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong) ARISServiceGraveyard *servicesGraveyard;
@property(nonatomic, strong) MediaModel *mediaModel;

@property(nonatomic, strong) CMMotionManager *motionManager;

+ (AppModel *) sharedAppModel;

- (void) initUserDefaults;
- (void) saveUserDefaults;
- (void) loadUserDefaults;

- (void) attemptLogInWithUserName:(NSString *)user_name password:(NSString *)password;
- (void) createAccountWithUserName:(NSString *)user_name displayName:(NSString *)display_name email:(NSString *)email password:(NSString *)password;
- (void) logInPlayer:(User *)user;

- (void) setPlayerLocation:(CLLocation *)newLocation;

- (void) commitCoreDataContexts;
- (NSString *) applicationDocumentsDirectory;

@end

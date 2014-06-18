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
#define _MODEL_GAMES_ [AppModel sharedAppModel].gamesModel
#define _MODEL_MEDIA_ [AppModel sharedAppModel].mediaModel
#define _MODEL_GAME_ [AppModel sharedAppModel].game
#define _MODEL_PLAQUES_ [AppModel sharedAppModel].game.plaquesModel
#define _MODEL_ITEMS_ [AppModel sharedAppModel].game.itemsModel
#define _MODEL_DIALOGS_ [AppModel sharedAppModel].game.dialogsModel
#define _MODEL_WEBPAGES_ [AppModel sharedAppModel].game.webPagesModel
#define _MODEL_TRIGGERS_ [AppModel sharedAppModel].game.triggersModel
#define _MODEL_OVERLAYS_ [AppModel sharedAppModel].game.overlaysModel
#define _MODEL_INSTANCES_ [AppModel sharedAppModel].game.instancesModel
#define _MODEL_TABS_ [AppModel sharedAppModel].game.tabsModel
#define _MODEL_LOGS_ [AppModel sharedAppModel].game.logsModel

#import "User.h"
#import "GamesModel.h"
#import "MediaModel.h"
#import "ARISPusherHandler.h"

@class ARISServiceGraveyard;

@interface AppModel : NSObject
{
  NSString *serverURL;
  BOOL showGamesInDevelopment;
  BOOL showPlayerOnMap;

  BOOL disableLeaveGame;
  BOOL hidePlayers;

  User *player;
  Game *game;
  GamesModel *gamesModel;  
  MediaModel *mediaModel; 
  CLLocation *deviceLocation;

  //CORE Data
  NSManagedObjectContext *mediaManagedObjectContext;
  NSManagedObjectContext *requestsManagedObjectContext;
  NSPersistentStoreCoordinator *persistentStoreCoordinator;
  ARISServiceGraveyard *servicesGraveyard;

  CMMotionManager *motionManager;
}

@property(nonatomic, strong) NSString *serverURL;
@property(nonatomic, assign) BOOL showGamesInDevelopment;
@property(nonatomic, assign) BOOL showPlayerOnMap;

@property(nonatomic, assign) BOOL disableLeaveGame;
@property(nonatomic, assign) BOOL hidePlayers;

@property(nonatomic, strong) User *player;
@property(nonatomic, strong) Game *game;
@property(nonatomic, strong) GamesModel *gamesModel;
@property(nonatomic, strong) MediaModel *mediaModel;
@property(nonatomic, strong) CLLocation *deviceLocation;

  //CORE Data
@property(nonatomic, strong) NSManagedObjectContext *mediaManagedObjectContext;
@property(nonatomic, strong) NSManagedObjectContext *requestsManagedObjectContext;
@property(nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong) ARISServiceGraveyard *servicesGraveyard;

@property(nonatomic, strong) CMMotionManager *motionManager;

+ (AppModel *) sharedAppModel;

- (void) attemptLogInWithUserName:(NSString *)user_name password:(NSString *)password;
- (void) createAccountWithUserName:(NSString *)user_name displayName:(NSString *)display_name groupName:(NSString *)group_name email:(NSString *)email password:(NSString *)password;
- (void) logInPlayer:(User *)user;
- (void) logOut;

- (void) chooseGame:(Game *)game;
- (void) beginGame;
- (void) leaveGame;
- (void) resetGame;

- (void) setPlayerLocation:(CLLocation *)newLocation;

- (void) commitCoreDataContexts;
- (NSString *) applicationDocumentsDirectory;

@end

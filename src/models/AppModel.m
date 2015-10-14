//
//  AppModel.m
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AppModel.h"
#import "AppServices.h"
#import "ARISDefaults.h"

#import "User.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "Quest.h"
#import "ARISServiceGraveyard.h"
#import "MediaModel.h"
#import "ARISAlertHandler.h"

@interface AppModel()

@end

@implementation AppModel

@synthesize serverURL;
@synthesize showPlayerOnMap;
@synthesize preferred_game_id;
@synthesize leave_game_enabled;
@synthesize auto_profile_enabled;
@synthesize hidePlayers;
@synthesize player;
@synthesize game;
@synthesize usersModel;
@synthesize gamesModel;
@synthesize mediaModel;
@synthesize deviceLocation;
@synthesize mediaManagedObjectContext;
@synthesize requestsManagedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize servicesGraveyard;

+ (AppModel *) sharedAppModel
{
  static dispatch_once_t pred = 0;
  __strong static id _sharedObject = nil;
  dispatch_once(&pred, ^{ _sharedObject = [[self alloc] init]; });
  return _sharedObject;
}

- (id) init
{
  if(self = [super init])
  {
    leave_game_enabled = YES;
    auto_profile_enabled = YES;

    servicesGraveyard = [[ARISServiceGraveyard alloc] initWithContext:[self requestsManagedObjectContext]];
    usersModel        = [[UsersModel alloc] init];
    gamesModel        = [[GamesModel alloc] init];
    mediaModel        = [[MediaModel alloc] initWithContext:[self mediaManagedObjectContext]];

    _ARIS_NOTIF_LISTEN_(@"DEFAULTS_CLEAR", self, @selector(defaultsClear), nil);
    _ARIS_NOTIF_LISTEN_(@"DEFAULTS_UPDATED", self, @selector(defaultsUpdated), nil);
    _ARIS_NOTIF_LISTEN_(@"DEVICE_MOVED", self, @selector(deviceMoved:), nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_LOGIN_RECEIVED", self, @selector(loginReceived:), nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_LOGIN_FAILED", self, @selector(loginFailed:), nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_UPDATE_USER_RECEIVED", self, @selector(updateUserReceived:), nil);
  }
  return self;
}

- (void) defaultsClear
{
    if(_MODEL_.player) [self logOut];
}

- (void) defaultsUpdated
{
    if(_DEFAULTS_.fallbackUser)
    {
        if(_MODEL_.player && _MODEL_.player.user_id != _DEFAULTS_.fallbackUser.user_id) [self logOut];
        if(!_MODEL_.player) [self logInPlayer:_DEFAULTS_.fallbackUser];
    }
    if(_DEFAULTS_.fallbackGameId)
    {
        //do game loading stuff here
    }
    serverURL = _DEFAULTS_.serverURL;
    [_SERVICES_ setServer:_MODEL_.serverURL];
    showPlayerOnMap = _DEFAULTS_.showPlayerOnMap;
}

- (void) attemptLogInWithUserName:(NSString *)user_name password:(NSString *)password
{
  [_SERVICES_ logInUserWithName:user_name password:password];
}

- (void) createAccountWithUserName:(NSString *)user_name displayName:(NSString *)display_name groupName:(NSString *)group_name email:(NSString *)email password:(NSString *)password
{
  [_SERVICES_ createUserWithName:user_name displayName:display_name groupName:(NSString *)group_name email:email password:password];
}

- (void) generateUserFromGroup:(NSString *)group_name
{
  [_SERVICES_ generateUserFromGroup:group_name];
}

- (void) resetPasswordForEmail:(NSString *)email
{
  [_SERVICES_ resetPasswordForEmail:email];
}

- (void) changePasswordFrom:(NSString *)oldp to:(NSString *)newp
{
  [_SERVICES_ changePasswordFrom:oldp to:newp];
}

- (void) updatePlayerName:(NSString *)display_name
{
  [_SERVICES_ updatePlayerName:display_name];
}

- (void) updatePlayerMedia:(Media *)media
{
  [_SERVICES_ updatePlayerMedia:media];
}

- (void) loginReceived:(NSNotification *)n { [self logInPlayer:(User *)n.userInfo[@"user"]]; }
- (void) loginFailed:(NSNotification *)n { _ARIS_NOTIF_SEND_(@"MODEL_LOGIN_FAILED",nil,nil); }
- (void) updateUserReceived:(NSNotification *)n
{
    [_MODEL_PLAYER_ mergeDataFromUser:n.userInfo[@"user"]];
}
- (void) logInPlayer:(User *)p
{
  _MODEL_PLAYER_ = p;
  if(deviceLocation) _MODEL_PLAYER_.location = deviceLocation;
  [_DEFAULTS_ saveUserDefaults];
  [_PUSHER_ loginPlayer:_MODEL_PLAYER_.user_id];
  _ARIS_NOTIF_SEND_(@"MODEL_LOGGED_IN",nil,nil);

  //load the player media immediately if possible
  //if(_MODEL_PLAYER_.media_id != 0) [_SERVICES_ loadMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id] delegateHandle:nil];
}

- (void) logOut
{
  if(_MODEL_GAME_) [self leaveGame];
  _MODEL_PLAYER_ = nil;
  _MODEL_.auto_profile_enabled = YES;
  _MODEL_.leave_game_enabled = YES;
  [_DEFAULTS_ saveUserDefaults];
  [_PUSHER_ logoutPlayer];
  _ARIS_NOTIF_SEND_(@"MODEL_LOGGED_OUT",nil,nil);
}

- (void) chooseGame:(Game *)g
{
  _MODEL_GAME_ = g;
  [_MODEL_GAME_ getReadyToPlay];
  [_DEFAULTS_ saveUserDefaults];
  [_PUSHER_ loginGame:_MODEL_GAME_.game_id];
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_CHOSEN",nil,nil);
}

- (void) downloadGame:(Game *)g
{
  _MODEL_GAME_ = g;
  [_MODEL_GAME_ getReadyToPlay];
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_CHOSEN",nil,nil);
}

- (void) beginGame
{
  _MODEL_.preferred_game_id = 0; //assume the preference was met
  [_MODEL_ storeGame];
  [_MODEL_LOGS_ playerEnteredGame];
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_BEGAN",nil,nil);
}

- (void) leaveGame
{
  [_MODEL_GAME_ endPlay];
  _MODEL_GAME_ = nil;
  _MODEL_.leave_game_enabled = YES;
  [_DEFAULTS_ saveUserDefaults];
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_LEFT",nil,nil);
}

- (void) deviceMoved:(NSNotification *)n
{
    //don't report meaningless diffs
    if(!deviceLocation || [deviceLocation distanceFromLocation:n.userInfo[@"location"]] > 0.01f)
        [self setDeviceLocation:n.userInfo[@"location"]];
}

- (void) setDeviceLocation:(CLLocation *)l
{
  deviceLocation = l;
  [self setPlayerLocation:l];
}

- (void) setPlayerLocation:(CLLocation *)l
{
  if(!player) return;
  player.location = l;
  if(_MODEL_GAME_)[_MODEL_LOGS_ playerMoved];
}

- (NSString *) applicationDocumentsDirectory
{
  return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSManagedObjectContext *) mediaManagedObjectContext
{
  if(!mediaManagedObjectContext)
  {
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(coordinator)
    {
      mediaManagedObjectContext = [[NSManagedObjectContext alloc] init];
      [mediaManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
  }
  return mediaManagedObjectContext;
}

- (NSManagedObjectContext *) requestsManagedObjectContext
{
  if(!requestsManagedObjectContext)
  {
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(coordinator)
    {
      requestsManagedObjectContext = [[NSManagedObjectContext alloc] init];
      [requestsManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
  }
  return requestsManagedObjectContext;
}

- (void) storeGame
{
  NSError *error;
  
  NSData *data;
  NSString *file;
  
  NSString *folder = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",_MODEL_GAME_.game_id]];
  [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
  
  data = [[_MODEL_GAME_ serialize] dataUsingEncoding:NSUTF8StringEncoding];
  file = [folder stringByAppendingPathComponent:@"game.json"];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  
  ARISModel *m;
  for(long i = 0; i < _MODEL_GAME_.models.count; i++)
  {
    m = _MODEL_GAME_.models[i];
    data = [[m serializeGameData] dataUsingEncoding:NSUTF8StringEncoding];
    file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_game.json",m.serializedName]];
    [data writeToFile:file atomically:YES];
    [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  }
  for(long i = 0; i < _MODEL_GAME_.models.count; i++)
  {
    m = _MODEL_GAME_.models[i];
    data = [[m serializePlayerData] dataUsingEncoding:NSUTF8StringEncoding];
    file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",m.serializedName]];
    [data writeToFile:file atomically:YES];
    [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  }
  _MODEL_GAME_.downloadedVersion = _MODEL_GAME_.version;
}

- (void) restoreGame
{
  [self restoreGameData];
  [self restorePlayerData];
}
- (void) restoreGameData
{
  NSError *error;
  NSString *file;

  NSString *folder = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",_MODEL_GAME_.game_id]];

  ARISModel *m;
  for(long i = 0; i < _MODEL_GAME_.models.count; i++)
  {
    m = _MODEL_GAME_.models[i];
    file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_game.json",m.serializedName]];
    [m deserializeGameData:[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error]];
  }
}
- (void) restorePlayerData
{
  NSError *error;
  NSString *file;

  NSString *folder = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",_MODEL_GAME_.game_id]];

  ARISModel *m;
  for(long i = 0; i < _MODEL_GAME_.models.count; i++)
  {
    m = _MODEL_GAME_.models[i];
    file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",m.serializedName]];
    [m deserializePlayerData:[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error]];
  }
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
  if(!persistentStoreCoordinator)
  {
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"ARISCoreData.sqlite"]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
      [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
      nil];

    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
      _ARIS_LOG_(@"AppModel: Error getting the persistentStoreCoordinator");

    [storeUrl setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  }
  return persistentStoreCoordinator;
}

- (void) commitCoreDataContexts
{
  NSError *error = nil;
  if(mediaManagedObjectContext != nil)
  {
    if([mediaManagedObjectContext hasChanges] && ![mediaManagedObjectContext save:&error])
    {
      _ARIS_LOG_(@"Unresolved error %@, %@", error, [error userInfo]);
      [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ErrorSavingToDiskKey", @"") message:[NSString stringWithFormat:@"%@",[error userInfo]]];
    }
  }
  if(requestsManagedObjectContext != nil)
  {
    if([requestsManagedObjectContext hasChanges] && ![requestsManagedObjectContext save:&error])
    {
      _ARIS_LOG_(@"Unresolved error %@, %@", error, [error userInfo]);
      [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ErrorSavingToDiskKey", @"") message:[NSString stringWithFormat:@"%@",[error userInfo]]];
    }
  }
}

- (NSString *) serializedName
{
  return @"app";
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


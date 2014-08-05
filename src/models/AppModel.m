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
@synthesize showGamesInDevelopment;
@synthesize showPlayerOnMap;
@synthesize disableLeaveGame;
@synthesize hidePlayers;
@synthesize player;
@synthesize game;
@synthesize gamesModel;
@synthesize mediaModel;
@synthesize deviceLocation;
@synthesize mediaManagedObjectContext;
@synthesize requestsManagedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize servicesGraveyard;
@synthesize motionManager;

+ (id) sharedAppModel
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
    disableLeaveGame = NO;

    motionManager     = [[CMMotionManager alloc] init];
    servicesGraveyard = [[ARISServiceGraveyard alloc] initWithContext:[self requestsManagedObjectContext]];
    gamesModel        = [[GamesModel alloc] init];  
    mediaModel        = [[MediaModel alloc] initWithContext:[self mediaManagedObjectContext]]; 
      
    _ARIS_NOTIF_LISTEN_(@"DEFAULTS_CLEAR", self, @selector(defaultsClear), nil); 
    _ARIS_NOTIF_LISTEN_(@"DEFAULTS_UPDATED", self, @selector(defaultsUpdated), nil); 
    _ARIS_NOTIF_LISTEN_(@"DEVICE_MOVED", self, @selector(deviceMoved:), nil); 
    _ARIS_NOTIF_LISTEN_(@"SERVICES_LOGIN_RECEIVED", self, @selector(loginReceived:), nil); 
    _ARIS_NOTIF_LISTEN_(@"SERVICES_LOGIN_FAILED", self, @selector(loginFailed:), nil); 
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
    showGamesInDevelopment = _DEFAULTS_.showGamesInDevelopment;
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

- (void) loginReceived:(NSNotification *)n { [self logInPlayer:(User *)n.userInfo[@"user"]]; }
- (void) loginFailed:(NSNotification *)n { _ARIS_NOTIF_SEND_(@"MODEL_LOGIN_FAILED",nil,nil); }
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

- (void) beginGame
{
  [_MODEL_LOGS_ playerEnteredGame];
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_BEGAN",nil,nil);   
}

- (void) leaveGame
{
  [_MODEL_GAME_ endPlay]; 
  _MODEL_GAME_ = nil; 
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
      NSLog(@"AppModel: Error getting the persistentStoreCoordinator");
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
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ErrorSavingToDiskKey", @"") message:[NSString stringWithFormat:@"%@",[error userInfo]]];
    }
  }
  if(requestsManagedObjectContext != nil) 
  {
    if([requestsManagedObjectContext hasChanges] && ![requestsManagedObjectContext save:&error])
    {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ErrorSavingToDiskKey", @"") message:[NSString stringWithFormat:@"%@",[error userInfo]]];
    }
  }
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self); 
}

@end

//
//  AppModel.m
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AppModel.h"
#import "AppServices.h"

#import "User.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "Quest.h"
#import "ARISServiceGraveyard.h"
#import "MediaModel.h"
#import "ARISAlertHandler.h"

@interface AppModel() 
{
  NSUserDefaults *defaults; 
  NSMutableDictionary *defaultDefaults; //yeah good work on naming scheme there apple...
}

@end

@implementation AppModel

@synthesize serverURL;
@synthesize showGamesInDevelopment;
@synthesize showPlayerOnMap;
@synthesize disableLeaveGame;
@synthesize fallbackGameId;
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

    [self loadDefaultUserDefaults];  
      
    _ARIS_NOTIF_LISTEN_(@"SERVICES_LOGIN_RECEIVED", self, @selector(loginReceived:), nil);
  }
  return self;
}

- (void) loadDefaultUserDefaults
{
  NSLog(@"DefaultsState : Loading default defaults");

  defaultDefaults = [[NSMutableDictionary alloc] init];

  //Just load immutable settings from root.plist to find default defaults, and put them in easily accessible dictionary
  NSDictionary *settingsDict  = [NSDictionary dictionaryWithContentsOfFile:[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"] stringByAppendingPathComponent:@"Root.plist"]];
  NSArray *prefDictArray = settingsDict[@"PreferenceSpecifiers"];
  for(int i = 0; i < [prefDictArray count]; i++)
  {
    if(prefDictArray[i][@"DefaultValue"]) 
        defaultDefaults[prefDictArray[i][@"Key"]] = prefDictArray[i][@"DefaultValue"];
  }
}

- (void) loadUserDefaults
{
  NSLog(@"DefaultsState : Loading");
  defaults = [NSUserDefaults standardUserDefaults];

  NSURL *defaultServer;
  if(!(defaultServer = [NSURL URLWithString:[defaults stringForKey:@"baseServerString"]])) 
    defaultServer = [NSURL URLWithString:defaultDefaults[@"baseServerString"]];

  NSString *defaultVersion;
  if(!(defaultVersion = [defaults stringForKey:@"appVersion"])) 
    defaultVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

  if(
    (self.serverURL && ![defaultServer isEqual:self.serverURL]) || //new server
    ([defaultVersion isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]) || //new version
    [defaults boolForKey:@"clearCache"] //requested clear
    )
  {
    if(_MODEL_MEDIA_)  [_MODEL_MEDIA_ clearCache];
    if(_MODEL_GAME_)   [_MODEL_GAME_ clearModels];
    if(_MODEL_PLAYER_) [self logOut];
  }
  self.serverURL = defaultServer;
  
  [defaults setObject:[defaultServer absoluteString] forKey:@"baseServerString"];
  [defaults setObject:defaultVersion forKey:@"appVersion"];
  [defaults setBool:NO forKey:@"clearCache"];
  [defaults synchronize];

  self.showGamesInDevelopment = [defaults boolForKey:@"showGamesInDevelopment"];
  self.showPlayerOnMap        = [defaults boolForKey:@"showPlayerOnMap"];

  if(!_MODEL_PLAYER_)
  {
    User *u          = [[User alloc] init];
    u.user_id        = [defaults integerForKey:@"user_id"];
    u.user_name      = [defaults objectForKey:@"user_name"];
    u.display_name   = [defaults objectForKey:@"display_name"];
    u.email          = [defaults objectForKey:@"email"];
    u.media_id       = [defaults integerForKey:@"media_id"];
    u.read_write_key = [defaults objectForKey:@"read_write_key"];
    if(u.user_id) [self logInPlayer:u];
  }

  if(!self.fallbackGameId) self.fallbackGameId = [defaults integerForKey:@"game_id"]; 
  if(!_MODEL_GAME_ && self.fallbackGameId)
    [_SERVICES_ fetchOneGameGameList:_MODEL_.fallbackGameId]; 
}

- (void) saveUserDefaults
{
  NSLog(@"DefaultsState : Saving");

  [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVersion"];
  [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildNumber"]   forKey:@"buildNum"];
  [defaults setInteger:fallbackGameId forKey:@"game_id"];
  if(_MODEL_PLAYER_)
  {
    [defaults setInteger:_MODEL_PLAYER_.user_id        forKey:@"user_id"];
    [defaults setObject: _MODEL_PLAYER_.user_name      forKey:@"user_name"];
    [defaults setObject: _MODEL_PLAYER_.display_name   forKey:@"display_name"];
    [defaults setObject: _MODEL_PLAYER_.email          forKey:@"email"];
    [defaults setInteger:_MODEL_PLAYER_.media_id       forKey:@"media_id"];
    [defaults setObject: _MODEL_PLAYER_.read_write_key forKey:@"read_write_key"];
  }
  else
  {
    [defaults setInteger:0  forKey:@"user_id"];
    [defaults setObject:@"" forKey:@"user_name"];
    [defaults setObject:@"" forKey:@"display_name"];
    [defaults setObject:@"" forKey:@"email"];
    [defaults setInteger:0  forKey:@"media_id"];
    [defaults setObject:@"" forKey:@"read_write_key"];
  }
  [defaults synchronize];
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
- (void) logInPlayer:(User *)p
{
  _MODEL_PLAYER_ = p;
  if(deviceLocation) _MODEL_PLAYER_.location = deviceLocation;
  [_PUSHER_ loginPlayer:_MODEL_PLAYER_.user_id];
  [_MODEL_ saveUserDefaults]; 
  _ARIS_NOTIF_SEND_(@"MODEL_LOGGED_IN",nil,nil);

  //load the player media immediately if possible
  //if(_MODEL_PLAYER_.media_id != 0) [_SERVICES_ loadMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id] delegateHandle:nil];

  //Subscribe to player channel
  //[RootViewController sharedRootViewController].playerChannel = [[RootViewController sharedRootViewController].client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-player-channel",self.playerId]];
}

- (void) logOut
{
  if(_MODEL_GAME_) [self leaveGame];
  _MODEL_PLAYER_ = nil;
  [_PUSHER_ logoutPlayer];    
  [_MODEL_ saveUserDefaults];
  _ARIS_NOTIF_SEND_(@"MODEL_LOGGED_OUT",nil,nil); 
}

- (void) chooseGame:(Game *)g
{
  _MODEL_GAME_ = g;
  _MODEL_.fallbackGameId = _MODEL_GAME_.game_id;  
  [_PUSHER_ loginGame:_MODEL_GAME_.game_id];  
  [_MODEL_ saveUserDefaults]; 
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_CHOSEN",nil,nil);  
}

- (void) beginGame
{
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_BEGAN",nil,nil);   
}

- (void) leaveGame
{
  _MODEL_GAME_ = nil;
  _MODEL_.fallbackGameId = 0; 
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_LEFT",nil,nil);    
}



#pragma mark User Defaults
- (void) setDeviceLocation:(CLLocation *)l
{
  deviceLocation = l;
  [self setPlayerLocation:l];
}

- (void) setPlayerLocation:(CLLocation *)l
{
  if(!player) player = [[User alloc] init];
  player.location = l;
  [_SERVICES_ updateServerWithPlayerLocation];

  NSDictionary *locDict = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:l,nil] forKeys:[[NSArray alloc] initWithObjects:@"location",nil]];
  _ARIS_NOTIF_SEND_(@"UserMoved",nil,locDict);
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
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

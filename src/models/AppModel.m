//
//  AppModel.m
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AppModel.h"
#import "Player.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "Quest.h"
#import "ARISServiceGraveyard.h"
#import "MediaModel.h"
#import "AppServices.h"
#import "ARISAlertHandler.h"

@interface AppModel() 
{
   	NSUserDefaults *defaults; 
}

@end

@implementation AppModel

@synthesize serverURL;
@synthesize showGamesInDevelopment;
@synthesize showPlayerOnMap;
@synthesize fallbackGameId;
@synthesize disableLeaveGame;
@synthesize skipGameDetails;
@synthesize oneGameGameList;
@synthesize nearbyGameList;
@synthesize anywhereGameList;
@synthesize searchGameList;
@synthesize popularGameList;
@synthesize recentGameList;
@synthesize player;
@synthesize deviceLocation;
@synthesize currentGame;
@synthesize overlayIsVisible;
@synthesize nearbyLocationsList;
@synthesize hidePlayers;
@synthesize servicesGraveyard;
@synthesize mediaModel;
@synthesize motionManager;

+ (id) sharedAppModel
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id) init
{
    if(self = [super init])
    {
		//Init USerDefaults
        disableLeaveGame = NO;
        skipGameDetails  = 0;
		defaults      = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"clearCache"]; //clear cache on init- hack to get v1 working on ios8
        motionManager = [[CMMotionManager alloc] init];
        servicesGraveyard = [[ARISServiceGraveyard alloc] initWithContext:[self requestsManagedObjectContext]];
        mediaModel        = [[MediaModel alloc] initWithContext:[self mediaManagedObjectContext]]; 
	}
    return self;
}

- (void) resetAllGameLists
{
    [self.currentGame clearLocalModels];
}

- (void) resetAllPlayerLists
{
  self.nearbyLocationsList = [[NSMutableArray alloc] initWithCapacity:0];
  [self.currentGame clearLocalModels];
}

#pragma mark User Defaults

- (void) loadUserDefaults
{
	NSLog(@"Model: Loading User Defaults");
    NSURL *currServ = [NSURL URLWithString:[defaults stringForKey:@"baseServerString"]];
    if([[currServ absoluteString] isEqual:@""])
    {
        currServ = [NSURL URLWithString:@"http://arisgames.org/server"];
        [defaults setObject:[currServ absoluteString] forKey:@"baseServerString"];
        [defaults synchronize];
    }
    if(![[defaults stringForKey:@"appVersion"] isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] ||
       (self.serverURL && ![currServ isEqual:self.serverURL]) ||
       [defaults boolForKey:@"clearCache"])
    {
        [self.mediaModel clearCache];
        if(self.player)
        {
            NSLog(@"NSNotification: LogoutRequested");
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self]];
        }
        self.serverURL = currServ;
        [defaults setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] forKey:@"appVersion"];
        [defaults setBool:NO forKey:@"clearCache"];
        [defaults synchronize];
        return;
    }
    self.serverURL = currServ;
    self.showGamesInDevelopment = [defaults boolForKey:@"showGamesInDevelopment"];
    
    //Safe to load defaults
    if(!self.player)
    {
        self.player               = [[Player alloc] init];
        self.showPlayerOnMap      = [defaults  boolForKey:@"showPlayerOnMap"];
        self.player.playerId      = [defaults  integerForKey:@"playerId"];
        self.player.playerMediaId = [defaults  integerForKey:@"playerMediaId"];
        self.player.username      = [defaults  objectForKey:@"userName"];
        self.player.displayname   = [defaults  objectForKey:@"displayName"];
        self.player.groupname     = [defaults  objectForKey:@"groupName"];
        self.player.groupGameId   = [[defaults objectForKey:@"groupName"] intValue];
        
        //load the player media immediately if possible
        if(self.player.playerMediaId != 0)
            [[AppServices sharedAppServices] loadMedia:[self mediaForMediaId:self.player.playerMediaId] delegateHandle:nil];
    }
    
    self.fallbackGameId = [defaults integerForKey:@"gameId"];
}

- (void) commitPlayerLogin:(Player *)p
{
    self.player = p;
    if(!self.player.location) self.player.location = deviceLocation;
    
    [[AppServices sharedAppServices] setShowPlayerOnMap];
    [self saveUserDefaults];
    //Subscribe to player channel
    //[RootViewController sharedRootViewController].playerChannel = [[RootViewController sharedRootViewController].client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-player-channel",self.playerId]];
}

- (void) saveUserDefaults
{
	NSLog(@"Model: Saving User Defaults");
    [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVersion"];
    [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildNumber"]   forKey:@"buildNum"];
    [defaults setInteger:fallbackGameId           forKey:@"gameId"];
    if(player)
    {
        [defaults setInteger:player.playerId          forKey:@"playerId"];
        [defaults setInteger:player.playerMediaId     forKey:@"playerMediaId"];
        [defaults setObject:player.username           forKey:@"userName"];
        [defaults setObject:player.displayname        forKey:@"displayName"];
    }
    else
    {
        [defaults setInteger:0  forKey:@"playerId"];
        [defaults setInteger:0  forKey:@"playerMediaId"];
        [defaults setObject:@"" forKey:@"userName"];
        [defaults setObject:@"" forKey:@"displayName"];
    }
    [defaults synchronize];
       
    if(self.player.playerMediaId != 0)
        [[AppServices sharedAppServices] loadMedia:[self mediaForMediaId:self.player.playerMediaId] delegateHandle:nil];  
}

- (void) initUserDefaults
{
	//Load the settings bundle data into an array
	NSDictionary *settingsDict  = [NSDictionary dictionaryWithContentsOfFile:[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"] stringByAppendingPathComponent:@"Root.plist"]];
	NSArray *prefDictArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	
	//Find the Default values for each preference
	NSString *baseServerURLDefault   = @"http://arisgames.org/server";
    NSNumber *showGamesInDevDefault  = [NSNumber numberWithInt:0];
    NSNumber *showPlayerOnMapDefault = [NSNumber numberWithInt:1];
	NSDictionary *prefItem;
	for(prefItem in prefDictArray)
	{
		if([[prefItem objectForKey:@"Key"] isEqualToString:@"baseServerString"]) baseServerURLDefault   = [prefItem objectForKey:@"DefaultValue"];
        if([[prefItem objectForKey:@"Key"] isEqualToString:@"showGamesInDev"])   showGamesInDevDefault  = [prefItem objectForKey:@"DefaultValue"];
        if([[prefItem objectForKey:@"Key"] isEqualToString:@"showPlayerOnMap"])  showPlayerOnMapDefault = [prefItem objectForKey:@"DefaultValue"];
    }
	
	// since no default values have been set (i.e. no preferences file created), create it here
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
                                 baseServerURLDefault,   @"baseServerString",
                                 showGamesInDevDefault,  @"showGamesInDev",
                                 showPlayerOnMapDefault, @"showPlayerOnMap",
								 nil];
	
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
    [self loadUserDefaults];
}

- (void) setDeviceLocation:(CLLocation *)l
{
    deviceLocation = l;
    [self setPlayerLocation:l];
}

- (void) setPlayerLocation:(CLLocation *)l
{
    if(!player) player = [[Player alloc] init];
    player.location = l;
    [[AppServices sharedAppServices] updateServerWithPlayerLocation];
	
    NSDictionary *locDict = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:l,nil] forKeys:[[NSArray alloc] initWithObjects:@"location",nil]];
    NSLog(@"NSNotification: PlayerMoved");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PlayerMoved" object:nil userInfo:locDict]];
}

- (Media *) mediaForMediaId:(int)mId
{
    if(mId == 0) return nil;
	return [mediaModel mediaForMediaId:mId];
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

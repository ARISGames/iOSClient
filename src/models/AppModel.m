//
//  AppModel.m
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AppModel.h"
#import "User.h"
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
        self.player               = [[User alloc] init];
        self.showPlayerOnMap      = [defaults  boolForKey:@"showPlayerOnMap"];
        self.player.user_id      = [defaults  integerForKey:@"user_id"];
        self.player.media_id = [defaults  integerForKey:@"media_id"];
        self.player.user_name      = [defaults  objectForKey:@"user_name"];
        self.player.display_name   = [defaults  objectForKey:@"display_name"];
        
        //load the player media immediately if possible
        if(self.player.media_id != 0)
            [[AppServices sharedAppServices] loadMedia:[self.mediaModel mediaForMediaId:self.player.media_id] delegateHandle:nil];
    }
    
    self.fallbackGameId = [defaults integerForKey:@"game_id"];
}

- (void) commitPlayerLogin:(User *)p
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
    [defaults setInteger:fallbackGameId           forKey:@"game_id"];
    if(player)
    {
        [defaults setInteger:player.user_id          forKey:@"user_id"];
        [defaults setInteger:player.media_id     forKey:@"media_id"];
        [defaults setObject:player.user_name           forKey:@"user_name"];
        [defaults setObject:player.display_name        forKey:@"display_name"];
    }
    else
    {
        [defaults setInteger:0  forKey:@"user_id"];
        [defaults setInteger:0  forKey:@"media_id"];
        [defaults setObject:@"" forKey:@"user_name"];
        [defaults setObject:@"" forKey:@"display_name"];
    }
    [defaults synchronize];
       
    if(self.player.media_id != 0)
        [[AppServices sharedAppServices] loadMedia:[self.mediaModel mediaForMediaId:self.player.media_id] delegateHandle:nil];  
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
    if(!player) player = [[User alloc] init];
    player.location = l;
    [[AppServices sharedAppServices] updateServerWithPlayerLocation];
	
    NSDictionary *locDict = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:l,nil] forKeys:[[NSArray alloc] initWithObjects:@"location",nil]];
    NSLog(@"NSNotification: UserMoved");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"UserMoved" object:nil userInfo:locDict]];
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

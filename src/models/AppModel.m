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
#import "NodeOption.h"
#import "Quest.h"
#import "AppServices.h"
#import "ARISAlertHandler.h"

@implementation AppModel

@synthesize serverURL;
@synthesize showGamesInDevelopment;
@synthesize showPlayerOnMap;
@synthesize fallbackGameId;
@synthesize disableLeaveGame;
@synthesize skipGameDetails;
@synthesize oneGameGameList;
@synthesize nearbyGameList;
@synthesize searchGameList;
@synthesize popularGameList;
@synthesize recentGameList;
@synthesize player;
@synthesize currentGame;
@synthesize playerList;
@synthesize networkAlert;
@synthesize gameMediaList;
@synthesize gameItemList;
@synthesize gameNodeList;
@synthesize gameNpcList;
@synthesize gameWebPageList;
@synthesize gamePanoramicList;
@synthesize gameNoteList;
@synthesize playerNoteList;
@synthesize overlayList;
@synthesize overlayIsVisible;
@synthesize nearbyLocationsList;
@synthesize gameTagList;
@synthesize hidePlayers;
@synthesize progressBar;
@synthesize isGameNoteList;
@synthesize uploadManager;
@synthesize mediaCache;
@synthesize fileToDeleteURL;

@synthesize motionManager;
@synthesize averageAccelerometerReadingX;
@synthesize averageAccelerometerReadingY;
@synthesize averageAccelerometerReadingZ;

+ (id)sharedAppModel
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

#pragma mark Init/dealloc
- (id) init
{
    self = [super init];
    if(self)
    {
		//Init USerDefaults
        disableLeaveGame = NO;
        skipGameDetails  = 0;
		defaults      = [NSUserDefaults standardUserDefaults];
		gameMediaList = [[NSMutableDictionary alloc] initWithCapacity:10];
        overlayList   = [[NSMutableArray alloc] initWithCapacity:10];
        motionManager = [[CMMotionManager alloc] init];
        
        playerNoteList = [[NSMutableDictionary alloc] initWithCapacity:10];
		gameNoteList   = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearGameLists) name:@"NewGameSelected" object:nil];
	}
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [[AppModel sharedAppModel].mediaCache clearCache];
        if([AppModel sharedAppModel].player)
        {
            NSLog(@"NSNotification: LogoutRequested");
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self]];
        }
        self.serverURL = currServ;
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
    }
    
    self.fallbackGameId = [defaults integerForKey:@"gameId"];
}

- (void) commitPlayerLogin:(Player *)p
{
    self.player = p;
    
    [[AppServices sharedAppServices] setShowPlayerOnMap];
    [[AppModel sharedAppModel] saveUserDefaults];
    //Subscribe to player channel
    //[RootViewController sharedRootViewController].playerChannel = [[RootViewController sharedRootViewController].client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-player-channel",[AppModel sharedAppModel].playerId]];
}

-(void)clearGameLists
{
    NSLog(@"Clearing Game Lists");
    [gameMediaList     removeAllObjects];
    [gameItemList      removeAllObjects];
    [gameNodeList      removeAllObjects];
    [gameNpcList       removeAllObjects];
    [gameWebPageList   removeAllObjects];
    [gamePanoramicList removeAllObjects];
    //[gameNoteList removeAllObjects];
    //[playerNoteList removeAllObjects];
}

-(void)saveUserDefaults
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
}

- (void) saveCOREData
{
    NSError *error = nil;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:@"Error saving to disk" message:[NSString stringWithFormat:@"%@",[error userInfo]]];
        }
    }
}

- (void) initUserDefaults
{
	//Load the settings bundle data into an array
	NSDictionary *settingsDict  = [NSDictionary dictionaryWithContentsOfFile:[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"] stringByAppendingPathComponent:@"Root.plist"]];
	NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	
	//Find the Defaults
	NSString *baseAppURLDefault             = @"Unknown Default";
    NSNumber *showGamesInDevelopmentDefault = [NSNumber numberWithInt:0];
    NSNumber *showPlayerOnMapDefault        = [NSNumber numberWithInt:1];
	NSDictionary *prefItem;
	for(prefItem in prefSpecifierArray)
	{
		if([[prefItem objectForKey:@"Key"] isEqualToString:@"baseServerString"])       baseAppURLDefault             = [prefItem objectForKey:@"DefaultValue"];
        if([[prefItem objectForKey:@"Key"] isEqualToString:@"showGamesInDevelopment"]) showGamesInDevelopmentDefault = [prefItem objectForKey:@"DefaultValue"];
        if([[prefItem objectForKey:@"Key"] isEqualToString:@"showPlayerOnMap"])        showPlayerOnMapDefault        = [prefItem objectForKey:@"DefaultValue"];
    }
	
	// since no default values have been set (i.e. no preferences file created), create it here
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 baseAppURLDefault,             @"baseServerString",
                                 showGamesInDevelopmentDefault, @"showGamesInDevelopment",
                                 showPlayerOnMapDefault,        @"showPlayerOnMap",
								 nil];
	
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
    
    uploadManager = [[UploadMan alloc]  init];
    mediaCache    = [[MediaCache alloc] init];
}

- (void) setPlayerLocation:(CLLocation *)newLocation
{
    if(player)
    {
        player.location = newLocation;
        [[AppServices sharedAppServices] updateServerWithPlayerLocation];
    }
	
    NSDictionary *locDict = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:newLocation,nil] forKeys:[[NSArray alloc] initWithObjects:@"location",nil]];
    NSLog(@"NSNotification: PlayerMoved");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PlayerMoved" object:nil userInfo:locDict]];
}

#pragma mark Retrieving Cashed Objects 

- (Media *) mediaForMediaId:(int)mId ofType:(NSString *)type// type = nil for "I don't know". Used as a hint for how to treat media if it needs to be loaded
{
    if(mId == 0) return nil;
	return [mediaCache mediaForMediaId:mId ofType:type];
}

- (Npc *) npcForNpcId:(int)mId
{    
	return [self.gameNpcList objectForKey:[NSNumber numberWithInt:mId]];
}

- (Node *) nodeForNodeId:(int)mId
{
	return [self.gameNodeList objectForKey:[NSNumber numberWithInt:mId]];
}

- (WebPage *) webPageForWebPageId:(int)mId
{
	return [self.gameWebPageList objectForKey:[NSNumber numberWithInt:mId]];
}


- (Panoramic *) panoramicForPanoramicId:(int)mId
{
    return [self.gamePanoramicList objectForKey:[NSNumber numberWithInt:mId]];
}

-(Item *) itemForItemId:(int)mId
{
	return [self.gameItemList objectForKey:[NSNumber numberWithInt:mId]];
}

- (Note *) noteForNoteId:(int)mId playerListYesGameListNo:(BOOL)checkPlayerList
{
	Note *note;
    note = [self.gameNoteList objectForKey:[NSNumber numberWithInt:mId]];
	if(!note) note = [self.playerNoteList objectForKey:[NSNumber numberWithInt:mId]];
    
	if(!note)
    {
        if(checkPlayerList) [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];
        else                [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];
	}
	return note;
}

- (NSManagedObjectContext *) managedObjectContext
{
    if(!managedObjectContext)
    {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if(coordinator)
        {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return managedObjectContext;
}

- (NSManagedObjectModel *) managedObjectModel
{
    if(!managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UploadContent" withExtension:@"momd"];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return managedObjectModel;
}

- (NSString *) applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if(!persistentStoreCoordinator)
    {
        NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"UploadContent.sqlite"]];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSError *error;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
            NSLog(@"AppModel: Error getting the persistentStoreCoordinator");
	}
    return persistentStoreCoordinator;
}

@end

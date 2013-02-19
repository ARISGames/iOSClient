//
//  AppModel.m
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "NodeOption.h"
#import "Quest.h"
#import "AppServices.h"

@implementation AppModel

@synthesize serverURL;
@synthesize showGamesInDevelopment;
@synthesize showPlayerOnMap;
@synthesize loggedIn;
@synthesize userName;
@synthesize groupName;
@synthesize groupGame;
@synthesize displayName;
@synthesize password;
@synthesize playerId;
@synthesize fallbackGameId;
@synthesize playerMediaId;
@synthesize museumMode;
@synthesize skipGameDetails;
@synthesize singleGameList;
@synthesize nearbyGameList;
@synthesize searchGameList;
@synthesize popularGameList;
@synthesize recentGameList;
@synthesize currentGame;
@synthesize locationList;
@synthesize playerList;
@synthesize playerLocation;
@synthesize networkAlert;
@synthesize gameMediaList;
@synthesize gameItemList;
@synthesize gameNodeList;
@synthesize gameNpcList;
@synthesize gameWebPageList;
@synthesize gamePanoramicList;
@synthesize gameTabList;
@synthesize defaultGameTabList;
@synthesize gameNoteList;
@synthesize playerNoteList;
@synthesize profilePic;
@synthesize gameNoteListHash;
@synthesize playerNoteListHash;
@synthesize overlayListHash;
@synthesize overlayList;
@synthesize overlayIsVisible;
@synthesize nearbyLocationsList;
@synthesize gameTagList;
@synthesize hasSeenNearbyTabTutorial;
@synthesize hasSeenQuestsTabTutorial;
@synthesize hasSeenMapTabTutorial;
@synthesize hasSeenInventoryTabTutorial;
@synthesize tabsReady;
@synthesize currentlyInteractingWithObject;
@synthesize hidePlayers;
@synthesize progressBar;
@synthesize isGameNoteList;
@synthesize uploadManager;
@synthesize mediaCache;
@synthesize hasReceivedMediaList;
@synthesize inGame;
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
-(id)init
{
    self = [super init];
    if (self)
    {
		//Init USerDefaults
        museumMode = NO;
        skipGameDetails = NO;
		defaults      = [NSUserDefaults standardUserDefaults];
		gameMediaList = [[NSMutableDictionary alloc] initWithCapacity:10];
        overlayList   = [[NSMutableArray alloc] initWithCapacity:10];
        motionManager = [[CMMotionManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearGameLists) name:@"NewGameSelected" object:nil];
	}
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark User Defaults

-(void)loadUserDefaults
{
	NSLog(@"Model: Loading User Defaults");
	[defaults synchronize];
    
    NSURL *currServ = [NSURL URLWithString:[defaults stringForKey:@"baseServerString"]];
    
    if ([[currServ absoluteString] isEqual:@"http://arisgames.org/server1"] ||
        [[currServ absoluteString] isEqual:@"http://arisgames.org/stagingserver1/"] ||
        [[currServ absoluteString] isEqual:@""])
    {
        NSString *updatedURL = @"http://arisgames.org/server";
        [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:updatedURL] forKey:@"baseServerString"];
        [defaults synchronize];
        currServ = [NSURL URLWithString:updatedURL];
    }
    if (self.serverURL && ![currServ isEqual:self.serverURL])
    {
        [[AppModel sharedAppModel].mediaCache clearCache];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self]];
        self.serverURL = currServ;
        return;
    }
    self.serverURL = currServ;
    if(self.showGamesInDevelopment != [defaults boolForKey:@"showGamesInDevelopment"])
    {
        self.showGamesInDevelopment = [defaults boolForKey:@"showGamesInDevelopment"];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self]];
        return;
    }
    
    //Safe to load defaults
    
    if(!self.loggedIn)
    {
        self.showPlayerOnMap = [defaults boolForKey:@"showPlayerOnMap"];
        self.playerId        = [defaults integerForKey:@"playerId"];
        self.playerMediaId   = [defaults integerForKey:@"playerMediaId"];
        self.userName        = [defaults objectForKey:@"userName"];
        self.displayName     = [defaults objectForKey:@"displayName"];
        self.groupName       = [defaults objectForKey:@"groupName"];
        self.groupGame       = [[defaults objectForKey:@"groupName"] intValue];
    }
    
	if ([defaults boolForKey:@"resetTutorial"])
    {
		self.hasSeenNearbyTabTutorial    = NO;
		self.hasSeenQuestsTabTutorial    = NO;
		self.hasSeenMapTabTutorial       = NO;
		self.hasSeenInventoryTabTutorial = NO;
		[defaults setBool:NO forKey:@"hasSeenNearbyTabTutorial"];
		[defaults setBool:NO forKey:@"hasSeenQuestsTabTutorial"];
		[defaults setBool:NO forKey:@"hasSeenMapTabTutorial"];
		[defaults setBool:NO forKey:@"hasSeenInventoryTabTutorial"];
        
		[defaults setBool:NO forKey:@"resetTutorial"];
	}
	else
    {
		self.hasSeenNearbyTabTutorial    = [defaults boolForKey:@"hasSeenNearbyTabTutorial"];
		self.hasSeenQuestsTabTutorial    = [defaults boolForKey:@"hasSeenQuestsTabTutorial"];
		self.hasSeenMapTabTutorial       = [defaults boolForKey:@"hasSeenMapTabTutorial"];
		self.hasSeenInventoryTabTutorial = [defaults boolForKey:@"hasSeenInventoryTabTutorial"];
	}
    
    self.fallbackGameId = [defaults integerForKey:@"gameId"];
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

-(void)clearUserDefaults
{
	NSLog(@"Model: Clearing User Defaults");	
	[AppModel sharedAppModel].currentGame.gameId = 0;
    [AppModel sharedAppModel].playerId           = 0;
    [AppModel sharedAppModel].fallbackGameId     = 0;
    [AppModel sharedAppModel].playerMediaId      = -1;
    [AppModel sharedAppModel].userName           = @"";
    [AppModel sharedAppModel].displayName        = @"";
    [defaults setInteger:playerId       forKey:@"playerId"];
    [defaults setInteger:fallbackGameId forKey:@"gameId"];
    [defaults setInteger:playerMediaId  forKey:@"playerMediaId"];
    [defaults setObject:userName        forKey:@"userName"];
    [defaults setObject:displayName     forKey:@"displayName"];
       
	[defaults synchronize];
}

-(void)saveUserDefaults
{
	NSLog(@"Model: Saving User Defaults");
	
	[defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVerison"];
	[defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildNumber"]   forKey:@"buildNum"];
    
	[defaults setBool:hasSeenNearbyTabTutorial    forKey:@"hasSeenNearbyTabTutorial"];
	[defaults setBool:hasSeenQuestsTabTutorial    forKey:@"hasSeenQuestsTabTutorial"];
	[defaults setBool:hasSeenMapTabTutorial       forKey:@"hasSeenMapTabTutorial"];
	[defaults setBool:hasSeenInventoryTabTutorial forKey:@"hasSeenInventoryTabTutorial"];
    [defaults setInteger:playerId                 forKey:@"playerId"];
    [defaults setInteger:playerMediaId            forKey:@"playerMediaId"];
    [defaults setInteger:fallbackGameId           forKey:@"gameId"];
    [defaults setObject:userName                  forKey:@"userName"];
    [defaults setObject:displayName               forKey:@"displayName"];
	[defaults synchronize];
}

-(void)saveCOREData
{
    NSError *error = nil;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [[RootViewController sharedRootViewController] showAlert:@"Error saving to disk" message:[NSString stringWithFormat:@"%@",[error userInfo]]];
        }
    }
}

-(void)initUserDefaults
{
	//Load the settings bundle data into an array
	NSString *pathStr            = [[NSBundle mainBundle] bundlePath];
	NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
	NSString *finalPath          = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
	NSDictionary *settingsDict   = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	NSArray *prefSpecifierArray  = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	
	//Find the Defaults
	NSString *baseAppURLDefault = @"Unknown Default";
    NSNumber *showGamesInDevelopmentDefault,*showPlayerOnMapDefault;
	NSDictionary *prefItem;
	for (prefItem in prefSpecifierArray)
	{
		NSString *keyValueStr = [prefItem objectForKey:@"Key"];
		
		if ([keyValueStr isEqualToString:@"baseServerString"])
            baseAppURLDefault = [prefItem objectForKey:@"DefaultValue"];
        if ([keyValueStr isEqualToString:@"showGamesInDevelopment"])
			showGamesInDevelopmentDefault = [prefItem objectForKey:@"DefaultValue"];
        if ([keyValueStr isEqualToString:@"showPlayerOnMap"])
			showPlayerOnMapDefault = [prefItem objectForKey:@"DefaultValue"];
    }
	
	// since no default values have been set (i.e. no preferences file created), create it here
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 baseAppURLDefault,  @"baseServerString",
                                 showGamesInDevelopmentDefault , @"showGamesInDevelopment",
                                 showPlayerOnMapDefault,@"showPlayerOnMap",
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    uploadManager = [[UploadMan alloc]  init];
    mediaCache    = [[MediaCache alloc] init];
}

#pragma mark Setters/Getters

- (void)setPlayerLocation:(CLLocation *) newLocation
{
	NSLog(@"AppModel: setPlayerLocation");
	
	playerLocation = newLocation;
	
	//Tell the model to update the server and fetch any nearby locations
	[[AppServices sharedAppServices] updateServerWithPlayerLocation];	
	
	//Tell the other parts of the client
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PlayerMoved" object:nil]];
}

#pragma mark Retrieving Cashed Objects 

-(void)modifyQuantity:(int)quantityModifier forLocationId:(int)locationId
{
	NSLog(@"AppModel: modifying quantity for a location in the local location list");
	
	for (Location* loc in locationList)
    {
		if (loc.locationId == locationId && loc.kind == NearbyObjectItem)
        {
			loc.qty += quantityModifier;
			NSLog(@"AppModel: Quantity for %@ set to %d",loc.name,loc.qty);	
		}
	}	
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewLocationListReady" object:nil]];
	
}

-(Media *)mediaForMediaId:(int)mId
{
    if(mId == 0) return nil;
	return [mediaCache mediaForMediaId:mId];
}

-(Npc *)npcForNpcId:(int)mId
{
	NSLog(@"AppModel: Npc %d requested from cached list",mId);
    
	Npc *npc = [self.gameNpcList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!npc) {
		//Let's pause everything and do a lookup
		NSLog(@"AppModel: Npc not found in cached item list, refresh");
		[[AppServices sharedAppServices] fetchGameNpcListAsynchronously:NO];
		
		npc = [self.gameNpcList objectForKey:[NSNumber numberWithInt:mId]];
		if (npc) NSLog(@"AppModel: Npc found after refresh");
		else NSLog(@"AppModel: Npc still NOT found after refresh");
	}
	return npc;
}

-(Node *)nodeForNodeId:(int)mId
{
	Node *node = [self.gameNodeList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!node) {
		//Let's pause everything and do a lookup
		NSLog(@"AppModel: Node not found in cached item list, refresh");
		[[AppServices sharedAppServices] fetchGameNodeListAsynchronously:NO];
		
		node = [self.gameNodeList objectForKey:[NSNumber numberWithInt:mId]];
		if (node) NSLog(@"AppModel: Node found after refresh");
		else NSLog(@"AppModel: Node still NOT found after refresh");
	}
	return node;
}

- (Note *)noteForNoteId:(int)mId playerListYesGameListNo:(BOOL)playerorGame
{
	Note *note;
    note = [self.gameNoteList objectForKey:[NSNumber numberWithInt:mId]];
	if(!note) note = [self.playerNoteList objectForKey:[NSNumber numberWithInt:mId]];
    
	if (!note) {
		//Let's pause everything and do a lookup
		NSLog(@"AppModel: Note not found in cached item list, refresh");
        if(!playerorGame)
            [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];
        else
            [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];
        
        if (note) NSLog(@"AppModel: Note found after refresh");
		else NSLog(@"AppModel: Note still NOT found after refresh");
	}
	return note;
}

- (WebPage *)webPageForWebPageID:(int)mId
{
	WebPage *page = [self.gameWebPageList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!page) {
        
		
		[[AppServices sharedAppServices] fetchGameWebpageListAsynchronously:NO];
		
		page = [self.gameWebPageList objectForKey:[NSNumber numberWithInt:mId]];
        
	}
	return page;
}


- (Panoramic *)panoramicForPanoramicId:(int)mId
{
    Panoramic *pan = [self.gamePanoramicList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!pan) {
        
		
		[[AppServices sharedAppServices] fetchGamePanoramicListAsynchronously:NO];
		
		pan = [self.gamePanoramicList objectForKey:[NSNumber numberWithInt:mId]];
        
	}
	return pan;
    
}

-(Item *)itemForItemId:(int)mId
{
	Item *item = [self.gameItemList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!item) {
		//Let's pause everything and do a lookup
		NSLog(@"AppModel: Item not found in cached item list, refresh");
		[[AppServices sharedAppServices] fetchGameItemListAsynchronously:NO];
		
		item = [self.gameItemList objectForKey:[NSNumber numberWithInt:mId]];
		if (item) NSLog(@"AppModel: Item found after refresh");
		else NSLog(@"AppModel: Item still NOT found after refresh");
	}
	return item;
}

-(Location *)locationForLocationId:(int)lId
{
    for(int i = 0; i < [self.locationList count]; i++)
    {
        if(((Location *)[self.locationList objectAtIndex:i]).locationId == lId)
            return [self.locationList objectAtIndex:i];
    }
    return nil;
}

#pragma mark Core Data
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{
    if (managedObjectContext != nil)
        return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if(managedObjectModel != nil)
        return managedObjectModel;
        
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}

/**
  Returns the path to the application's Documents directory.
  */
- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
        return persistentStoreCoordinator;
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"UploadContent.sqlite"]];
    NSError *error = nil;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
        NSLog(@"AppModel: Error getting the persistentStoreCoordinator");
	
    return persistentStoreCoordinator;
}

@end

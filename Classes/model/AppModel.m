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
@synthesize serverURL,showGamesInDevelopment,showPlayerOnMap;
@synthesize loggedIn, userName, password, playerId;
@synthesize currentGame, gameList, locationList, playerList,recentGameList;
@synthesize playerLocation, inventory, questList, networkAlert;
@synthesize gameMediaList, gameItemList, gameNodeList, gameNpcList,gameWebPageList,gamePanoramicList,gameTabList, defaultGameTabList,gameNoteList,playerNoteList;
@synthesize locationListHash, questListHash, inventoryHash,profilePic,attributes,gameNoteListHash,playerNoteListHash;

@synthesize nearbyLocationsList,gameTagList;
@synthesize hasSeenNearbyTabTutorial,hasSeenQuestsTabTutorial,hasSeenMapTabTutorial,hasSeenInventoryTabTutorial, tabsReady,hidePlayers,progressBar,isGameNoteList,uploadManager,mediaCache;


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
-(id)init {
    self = [super init];
    if (self) {
		//Init USerDefaults
		defaults = [NSUserDefaults standardUserDefaults];
		gameMediaList = [[NSMutableDictionary alloc] initWithCapacity:10];
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(clearGameLists) name:@"NewGameSelected" object:nil];
	}
			 
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    
}


#pragma mark User Defaults

-(void)loadUserDefaults {
	NSLog(@"Model: Loading User Defaults");
	[defaults synchronize];

	//Load the base App URL
	NSString *baseServerString = [defaults stringForKey:@"baseServerString"];
    NSURL *currServ = [NSURL URLWithString: baseServerString ];
   
    self.showPlayerOnMap = [defaults boolForKey:@"showPlayerOnMap"];
    if(!loggedIn &&(self.showGamesInDevelopment == [defaults boolForKey:@"showGamesInDevelopment"])&&(!(![currServ isEqual:self.serverURL] || (self.serverURL == nil)))) {
        self.userName = [defaults objectForKey:@"userName"];
        self.playerId = [defaults integerForKey:@"playerId"];
    }
    
    if (![currServ isEqual:self.serverURL] || (self.serverURL == nil)) {
        NSNotification *logoutRequestNotification = [NSNotification notificationWithName:@"LogoutRequested" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:logoutRequestNotification];
    }
    
    
    //Old versions of the server URL are depricated. Migrate to the new version
    if ([[currServ absoluteString] isEqual:@"http://arisgames.org/server1"] || 
        [[currServ absoluteString]  isEqual:@"http://arisgames.org/server1/"] || 
        [[currServ absoluteString]  isEqual:@"http://arisgames.org/stagingserver1"] ||
        [[currServ absoluteString]  isEqual:@"http://arisgames.org/stagingserver1/"]) {
        
        NSLog(@"AppModel: SERVER NEEDS TO BE CHANGED");
        
        NSString *updatedURL = @"http://arisgames.org/server";
        [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:updatedURL] forKey:@"baseServerString"]; 
        
        [defaults synchronize];		
        NSNotification *logoutRequestNotification = [NSNotification notificationWithName:@"LogoutRequested" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:logoutRequestNotification];
    }

    
    self.serverURL = [NSURL URLWithString: baseServerString ];
    if(self.showGamesInDevelopment != [defaults boolForKey:@"showGamesInDevelopment"])
    {
    self.showGamesInDevelopment = [defaults boolForKey:@"showGamesInDevelopment"];
    NSNotification *logoutRequestNotification = [NSNotification notificationWithName:@"LogoutRequested" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:logoutRequestNotification];
    }
    
	if ([defaults boolForKey:@"resetTutorial"]) {
		self.hasSeenNearbyTabTutorial = NO;
		self.hasSeenQuestsTabTutorial = NO;
		self.hasSeenMapTabTutorial = NO;
		self.hasSeenInventoryTabTutorial = NO;
		[defaults setBool:hasSeenNearbyTabTutorial forKey:@"hasSeenNearbyTabTutorial"];
		[defaults setBool:hasSeenQuestsTabTutorial forKey:@"hasSeenQuestsTabTutorial"];
		[defaults setBool:hasSeenMapTabTutorial forKey:@"hasSeenMapTabTutorial"];
		[defaults setBool:hasSeenInventoryTabTutorial forKey:@"hasSeenInventoryTabTutorial"];
		[defaults setBool:NO forKey:@"resetTutorial"];

	}
	else {
		self.hasSeenNearbyTabTutorial = [defaults boolForKey:@"hasSeenNearbyTabTutorial"];
		self.hasSeenQuestsTabTutorial = [defaults boolForKey:@"hasSeenQuestsTabTutorial"];
		self.hasSeenMapTabTutorial = [defaults boolForKey:@"hasSeenMapTabTutorial"];
		self.hasSeenInventoryTabTutorial = [defaults boolForKey:@"hasSeenInventoryTabTutorial"];
	}

}

-(void)clearGameLists{
    NSLog(@"Clearing Game Lists");
    [gameMediaList removeAllObjects];
    [gameItemList removeAllObjects];
    [gameNodeList removeAllObjects];
    [gameNpcList removeAllObjects];
    [gameWebPageList removeAllObjects];
    [gamePanoramicList removeAllObjects];
    //[gameNoteList removeAllObjects];
    //[playerNoteList removeAllObjects];
}

-(void)clearUserDefaults {
	NSLog(@"Model: Clearing User Defaults");	
	[AppModel sharedAppModel].currentGame.gameId = 0;
    [AppModel sharedAppModel].playerId = 0;
	[defaults synchronize];		
}

-(void)saveUserDefaults {
	NSLog(@"Model: Saving User Defaults");
	
	[defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVerison"];
	[defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildNumber"] forKey:@"buildNum"];

	[defaults setBool:hasSeenNearbyTabTutorial forKey:@"hasSeenNearbyTabTutorial"];
	[defaults setBool:hasSeenQuestsTabTutorial forKey:@"hasSeenQuestsTabTutorial"];
	[defaults setBool:hasSeenMapTabTutorial forKey:@"hasSeenMapTabTutorial"];
	[defaults setBool:hasSeenInventoryTabTutorial forKey:@"hasSeenInventoryTabTutorial"];
    [defaults setValue:userName forKey:@"userName"];
    [defaults setInteger:playerId forKey:@"playerId"];

}

-(void)saveCOREData {
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}

-(void)initUserDefaults {	
	
	//Load the settings bundle data into an array
	NSString *pathStr = [[NSBundle mainBundle] bundlePath];
	NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
	NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	
	//Find the Defaults
	NSString *baseAppURLDefault = [NSString stringWithString:@"Unknown Default"];
    NSNumber *showGamesInDevelopmentDefault,*showPlayerOnMapDefault;
	NSDictionary *prefItem;
	for (prefItem in prefSpecifierArray)
	{
		NSString *keyValueStr = [prefItem objectForKey:@"Key"];
		
		if ([keyValueStr isEqualToString:@"baseServerString"])
		{
            baseAppURLDefault = [prefItem objectForKey:@"DefaultValue"];
		}
        if ([keyValueStr isEqualToString:@"showGamesInDevelopment"])
		{
			showGamesInDevelopmentDefault = [prefItem objectForKey:@"DefaultValue"];
		}
        if ([keyValueStr isEqualToString:@"showPlayerOnMap"])
		{
			showPlayerOnMapDefault = [prefItem objectForKey:@"DefaultValue"];
		}

		//More defaults would go here
	}
	
	// since no default values have been set (i.e. no preferences file created), create it here
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 baseAppURLDefault,  @"baseServerString",
                                 showGamesInDevelopmentDefault , @"showGamesInDevelopment",
                                 showPlayerOnMapDefault,@"showPlayerOnMapDefault",
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    uploadManager = [[UploadMan alloc]init];
    mediaCache = [[MediaCache alloc]init];

}

#pragma mark Seters/Geters

- (void)setPlayerLocation:(CLLocation *) newLocation{
	NSLog(@"AppModel: setPlayerLocation");
	
	playerLocation = newLocation;
	
	//Tell the model to update the server and fetch any nearby locations
	[[AppServices sharedAppServices] updateServerWithPlayerLocation];	
	
	//Tell the other parts of the client
	NSNotification *updatedLocationNotification = [NSNotification notificationWithName:@"PlayerMoved" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:updatedLocationNotification];
}


#pragma mark Retrieving Cashed Objects 

-(void)modifyQuantity: (int)quantityModifier forLocationId: (int)locationId {
	NSLog(@"AppModel: modifying quantity for a location in the local location list");
	
	for (Location* loc in locationList) {
		if (loc.locationId == locationId && loc.kind == NearbyObjectItem) {
			loc.qty += quantityModifier;
			NSLog(@"AppModel: Quantity for %@ set to %d",loc.name,loc.qty);	
		}
	}	
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewLocationListReady" object:nil]];
	
}

-(void)removeItemFromInventory:(Item*)item qtyToRemove:(int)qty {
	NSLog(@"AppModel: removing an item from the local inventory");
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];

	item.qty -=qty; 
	if (item.qty < 1) [self.inventory removeObjectForKey:[NSString stringWithFormat:@"%d",item.itemId]];
    
    if([[(UINavigationController *) appDelegate.tabBarController.selectedViewController topViewController] respondsToSelector:@selector(updateQuantityDisplay)])
        [[(UINavigationController *)appDelegate.tabBarController.selectedViewController topViewController] performSelector:@selector(updateQuantityDisplay)];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item Lost",@"title",[NSString stringWithFormat:@"%d %@ removed from inventory",qty,item.name],@"prompt", nil];
    
    [appDelegate.notifArray addObject:dict];
    [appDelegate showNotifications];

 //   [appDelegate performSelector:@selector(displayNotificationTitle:) withObject:dict afterDelay:.1];

    
	NSNotification *notification = [NSNotification notificationWithName:@"NewInventoryReady" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];

}

-(void)addItemToInventory: (Item*)item {
	NSLog(@"AppModel: adding an item from the local inventory");
    
	[self.inventory setObject:item forKey:[NSString stringWithFormat:@"%d",item.itemId]];
	NSNotification *notification = [NSNotification notificationWithName:@"NewInventoryReady" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
    //[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ItemRecievedNotification" object:nil]];
    //self.itemPrompt = item;

}

-(Media *)mediaForMediaId: (int)mId {
/*	Media *media = [self.gameMediaList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!media) {
		//Let's pause everything and do a lookup
		NSLog(@"AppModel: Media: %d not found in cached media List, refresh",mId);
		[[AppServices sharedAppServices] fetchGameMediaListAsynchronously:NO];
		
		media = [self.gameMediaList objectForKey:[NSNumber numberWithInt:mId]];
		if (media) NSLog(@"AppModel: Media found after refresh");
		else NSLog(@"AppModel: Media: %d still NOT found after refresh",mId);
	}*/
	return [mediaCache mediaForMediaId:mId];
}

-(Npc *)npcForNpcId: (int)mId {
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

-(Node *)nodeForNodeId: (int)mId {
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

- (Note *)noteForNoteId:(int)mId playerListYesGameListNo:(BOOL)playerorGame{
	Note *note;
    if(!playerorGame)
    note= [self.gameNoteList objectForKey:[NSNumber numberWithInt:mId]];
	else
        note= [self.playerNoteList objectForKey:[NSNumber numberWithInt:mId]];
    
	if (!note) {
		//Let's pause everything and do a lookup
		NSLog(@"AppModel: Note not found in cached item list, refresh");
		
        if(!playerorGame){
            [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];
            //note= [[AppServices sharedAppServices]fetchNote:mId];

        }
        else{
            [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];
            //note= [[AppServices sharedAppServices]fetchNote:mId];

        }
            
            if (note) NSLog(@"AppModel: Note found after refresh");
		else NSLog(@"AppModel: Note still NOT found after refresh");
	}
	return note;
}

- (WebPage *)webPageForWebPageID: (int)mId {
	WebPage *page = [self.gameWebPageList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!page) {

		
		[[AppServices sharedAppServices] fetchGameWebpageListAsynchronously:NO];
		
		page = [self.gameWebPageList objectForKey:[NSNumber numberWithInt:mId]];

	}
	return page;
}


- (Panoramic *)panoramicForPanoramicId:(int)mId {
    Panoramic *pan = [self.gamePanoramicList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!pan) {
        
		
		[[AppServices sharedAppServices] fetchGamePanoramicListAsynchronously:NO];
		
		pan = [self.gamePanoramicList objectForKey:[NSNumber numberWithInt:mId]];
        
	}
	return pan;

}

-(Item *)itemForItemId: (int)mId {
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

#pragma mark Core Data
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
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
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"UploadContent.sqlite"]];
    NSError *error = nil;

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        NSLog(@"AppModel: Error getting the persistentStoreCoordinator");
    }    
	
    return persistentStoreCoordinator;
}



@end

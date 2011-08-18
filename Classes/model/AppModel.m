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
@synthesize serverURL,showGamesInDevelopment;
@synthesize loggedIn, userName, password, playerId;
@synthesize currentGame, gameList, locationList, playerList,recentGameList;
@synthesize playerLocation, inventory, questList, networkAlert;
@synthesize gameMediaList, gameItemList, gameNodeList, gameNpcList,gameWebPageList,gamePanoramicList,gameTabList, defaultGameTabList;
@synthesize locationListHash, questListHash, inventoryHash,profilePic,attributes;

@synthesize nearbyLocationsList;
@synthesize hasSeenNearbyTabTutorial,hasSeenQuestsTabTutorial,hasSeenMapTabTutorial,hasSeenInventoryTabTutorial;



SYNTHESIZE_SINGLETON_FOR_CLASS(AppModel);



#pragma mark Init/dealloc
-(id)init {
    self = [super init];
    if (self) {
		//Init USerDefaults
		defaults = [NSUserDefaults standardUserDefaults];
		gameMediaList = [[NSMutableDictionary alloc] initWithCapacity:10];
	}
			 
    return self;
}

- (void)dealloc {
	[gameMediaList release];
	[gameList release];
    [defaultGameTabList release];
    [recentGameList release];
	[serverURL release];
	[userName release];
	[password release];
    [gameTabList release];
    [super dealloc];
}


#pragma mark User Defaults

-(void)loadUserDefaults {
	NSLog(@"Model: Loading User Defaults");
	[defaults synchronize];

	//Load the base App URL
	NSString *baseServerString = [defaults stringForKey:@"baseServerString"];
    NSURL *currServ = [NSURL URLWithString: baseServerString ];
   
    
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

-(void)initUserDefaults {	
	
	//Load the settings bundle data into an array
	NSString *pathStr = [[NSBundle mainBundle] bundlePath];
	NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
	NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	
	//Find the Defaults
	NSString *baseAppURLDefault = [NSString stringWithString:@"Unknown Default"];
    NSNumber *showGamesInDevelopmentDefault;
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
		//More defaults would go here
	}
	
	// since no default values have been set (i.e. no preferences file created), create it here
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 baseAppURLDefault,  @"baseServerString",
                                 showGamesInDevelopmentDefault , @"showGamesInDevelopment",
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Seters/Geters

- (void)setPlayerLocation:(CLLocation *) newLocation{
	NSLog(@"AppModel: setPlayerLocation");
	
	playerLocation = newLocation;
	[playerLocation retain];
	
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

    
    [appDelegate performSelector:@selector(displayNotificationTitle:) withObject:dict afterDelay:.1];

    
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
	Media *media = [self.gameMediaList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!media) {
		//Let's pause everything and do a lookup
		NSLog(@"AppModel: Media not found in cached media List, refresh");
		[[AppServices sharedAppServices] fetchGameMediaListAsynchronously:NO];
		
		media = [self.gameMediaList objectForKey:[NSNumber numberWithInt:mId]];
		if (media) NSLog(@"AppModel: Media found after refresh");
		else NSLog(@"AppModel: Media still NOT found after refresh");
	}
	return media;
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


@end

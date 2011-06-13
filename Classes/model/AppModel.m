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
@synthesize loggedIn, username, password, playerId, currentModule;
@synthesize currentGame, gameList, locationList, playerList;
@synthesize playerLocation, inventory, questList, networkAlert;
@synthesize gameMediaList, gameItemList, gameNodeList, gameNpcList;
@synthesize locationListHash, questListHash, inventoryHash;

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
	[serverURL release];
	[username release];
	[password release];
	[currentModule release];
    [super dealloc];
}


#pragma mark User Defaults

-(void)loadUserDefaults {
	NSLog(@"Model: Loading User Defaults");
	[defaults synchronize];
	
	//Load the base App URL
	NSString *baseServerString = [defaults stringForKey:@"baseServerString"];
    NSURL *currServ = [NSURL URLWithString: baseServerString ];
   
    if (![currServ isEqual:self.serverURL] || (self.serverURL == nil)) {
        NSNotification *logoutRequestNotification = [NSNotification notificationWithName:@"LogoutRequested" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:logoutRequestNotification];
    }
	
    self.serverURL = [NSURL URLWithString: baseServerString ];
    self.showGamesInDevelopment = [defaults boolForKey:@"showGamesInDevelopment"];

    
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
	NSDictionary *prefItem;
	for (prefItem in prefSpecifierArray)
	{
		NSString *keyValueStr = [prefItem objectForKey:@"Key"];
		id defaultValue = [prefItem objectForKey:@"DefaultValue"];
		
		if ([keyValueStr isEqualToString:@"baseServerString"])
		{
			baseAppURLDefault = defaultValue;
		}
		//More defaults would go here
	}
	
	// since no default values have been set (i.e. no preferences file created), create it here
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 baseAppURLDefault,  @"baseServerString", 
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
    [appDelegate displayNotificationTitle:@"Lost Item!" andPrompt:[NSString stringWithFormat:@"%d %@ removed from inventory",qty,item.name]];

    
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

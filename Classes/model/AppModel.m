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
#import "JSONConnection.h"
#import "JSONResult.h"
#import "JSON.h"

static NSString *const nearbyLock = @"nearbyLock";
static NSString *const locationsLock = @"locationsLock";
static const int kDefaultCapacity = 10;
static const int kEmptyValue = -1;

@interface AppModel()

- (NSInteger) validIntForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary;
- (id) validObjectForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary;

@end


@implementation AppModel
@synthesize serverName, baseAppURL, jsonServerBaseURL, loggedIn;
@synthesize username, password, playerId, currentModule;
@synthesize site, gameId, gameList, locationList, playerList;
@synthesize playerLocation, inventory, questList, networkAlert, mediaList;

@synthesize nearbyLocationsList;

#pragma mark Init/dealloc
-(id)init {
    if (self = [super init]) {
		//Init USerDefaults
		defaults = [NSUserDefaults standardUserDefaults];
		mediaList = [[NSMutableDictionary alloc] initWithCapacity:kDefaultCapacity];
	}
			 
    return self;
}

- (void)dealloc {
	[mediaList release];
	[gameList release];
	[baseAppURL release];
	[username release];
	[password release];
	[currentModule release];
	[site release];
    [super dealloc];
}

-(void)loadUserDefaults {
	NSLog(@"Model: Loading User Defaults");
	
	//Load the base App URL
	self.baseAppURL = [defaults stringForKey:@"baseAppURL"];
	
	//Make sure it has a trailing slash (needed in some places)
	int length = [self.baseAppURL length];
	unichar lastChar = [self.baseAppURL characterAtIndex:length-1];
	NSString *lastCharString = [ NSString stringWithCharacters:&lastChar length:1 ];
	if (![lastCharString isEqualToString:@"/"]) self.baseAppURL = [[NSString alloc] initWithFormat:@"%@/",self.baseAppURL];
	
	NSURL *url = [NSURL URLWithString:self.baseAppURL];
	self.serverName = [NSString stringWithFormat:@"http://%@:%d", [url host], 
					   ([url port] ? [[url port] intValue] : 80)];
	
	self.gameId = [defaults integerForKey:@"gameId"];
	self.loggedIn = [defaults boolForKey:@"loggedIn"];
	
	if (loggedIn == YES) {
		if (![baseAppURL isEqualToString:[defaults stringForKey:@"lastBaseAppURL"]]) {
			self.loggedIn = NO;
			NSLog(@"Model: Server URL changed since last execution. Throw out Defaults and use URL: '%@' Site: '%@' GameId: '%d'", baseAppURL, site, gameId);
		}
		else {
			self.username = [defaults stringForKey:@"username"];
			self.password = [defaults stringForKey:@"password"];
			self.playerId = [defaults integerForKey:@"playerId"];
			NSLog(@"Model: Defaults Found. Use URL: '%@' User: '%@' Password: '%@' PlayerId: '%d' GameId: '%d' Site: '%@'", 
				  baseAppURL, username, password, playerId, gameId, site);
		}
	}
	else NSLog(@"Model: Player was not logged in, Initing with Defaults");

	
	self.jsonServerBaseURL = [NSString stringWithFormat:@"%@%@",
						 baseAppURL, @"json.php/aris"];
	
	NSLog(@"AppModel: jsonServerURL is %@",jsonServerBaseURL);
}


-(void)clearUserDefaults {
	NSLog(@"Model: Clearing User Defaults");
	
	[defaults removeObjectForKey:@"loggedIn"];	
	[defaults removeObjectForKey:@"username"];
	[defaults removeObjectForKey:@"password"];
	[defaults removeObjectForKey:@"playerId"];
	[defaults removeObjectForKey:@"gameId"];
	//Don't clear the baseAppURL
}

-(void)saveUserDefaults {
	NSLog(@"Model: Saving User Defaults");
	
	[defaults setBool:loggedIn forKey:@"loggedIn"];
	[defaults setObject:username forKey:@"username"];
	[defaults setObject:password forKey:@"password"];
	[defaults setInteger:playerId forKey:@"playerId"];
	[defaults setInteger:gameId forKey:@"gameId"];
	[defaults setObject:baseAppURL forKey:@"lastBaseAppURL"];
	[defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVerison"];
}

-(void)initUserDefaults {	
	
	//Load the settings bundle data into an array
	NSString *pathStr = [[NSBundle mainBundle] bundlePath];
	NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
	NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	
	//Find the Defaults
	NSString *baseAppURLDefault;
	NSDictionary *prefItem;
	for (prefItem in prefSpecifierArray)
	{
		NSString *keyValueStr = [prefItem objectForKey:@"Key"];
		id defaultValue = [prefItem objectForKey:@"DefaultValue"];
		
		if ([keyValueStr isEqualToString:@"baseAppURL"])
		{
			baseAppURLDefault = defaultValue;
		}
		//More defaults would go here
	}
	
	// since no default values have been set (i.e. no preferences file created), create it here
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 baseAppURLDefault,  @"baseAppURL", 
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
}




#pragma mark Communication with Server
- (BOOL)login {
	NSLog(@"AppModel: Login Requested");
	NSArray *arguments = [NSArray arrayWithObjects:self.username, self.password, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithArisJSONServer:jsonServerBaseURL 
																	andServiceName: @"players" 
																	andMethodName:@"login"
																	andArguments:arguments]; 

	JSONResult *jsonResult = [jsonConnection performSynchronousRequest];
	
	if (!jsonResult) {
		self.loggedIn = NO;
		return NO;
	}
	
	//handle login response
	int returnCode = jsonResult.returnCode;
	NSLog(@"AppModel: Login Result Code: %d", returnCode);
	if(returnCode == 0) {
		self.loggedIn = YES;
		loggedIn = YES;
		playerId = [((NSDecimalNumber*)jsonResult.data) intValue];
	}
	else {
		self.loggedIn = NO;	
	}

	return self.loggedIn;
}

- (BOOL)registerNewUser:(NSString*)userName password:(NSString*)pass 
			  firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email {
	NSLog(@"AppModel: New User Registration Requested");
	//createPlayer($strNewUserName, $strPassword, $strFirstName, $strLastName, $strEmail)
	NSArray *arguments = [NSArray arrayWithObjects:userName, pass, firstName, lastName, email, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithArisJSONServer:jsonServerBaseURL 
																	 andServiceName: @"players" 
																	  andMethodName:@"createPlayer"
																	   andArguments:arguments]; 
	
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest];
	
	if (!jsonResult) {
		NSLog(@"AppModel registerNewUser: No result Data, return");
		return NO;
	}
	
    BOOL success;
	
	int returnCode = jsonResult.returnCode;
	if (returnCode == 0) {
		NSLog(@"AppModel: Result from new user request successfull");
		success = YES;
	}
	else { 
		NSLog(@"AppModel: Result from new user request unsuccessfull");
		success = NO;
	}
	return success;
	
}

- (void)updateServerNodeViewed: (int)nodeId {
	NSLog(@"Model: Node %d Viewed, update server", nodeId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",playerId],
						  [NSString stringWithFormat:@"%d",nodeId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"players" 
																	 andMethodName:@"nodeViewed" 
																	  andArguments:arguments];
	[jsonConnection performAsynchronousRequestWithParser:nil]; 
	
	//Check for any updates to player state
	[self fetchLocationList];
	[self fetchQuestList];
	[self fetchInventory];
}

- (void)updateServerItemViewed: (int)itemId {
	NSLog(@"Model: Item %d Viewed, update server", itemId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"players" 
																	 andMethodName:@"itemViewed" 
																	  andArguments:arguments];
	[jsonConnection performAsynchronousRequestWithParser:nil]; 
	
	//Check for any updates to player state
	[self fetchLocationList];
	[self fetchQuestList];
	[self fetchInventory];
}

- (void)updateServerNpcViewed: (int)npcId {
	NSLog(@"Model: Npc %d Viewed, update server", npcId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",playerId],
						  [NSString stringWithFormat:@"%d",npcId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"players" 
																	 andMethodName:@"npcViewed" 
																	  andArguments:arguments];
	[jsonConnection performAsynchronousRequestWithParser:nil]; 
	
	//Check for any updates to player state
	[self fetchLocationList];
	[self fetchQuestList];
	[self fetchInventory];
}


- (void)updateServerGameSelected{
	NSLog(@"Model: Game %d Selected, update server", gameId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: 
						  [NSString stringWithFormat:@"%d",self.playerId],
						  [NSString stringWithFormat:@"%d",gameId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"players" 
																	 andMethodName:@"updatePlayerLastGame" 
																	  andArguments:arguments];
	[jsonConnection performAsynchronousRequestWithParser:nil]; 
}



- (void)resetPlayerEvents {
	NSLog(@"Model: Clearing Player Events");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"players" 
																	 andMethodName:@"resetEvents" 
																	  andArguments:arguments];
	[jsonConnection performSynchronousRequest]; 
}

- (void)resetPlayerItems {
	NSLog(@"Model: Clearing Player Items");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"players" 
																	 andMethodName:@"resetItems" 
																	  andArguments:arguments];
	[jsonConnection performSynchronousRequest]; 
}

- (void)updateServerPickupItem: (int)itemId fromLocation: (int)locationId {
	NSLog(@"Model: Informing the Server the player picked up item");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  [NSString stringWithFormat:@"%d",locationId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"players" 
																	 andMethodName:@"pickupItemFromLocation" 
																	  andArguments:arguments];
	[jsonConnection performSynchronousRequest]; 
}

- (void)updateServerDropItemHere: (int)itemId {
	NSLog(@"Model: Informing the Server the player dropped an item");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  [NSString stringWithFormat:@"%f",playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",playerLocation.coordinate.longitude],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"players" 
																	 andMethodName:@"dropItem" 
																	  andArguments:arguments];
	[jsonConnection performSynchronousRequest]; 
}

- (void)updateServerDestroyItem: (int)itemId {
	NSLog(@"Model: Informing the Server the player destroyed an item");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"players" 
																	 andMethodName:@"destroyItem" 
																	  andArguments:arguments];
	[jsonConnection performSynchronousRequest]; 
}

- (void)createItemAndGiveToPlayerFromFileData:(NSData *)fileData andFileName:(NSString *)fileName{
	NSLog(@"Model: creating a new Item for an image");

	//Do the file upload first
	NSString* newFileName = [self uploadFileToServerAndGetName:fileData fileName:fileName];
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",self.playerId],
						  @"Name",
						  @"Description",
						  newFileName,
						  @"1",
						  @"1",
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"items" 
																	 andMethodName:@"createItemAndGiveToPlayer" 
																	  andArguments:arguments];
	[jsonConnection performAsynchronousRequestWithParser:nil]; 
	
	 
	[self fetchInventory];	
		
}


- (NSString*)uploadFileToServerAndGetName: (NSData *)fileData fileName:(NSString*)fileName{
	NSLog(@"Model: Preparing to send file to Server");
	
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	//[appDelegate performSelectorInBackground:@selector(showWaitingIndicator:) withObject:@"Uploading Image"];
	[appDelegate showWaitingIndicator:@"Uploading Image"];
	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	
	// setting up the request object now
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@services/aris/uploadHandler.php",self.baseAppURL];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod: @"POST"];
	
	//Add headers
	NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	//body
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// GameID
	[body appendData:[self encode:[NSString stringWithFormat:@"%d", self.gameId] forPostWithName:@"gameID"]];
	
	//image
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:fileData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	// post it
	NSURLResponse *response;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	NSLog(@"Model: File Upload Result from Server: %@", returnString);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[appDelegate removeWaitingIndicator];

	
	return returnString;
}
//sure would be nice to wrap this in with the code above
- (NSData *) encode:(NSString *)data forPostWithName:(NSString *)name {
	NSString *const boundaryMagicString  = @"---------------------------14737809831466499882746641449";
	
	NSData *result = [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n--%@\r\n",
						name, data, boundaryMagicString] dataUsingEncoding:NSUTF8StringEncoding];
	return result;	
}

- (void)updateServerLocationAndfetchNearbyLocationList {
	@synchronized (nearbyLock) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSLog(@"Model: updating player position on server and determining nearby Locations");
		
		if (!loggedIn) {
			NSLog(@"Model: Player Not logged in yet, skip the location update");	
			return;
		}
		
		//init a fresh nearby location list array
		if(nearbyLocationsList != nil) {
			[nearbyLocationsList release];
		}
		nearbyLocationsList = [[NSMutableArray alloc] initWithCapacity:5];
		
		//Update the server with the new Player Location
		NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.playerId],
							  [NSString stringWithFormat:@"%f",playerLocation.coordinate.latitude],
							  [NSString stringWithFormat:@"%f",playerLocation.coordinate.longitude],
							  nil];
		JSONConnection *jsonConnection = [[JSONConnection alloc] initWithArisJSONServer:self.jsonServerBaseURL 
																		 andServiceName:@"players" 
																		  andMethodName:@"updatePlayerLocation" 
																		   andArguments:arguments];
		[jsonConnection performAsynchronousRequestWithParser:nil]; 
		
		//Rebuild nearbyLocationList
		//We could just do this in the getter
		NSEnumerator *locationsListEnumerator = [locationList objectEnumerator];
		Location *location;
		while (location = [locationsListEnumerator nextObject]) {
			//check if the location is close to the player
			if ([playerLocation getDistanceFrom:location.location] < location.error)
				[nearbyLocationsList addObject:location];
		}
		
		//Tell the rest of the app that the nearbyLocationList is fresh
		NSNotification *nearbyLocationListNotification = 
		[NSNotification notificationWithName:@"ReceivedNearbyLocationList" object:nearbyLocationsList];
		[[NSNotificationCenter defaultCenter] postNotification:nearbyLocationListNotification];
		[pool drain];
	}
}


#pragma mark Fetch selectors
- (id) fetchFromService:(NSString *)aService usingMethod:(NSString *)aMethod 
			   withArgs:(NSArray *)arguments usingParser:(SEL)aSelector 
{
	NSLog(@"JSON://%@/%@/%@", aService, aMethod, arguments);
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:aService
																	 andMethodName:aMethod
																	  andArguments:arguments];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest]; 
	
	if (!jsonResult) {
		NSLog(@"\tFailed.");
		return nil;
	}
	
	return [self performSelector:aSelector withObject:jsonResult.data];
}


-(Item *)fetchItem:(int)itemId{
	NSLog(@"Model: Fetch Requested for Item %d", itemId);
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",itemId],
						  nil];

	return [self fetchFromService:@"items" usingMethod:@"getItem" withArgs:arguments 
					  usingParser:@selector(parseItemFromDictionary:)];
}

-(Node *)fetchNode:(int)nodeId{
	NSLog(@"Model: Fetch Requested for Node %d", nodeId);
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",nodeId],
						  nil];
	
	return [self fetchFromService:@"nodes" usingMethod:@"getNode" withArgs:arguments
					  usingParser:@selector(parseNodeFromDictionary:)];
}

-(Npc *)fetchNpc:(int)npcId{
	NSLog(@"Model: Fetch Requested for Npc %d", npcId);
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",npcId],
						  [NSString stringWithFormat:@"%d",self.playerId],
						  nil];
	return [self fetchFromService:@"npcs" usingMethod:@"getNpcWithConversationsForPlayer"
						 withArgs:arguments usingParser:@selector(parseNpcFromDictionary:)];
}

- (void)fetchGameList {
	NSLog(@"AppModel: Fetching Game List.");
	self.gameList = [self fetchFromService:@"games" usingMethod:@"getGames"
						 withArgs:nil usingParser:@selector(parseGameListFromArray:)];
	
	//Tell everyone
	NSLog(@"AppModel: Finished Building the Game List");
	NSNotification *notification = [NSNotification notificationWithName:@"ReceivedGameList" object:self userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)fetchLocationList {
	NSLog(@"AppModel: Fetching Locations from Server");	
	
	if (!loggedIn) {
		NSLog(@"AppModel: Player Not logged in yet, skip the location fetch");	
		return;
	}
			
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", self.gameId],
						  [NSString stringWithFormat:@"%d",self.playerId], 
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"locations"
																	 andMethodName:@"getLocationsForPlayer"
																	  andArguments:arguments];
	[jsonConnection performAsynchronousRequestWithParser:@selector(parseLocationListFromJSON:)]; 
	
}

- (void)forceUpdateOnNextLocationListFetch {
	locationListHash = 0;
}




- (void)fetchMediaList {
	NSLog(@"AppModel: Fetching Media List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",self.gameId], nil];
	
	self.mediaList = [self fetchFromService:@"media" usingMethod:@"getMedia"
									  withArgs:arguments usingParser:@selector(parseMediaListFromArray:)];
	
}


- (void)fetchInventory {
	NSLog(@"Model: Inventory Fetch Requested");
	
	inventory = [NSMutableArray array];
	[inventory retain];
	
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",self.playerId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"items"
																	 andMethodName:@"getItemsForPlayer"
																	  andArguments:arguments];
	[jsonConnection performAsynchronousRequestWithParser:@selector(parseInventoryFromJSON:)]; 
}


-(NSObject<QRCodeProtocol> *)fetchQRCode:(NSString*)QRcodeId{
	NSLog(@"Model: Fetch Requested for QRCodeId: %@", QRcodeId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%@",QRcodeId],
						  [NSString stringWithFormat:@"%d",self.playerId],
						  nil];
	
	return [self fetchFromService:@"qrcodes" usingMethod:@"getQRCodeObjectForPlayer"
				  withArgs:arguments usingParser:@selector(parseQRCodeObjectFromDictionary:)];
	
}	




-(void)fetchQuestList {
	NSLog(@"Model: Fetch Requested for Quests");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",self.gameId],
						  [NSString stringWithFormat:@"%d",playerId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithArisJSONServer:self.jsonServerBaseURL 
																	andServiceName:@"quests"
																	 andMethodName:@"getQuestsForPlayer"
																	  andArguments:arguments];
	
	[jsonConnection performAsynchronousRequestWithParser:@selector(parseQuestListFromJSON:)]; 	
	
}

-(Media *)mediaForMediaId: (int)mId {
	Media *media = [self.mediaList objectForKey:[NSNumber numberWithInt:mId]];
	
	if (!media) {
		//Let's pause everything and do a lookup
		NSLog(@"AppModel: Media not found in cached media List, refresh");
		[self fetchMediaList];
		
		media = [self.mediaList objectForKey:[NSNumber numberWithInt:mId]];
		if (media) NSLog(@"AppModel: Media found after refresh");
		else NSLog(@"AppModel: Media still NOT found after refresh");
	}
	return media;
}

#pragma mark Parsers
- (NSInteger) validIntForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary {
	id theObject = [aDictionary valueForKey:aKey];
	return [theObject respondsToSelector:@selector(intValue)]
		? [theObject intValue] : kEmptyValue;
}

- (id) validObjectForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary {
	id theObject = [aDictionary valueForKey:aKey];
	return theObject == [NSNull null] ? nil : theObject;
}

-(Item *)parseItemFromDictionary: (NSDictionary *)itemDictionary{	
	Item *item = [[Item alloc] init];
	item.itemId = [[itemDictionary valueForKey:@"item_id"] intValue];
	item.name = [itemDictionary valueForKey:@"name"];
	item.description = [itemDictionary valueForKey:@"description"];
	item.mediaId = [[itemDictionary valueForKey:@"media_id"] intValue];
	item.iconMediaId = [[itemDictionary valueForKey:@"icon_media_id"] intValue];
	item.dropable = [[itemDictionary valueForKey:@"dropable"] boolValue];
	item.destroyable = [[itemDictionary valueForKey:@"destroyable"] boolValue];
	NSLog(@"\tadded item %@", item.name);
	
	return item;	
}

-(Node *)parseNodeFromDictionary: (NSDictionary *)nodeDictionary{
	//Build the node
	NSLog(@"%@", nodeDictionary);
	Node *node = [[Node alloc] init];
	node.nodeId = [[nodeDictionary valueForKey:@"node_id"] intValue];
	node.name = [nodeDictionary valueForKey:@"title"];
	node.text = [nodeDictionary valueForKey:@"text"];
	NSLog(@"%@", [nodeDictionary valueForKey:@"media_id"]);
	node.mediaId = [self validIntForKey:@"media_id" inDictionary:nodeDictionary];
	node.answerString = [self validObjectForKey:@"require_answer_string" inDictionary:nodeDictionary];
	node.nodeIfCorrect = [self validIntForKey:@"require_answer_correct_node_id" inDictionary:nodeDictionary];
	node.nodeIfIncorrect = [self validIntForKey:@"require_answer_incorrect_node_id" inDictionary:nodeDictionary];
	
	//Add options here
	int optionNodeId;
	NSString *text;
	NodeOption *option;
	
	if ([nodeDictionary valueForKey:@"opt1_node_id"] != [NSNull null] && [[nodeDictionary valueForKey:@"opt1_node_id"] intValue] > 0) {
		optionNodeId= [[nodeDictionary valueForKey:@"opt1_node_id"] intValue];
		text = [nodeDictionary valueForKey:@"opt1_text"]; 
		option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId];
		[node addOption:option];
	}
	if ([nodeDictionary valueForKey:@"opt2_node_id"] != [NSNull null] && [[nodeDictionary valueForKey:@"opt2_node_id"] intValue] > 0) {
		optionNodeId = [[nodeDictionary valueForKey:@"opt2_node_id"] intValue];
		text = [nodeDictionary valueForKey:@"opt2_text"]; 
		option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId];
		[node addOption:option];
	}
	if ([nodeDictionary valueForKey:@"opt3_node_id"] != [NSNull null] && [[nodeDictionary valueForKey:@"opt3_node_id"] intValue] > 0) {
		optionNodeId = [[nodeDictionary valueForKey:@"opt3_node_id"] intValue];
		text = [nodeDictionary valueForKey:@"opt3_text"]; 
		option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId];
		[node addOption:option];
	}
	
	return node;	
}

-(Npc *)parseNpcFromDictionary: (NSDictionary *)npcDictionary {
	Npc *npc = [[Npc alloc] init];
	npc.npcId = [[npcDictionary valueForKey:@"npc_id"] intValue];
	npc.name = [npcDictionary valueForKey:@"name"];
	npc.greeting = [npcDictionary valueForKey:@"text"];
	npc.description = [npcDictionary valueForKey:@"description"];
	npc.mediaId = [[npcDictionary valueForKey:@"media_id"] intValue];
	
	NSArray *conversationOptions = [npcDictionary objectForKey:@"conversationOptions"];
	NSEnumerator *conversationOptionsEnumerator = [conversationOptions objectEnumerator];
	NSDictionary *conversationDictionary;
	while (conversationDictionary = [conversationOptionsEnumerator nextObject]) {	
		//Make the Node Option and add it to the Npc
		int optionNodeId = [[conversationDictionary valueForKey:@"node_id"] intValue];
		NSString *text = [conversationDictionary valueForKey:@"text"]; 
		NodeOption *option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId];
		[npc addOption:option];
	}
	return npc;	
}

-(NSArray *)parseGameListFromArray: (NSArray *)gameListArray{
	NSMutableArray *tempGameList = [[NSMutableArray alloc] init];
	
	NSEnumerator *gameListEnumerator = [gameListArray objectEnumerator];	
	NSDictionary *gameDictionary;
	while (gameDictionary = [gameListEnumerator nextObject]) {
		//create a new game
		Game *game = [[Game alloc] init];
		game.gameId = [[gameDictionary valueForKey:@"game_id"] intValue];
		game.name = [gameDictionary valueForKey:@"name"];
		NSString *prefix = [gameDictionary valueForKey:@"prefix"];
		//parse out the trailing _ in the prefix
		game.site = [prefix substringToIndex:[prefix length] - 1];
		NSLog(@"Model: Adding Game: %@", game.name);
		[tempGameList addObject:game]; 
	}
	
	return tempGameList;

}

-(void)parseLocationListFromJSON: (JSONResult *)jsonResult{

	NSLog(@"AppModel: Parsing Location List");
	
	//Check for an error
	//Compare this hash to the last one. If the same, stop hee

	if (jsonResult.hash == locationListHash) {
		NSLog(@"AppModel: Hash is same as last location list update, continue");
		return;
	}
	 
	//Save this hash for later comparisions
	locationListHash = jsonResult.hash;
	
	//Continue parsing
	NSArray *locationsArray = (NSArray *)jsonResult.data;
	
	
	//Build the location list
	NSMutableArray *tempLocationsList = [[NSMutableArray alloc] init];
	NSEnumerator *locationsEnumerator = [locationsArray objectEnumerator];	
	NSDictionary *locationDictionary;
	while (locationDictionary = [locationsEnumerator nextObject]) {
		//create a new location
		Location *location = [[Location alloc] init];
		location.locationId = [[locationDictionary valueForKey:@"location_id"] intValue];
		location.name = [locationDictionary valueForKey:@"name"];
		location.iconMediaId = [[locationDictionary valueForKey:@"icon_media_id"] intValue];
		location.location = [[CLLocation alloc] initWithLatitude:[[locationDictionary valueForKey:@"latitude"] doubleValue]
													   longitude:[[locationDictionary valueForKey:@"longitude"] doubleValue]];
		location.error = [[locationDictionary valueForKey:@"error"] doubleValue];
		location.objectType = [locationDictionary valueForKey:@"type"];
		location.objectId = [[locationDictionary valueForKey:@"type_id"] intValue];
		location.hidden = [[locationDictionary valueForKey:@"hidden"] boolValue];
		location.forcedDisplay = [[locationDictionary valueForKey:@"force_view"] boolValue];
		location.qty = [[locationDictionary valueForKey:@"item_qty"] intValue];
		
		NSLog(@"Model: Adding Location: %@", location.name);
		[tempLocationsList addObject:location];
		[location release];
	}
	
	self.locationList = tempLocationsList;
	
	//Tell everyone
	NSLog(@"AppModel: Finished fetching locations from server, model updated");
	NSNotification *notification = 
	[NSNotification notificationWithName:@"ReceivedLocationList" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	
}


-(NSMutableDictionary *)parseMediaListFromArray: (NSArray *)mediaListArray{
	NSMutableDictionary *tempMediaList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [((NSArray *)mediaListArray) objectEnumerator];
	NSDictionary *dict;
	while (dict = [enumerator nextObject]) {
		NSInteger uid = [[dict valueForKey:@"media_id"] intValue];
		NSString *fileName = [dict valueForKey:@"file_name"];
		
		NSString *type = [dict valueForKey:@"type"];
		
		if (uid < 1) {
			NSLog(@"AppModel fetchMediaList: Invalid media id: %d", uid);
			continue;
		}
		if ([fileName length] < 1) {
			NSLog(@"AppModel fetchMediaList: Empty fileName string for media #%d.", uid);
			continue;
		}
		if ([type length] < 1) {
			NSLog(@"AppModel fetchMediaList: Empty type for media #%d", uid);
			continue;
		}
		
		fileName = [NSString stringWithFormat:@"%@gamedata/%d/%@", baseAppURL, gameId, fileName];
		NSLog(@"AppModel fetchMediaList: Full URL: %@", fileName);
		
		Media *media = [[Media alloc] initWithId:uid andUrlString:fileName ofType:type];
		[tempMediaList setObject:media forKey:[NSNumber numberWithInt:uid]];
		[media release];
	}
	
	return tempMediaList;
}


-(void)parseInventoryFromJSON: (JSONResult *)jsonResult{
	NSLog(@"AppModel: Parsing Inventory");
	
	//Check for an error
	
	//Compare this hash to the last one. If the same, stop hee
	
	if (jsonResult.hash == inventoryHash) {
		NSLog(@"AppModel: Hash is same as last inventory listy update, continue");
		return;
	}

	
	//Save this hash for later comparisions
	inventoryHash = jsonResult.hash;
	
	//Continue parsing
	NSArray *inventoryArray = (NSArray *)jsonResult.data;
	
	NSMutableArray *tempInventory = [[NSMutableArray alloc] init];
	NSEnumerator *inventoryEnumerator = [((NSArray *)inventoryArray) objectEnumerator];	
	NSDictionary *itemDictionary;
	while (itemDictionary = [inventoryEnumerator nextObject]) {
		Item *item = [[Item alloc] init];
		item.itemId = [[itemDictionary valueForKey:@"item_id"] intValue];
		item.name = [itemDictionary valueForKey:@"name"];
		item.description = [itemDictionary valueForKey:@"description"];
		item.mediaId = [[itemDictionary valueForKey:@"media_id"] intValue];
		item.iconMediaId = [[itemDictionary valueForKey:@"icon_media_id"] intValue];
		item.dropable = [[itemDictionary valueForKey:@"dropable"] boolValue];
		item.destroyable = [[itemDictionary valueForKey:@"destroyable"] boolValue];
		NSLog(@"Model: Adding Item: %@", item.name);
		[tempInventory addObject:item]; 
		[item release];
	}

	self.inventory = tempInventory;
	
	NSLog(@"AppModel: Finished fetching inventory from server, model updated");
	NSNotification *notification = [NSNotification notificationWithName:@"ReceivedInventory" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	
	//Note: The inventory list VC listener will add the badge now that it knows something is different
	
}


-(NSObject<QRCodeProtocol> *)parseQRCodeObjectFromDictionary: (NSDictionary *)qrCodeObjectDictionary {

	NSString *type = [qrCodeObjectDictionary valueForKey:@"type"];
	NSLog(@"QRCode Type: %@",type);

	if ([type isEqualToString:@"Node"]) return [self parseNodeFromDictionary:qrCodeObjectDictionary];
	if ([type isEqualToString:@"Item"]) return [self parseItemFromDictionary:qrCodeObjectDictionary];
	if ([type isEqualToString:@"Npc"]) return [self parseNpcFromDictionary:qrCodeObjectDictionary];

	return nil;
}



-(void)parseQuestListFromJSON: (JSONResult *)jsonResult{

	NSLog(@"AppModel: Parsing Quests");
	
	//Check for an error
	
	//Compare this hash to the last one. If the same, stop here
	if (jsonResult.hash == questListHash) {
		NSLog(@"AppModel: Hash is same as last quest list update, continue");
		return;
	}
	
	//Save this hash for later comparisions
	questListHash = jsonResult.hash;
	
	//Continue parsing
	NSDictionary *questListDictionary = (NSDictionary *)jsonResult.data;	
	
	
	//parse out the active quests into quest objects
	NSMutableArray *activeQuestObjects = [[NSMutableArray alloc] init];
	NSArray *activeQuests = [questListDictionary objectForKey:@"active"];
	NSEnumerator *activeQuestsEnumerator = [activeQuests objectEnumerator];
	NSDictionary *activeQuest;
	while (activeQuest = [activeQuestsEnumerator nextObject]) {
		//We have a quest, parse it into a quest abject and add it to the activeQuestObjects array
		Quest *quest = [[Quest alloc] init];
		quest.questId = [[activeQuest objectForKey:@"quest_id"] intValue];
		quest.name = [activeQuest objectForKey:@"name"];
		quest.description = [activeQuest objectForKey:@"description"];
		quest.iconMediaId = [[activeQuest objectForKey:@"icon_media_id"] intValue];
		[activeQuestObjects addObject:quest];
	}

	//parse out the completed quests into quest objects	
	NSMutableArray *completedQuestObjects = [[NSMutableArray alloc] init];
	NSArray *completedQuests = [questListDictionary objectForKey:@"completed"];
	NSEnumerator *completedQuestsEnumerator = [completedQuests objectEnumerator];
	NSDictionary *completedQuest;
	while (completedQuest = [completedQuestsEnumerator nextObject]) {
		//We have a quest, parse it into a quest abject and add it to the completedQuestObjects array
		Quest *quest = [[Quest alloc] init];
		quest.questId = [[completedQuest objectForKey:@"quest_id"] intValue];
		quest.name = [completedQuest objectForKey:@"name"];
		quest.description = [completedQuest objectForKey:@"text_when_complete"];
		quest.iconMediaId = [[completedQuest objectForKey:@"icon_media_id"] intValue];
		[completedQuestObjects addObject:quest];
	}

	//Package the two object arrays in a Dictionary
	NSMutableDictionary *tmpQuestList = [[NSMutableDictionary alloc] init];
	[tmpQuestList setObject:activeQuestObjects forKey:@"active"];
	[tmpQuestList setObject:completedQuestObjects forKey:@"completed"];
	
	self.questList = tmpQuestList;
	
	//Sound the alarm
	NSLog(@"AppModel: Finished fetching quests from server, model updated");
	NSNotification *notification = [NSNotification notificationWithName:@"ReceivedQuestList" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	
}

@end

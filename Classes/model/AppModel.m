//
//  AppModel.m
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AppModel.h"

#import "Constants.h"
#import "GameListParserDelegate.h"
#import "LocationListParserDelegate.h"
#import "NearbyLocationsListParserDelegate.h"
#import "InventoryParserDelegate.h"
#import "XMLParserDelegate.h"

#import "Item.h"
#import "NPC.h"
#import "Option.h"
#import "NearbyLocation.h"
#import "XMLParserDelegate.h"

@implementation AppModel

NSDictionary *InventoryElements;
NSDictionary *NearbyLocationsElements;
NSDictionary *NodeElements;
NSDictionary *NPCElements;

@synthesize serverName;
@synthesize baseAppURL;
@synthesize loggedIn;
@synthesize username;
@synthesize password;
@synthesize currentModule;
@synthesize site;
@synthesize gameList;
@synthesize locationList;
@synthesize nearbyLocationsList;
@synthesize lastLocation;
@synthesize inventory;
@synthesize nodeList, npcList;

-(id)init {
    if (self = [super init]) {
		//Init USerDefaults
		defaults = [NSUserDefaults standardUserDefaults];
		
		//Init Inventory XML Parsing info
		if (InventoryElements == nil) {	
			InventoryElements = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNull null], @"result",
								 [NSNull null], @"frameworkTplPath",
								 [NSNull null], @"isIphone",
								 [NSNull null], @"site",
								 [NSNull null], @"title",
								 [NSNull null], @"inventory",
			 [NSDictionary dictionaryWithObjectsAndKeys:
			  [Item class], @"__CLASS_NAME",
			  @"setItemId:", @"item_id",
			  @"setName:", @"name",
			  @"setDescription:", @"description",
			  @"setType:", @"type",
			  @"setMediaURL:", @"media",
			  @"setIconURL:", @"icon",
			  nil
			  ], @"row", 
			nil];
			[InventoryElements retain];
		}
		if (NearbyLocationsElements == nil) {
			NearbyLocationsElements = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNull null], @"result",
								 [NSNull null], @"results",
								 [NSNull null], @"frameworkTplPath",
								 [NSNull null], @"isIphone",
								 [NSNull null], @"site",
								 [NSNull null], @"title",
								 [NSNull null], @"function",
								[NSDictionary dictionaryWithObjectsAndKeys:
								  [Item class], @"__CLASS_NAME",
								  @"setItemId:", @"id",
								  @"setName:", @"name",
								  @"setDescription:", @"description",
								  @"setType:", @"type",
								  @"setMediaURL:", @"media",
								  @"setIconURL:", @"icon",
								  nil
								  ], @"item",
								[NSDictionary dictionaryWithObjectsAndKeys:
								  [NearbyLocation class], @"__CLASS_NAME",
								  @"setLocationId:", @"locationId",
								  @"setName:", @"name",
								  @"setURL:", @"url",
								  @"setType:", @"type",
								  @"setIconURL:", @"icon",
								  @"setForcedDisplay:", @"forceView",
								  nil
								], @"node", 
								[NSDictionary dictionaryWithObjectsAndKeys:
								  [NearbyLocation class], @"__CLASS_NAME",
								  @"setLocationId:", @"locationId",
								  @"setName:", @"name",
								  @"setURL:", @"url",
								  @"setType:", @"type",
								  @"setIconURL:", @"icon",
								  @"setForcedDisplay:", @"forceView",
								  nil
								], @"npc", 
								nil];
			[NearbyLocationsElements retain];
		}
		if (NodeElements == nil) {
			NodeElements = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSNull null], @"result",
									   [NSNull null], @"frameworkTplPath",
									   [NSNull null], @"isIphone",
									   [NSNull null], @"site",
									   [NSNull null], @"messages",
									   [NSNull null], @"conversations",
									   [NSNull null], @"wwwBase",
									   [NSNull null], @"npc",
									   [NSNull null], @"title",
									   [NSDictionary dictionaryWithObjectsAndKeys:
										[Node class], @"__CLASS_NAME",
										@"setName:", @"title",
										@"setDescription:", @"text",
										@"setOptionOneText:", @"opt1_text",
										@"setOptionOneId:", @"opt1_node_id",
										@"setOptionTwoText:", @"opt2_text",
										@"setOptionTwoId:", @"opt2_node_id",
										@"setOptionThreeText:", @"opt3_text",
										@"setOptionThreeId:", @"opt3_node_id",										
										nil
										], @"node",
									   nil];
			[NodeElements retain];
		}
		if (NPCElements == nil) {
			NPCElements = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNull null], @"result",
						   [NSNull null], @"frameworkTplPath",
						   [NSNull null], @"isIphone",
						   [NSNull null], @"site",
						   [NSNull null], @"messages",
						   [NSNull null], @"conversations",
						   [NSNull null], @"wwwBase",
						   [NSNull null], @"node",
						   [NSNull null], @"title",
						   [NSDictionary dictionaryWithObjectsAndKeys:
							[NPC class], @"__CLASS_NAME",
							@"setName:", @"name",
							@"setDescription:", @"text",
							@"setMediaURL:", @"media",
							@"setNpcID:", @"npc_id",
							nil
							], @"npc",
						   [NSDictionary dictionaryWithObjectsAndKeys:
							[Option class], @"__CLASS_NAME",
							@"setText:", @"text",
							@"setNodeIdFromString:", @"node_id",
							nil
							], @"row",
						   nil];
			[NPCElements retain];
		}
	}
			 
    return self;
}


-(void)loadUserDefaults {
	NSLog(@"Model: Loading User Defaults");
	
	//Load the base App URL and calculate the serverName (we should move the calculation to a geter)
	self.baseAppURL = [defaults stringForKey:@"baseAppURL"];
	
	//Make sure it has a trailing slash (needed in some places)
	int length = [self.baseAppURL length];
	unichar lastChar = [self.baseAppURL characterAtIndex:length-1];
	NSString *lastCharString = [ NSString stringWithCharacters:&lastChar length:1 ];
	if (![lastCharString isEqualToString:@"/"]) self.baseAppURL = [[NSString alloc] initWithFormat:@"%@/",self.baseAppURL];
	
	NSURL *url = [NSURL URLWithString:self.baseAppURL];
	self.serverName = [NSString stringWithFormat:@"http://%@:%@", [url host], [url port]];
	
	self.site = [defaults stringForKey:@"site"];
	self.loggedIn = [defaults boolForKey:@"loggedIn"];
	
	if (loggedIn == YES) {
		if (![baseAppURL isEqualToString:[defaults stringForKey:@"lastBaseAppURL"]]) {
			self.loggedIn = NO;
			self.site = @"Default";
			NSLog(@"Model: Server URL changed since last execution. Throw out Defaults and use URL: '%@' Site: '%@'", baseAppURL, site);
		}
		else {
			self.username = [defaults stringForKey:@"username"];
			self.password = [defaults stringForKey:@"password"];
			NSLog(@"Model: Defaults Found. Use URL: '%@' User: '%@' Password: '%@' Site: '%@'", baseAppURL, username, password, site);
		}
	}
	else NSLog(@"Model: No default User Data to Load. Use URL: '%@' Site: '%@'", baseAppURL, site);
}


-(void)clearUserDefaults {
	NSLog(@"Model: Clearing User Defaults");
	
	[defaults removeObjectForKey:@"loggedIn"];	
	[defaults removeObjectForKey:@"username"];
	[defaults removeObjectForKey:@"password"];
	//Don't clear the baseAppURL
	[defaults setObject:@"Default" forKey:@"site"];

}


-(void)saveUserDefaults {
	NSLog(@"Model: Saving User Defaults");
	
	[defaults setBool:loggedIn forKey:@"loggedIn"];
	[defaults setObject:username forKey:@"username"];
	[defaults setObject:password forKey:@"password"];
	[defaults setObject:baseAppURL forKey:@"lastBaseAppURL"];
	[defaults setObject:site forKey:@"site"];
	[defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVerison"];
	
}


-(void)initUserDefaults {	
	NSDictionary *initDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"http://atsosxdev.doit.wisc.edu/aris/games", @"baseAppURL",
								  @"Default", @"site",
								  nil];

	[defaults registerDefaults:initDefaults];
}


- (BOOL)login {
	BOOL loginSuccessful = NO;
	
	//Check with the Server
	NSURLRequest *keyRequest = [self getURLForModule:@"RESTLogin"];
	NSData *loginData = [self fetchURLData:keyRequest];
	NSString *loginResponse = [[NSString alloc] initWithData:loginData encoding:NSASCIIStringEncoding];
	
	//handle login response
	if([loginResponse isEqual:@"1"]) {
		loginSuccessful = YES;
	}
	
	loggedIn = loginSuccessful;
	
	return loginSuccessful;
}

//Returns the complete URL for the module, including authentication
-(NSMutableURLRequest *)getURLForModule:(NSString *)moduleName {
	NSString *urlString = [self getURLStringForModule:moduleName];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
												cachePolicy:NSURLRequestUseProtocolCachePolicy
												timeoutInterval:15.0];
	return urlRequest;
}

//Returns the complete URL for the module, including authentication
-(NSString *)getURLStringForModule:(NSString *)moduleName {
	NSString *URLString = [[[NSString alloc] initWithFormat:@"%@?module=%@&site=%@&user_name=%@&password=%@",
							baseAppURL, moduleName, site, username, password] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSLog(@"Model: URL String for Module was = %@",URLString);
	return URLString;
}

//Returns the complete URL for the server
-(NSMutableURLRequest *)getURL:(NSString *)relativeURL {
	NSString *urlString = [self getURLString:relativeURL];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:15.0];
	return urlRequest;
}

//Returns the complete URL for the server
-(NSString *) getURLString:(NSString *)relativeURL {
	NSString *URLString = [[[NSString alloc] initWithFormat:@"%@%@", serverName, relativeURL]  stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSLog(@"Model: URL String for Module was = %@",URLString);
	return URLString;
}

//Returns the complete URL including the engine path
-(NSMutableURLRequest *)getEngineURL:(NSString *)relativeURL {
	NSString *urlString = [self getEngineURLString:relativeURL];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:15.0];
	return urlRequest;
}

//Returns the complete URL including the engine path
-(NSString *) getEngineURLString:(NSString *)relativeURL {
	NSString *URLString = [[[NSString alloc] initWithFormat:@"%@/%@", baseAppURL, relativeURL]  stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSLog(@"Model: URL String for Module was = %@",URLString);
	return URLString;
}



-(NSData *) fetchURLData: (NSURLRequest *)request {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSURLResponse *response = NULL;
	NSError *error = NULL;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (error != NULL) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"ARIS is not able to communicate with the server. Check your internet connection."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}

	return data;
}

- (void)fetchGameList {
	NSLog(@"AppModel: Fetching Game List.");
	
	//init location list array
	if(gameList != nil) {
		[gameList release];
	}
	gameList = [NSMutableArray array];
	[gameList retain];
	
	//Fetch the Data
	NSURLRequest *request = [self getURLForModule:@"RESTSelectGame"];
	NSData *data = [self fetchURLData:request];

	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	GameListParserDelegate *gameListParserDelegate = [[GameListParserDelegate alloc] initWithGameList:gameList];
	
	[parser setDelegate:gameListParserDelegate];
	
	//init parser
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
}


- (void)fetchLocationList {
	NSLog(@"Fetching All Locations.");
	
	//init location list array
	if(locationList != nil) {
		[locationList release];
	}
	locationList = [NSMutableArray array];
	[locationList retain];
	
	//Fetch Data
	NSURLRequest *request = [self getURLForModule:@"RESTMap"];
	NSData *data = [self fetchURLData:request];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	LocationListParserDelegate *locationListParserDelegate = [[LocationListParserDelegate alloc] initWithLocationList:locationList];
	[parser setDelegate:locationListParserDelegate];
	
	//init parser
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
}


- (void)fetchInventory {
	NSLog(@"Model: Inventory Fetch Requested");
	//init inventory array
	if(inventory != nil) {
		NSLog(@"*** Releasing inventory ***");
		[inventory release];
	}

	inventory = [NSMutableArray array];
	[inventory retain];
	
	//Fetch Data
	NSURLRequest *request = [self getURLForModule:@"Inventory&controller=SimpleREST"];
	NSData *data = [self fetchURLData:request];
	
	
	XMLParserDelegate *parserDelegate = [[XMLParserDelegate alloc] initWithDictionary:InventoryElements
																		   andResults:inventory forNotification:@"ReceivedInventory"];
	[self startParsing:data usingDelegate:parserDelegate];
}

-(void)fetchNode: (NSString *)fromURL {
	if (nodeList != nil) [nodeList release];
	nodeList = [NSMutableArray array];
	[nodeList retain];
	
	NSURLRequest *request = [self getURLForModule:[NSString stringWithFormat:@"%@&controller=SimpleREST", fromURL]];
	NSData *data = [self fetchURLData:request];
	XMLParserDelegate *parserDelegate = [[XMLParserDelegate alloc] initWithDictionary:NodeElements
																		   andResults:nodeList
																	  forNotification:NODE_NOTIFICATION];
	[self startParsing:data usingDelegate:parserDelegate];
}

-(void)fetchConversations: (NSString *)fromURL {
	if (npcList != nil) [npcList release];
	npcList = [NSMutableArray array];
	[npcList retain];
	
	NSURLRequest *request = [self getURLForModule:[NSString stringWithFormat:@"%@&controller=SimpleREST", fromURL]];
	NSData *data = [self fetchURLData:request];
	XMLParserDelegate *parserDelegate = [[XMLParserDelegate alloc] initWithDictionary:NPCElements
																		   andResults:npcList
																	  forNotification:NPC_NOTIFICATION];
	[self startParsing:data usingDelegate:parserDelegate];
}

-(void)startParsing: (NSData *)data usingDelegate:(XMLParserDelegate *)delegate {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:delegate];
	
	//init parser
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
}

- (void)updateServerLocationAndfetchNearbyLocationList {
	//init a fresh nearby location list array
	if(nearbyLocationsList != nil) {
		[nearbyLocationsList release];
	}
	nearbyLocationsList = [NSMutableArray array];
	[nearbyLocationsList retain];


	//Fetch Data
	NSURLRequest *request = [self getURLForModule:
							 [NSString stringWithFormat:@"Async&controller=SimpleREST&latitude=%f&longitude=%f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude]];
	NSData *data = [self fetchURLData:request];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];	
	
	//NearbyLocationsListParserDelegate *nearbyLocationsListParserDelegate = [[NearbyLocationsListParserDelegate alloc] initWithNearbyLocationsList:nearbyLocationsList];
	XMLParserDelegate *parserDelegate = [[XMLParserDelegate alloc] initWithDictionary:NearbyLocationsElements
																		   andResults:nearbyLocationsList 
																	  forNotification:@"ReceivedNearbyLocationList"];
	
	[parser setDelegate:parserDelegate];

	//init parser
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
}



- (void)dealloc {
	[gameList release];
	[baseAppURL release];
	[username release];
	[password release];
	[currentModule release];
	[site release];
	[InventoryElements release];
    [super dealloc];
}

@end

//
//  AppModel.m
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AppModel.h"
#import "GameListParserDelegate.h"
#import "LocationListParserDelegate.h"
#import "NearbyLocationsListParserDelegate.h"
#import "InventoryParserDelegate.h"

#import "Item.h"
#import "XMLParserDelegate.h"


@implementation AppModel

NSDictionary *InventoryElements;

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

-(id)init {
    if (self = [super init]) {
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
		NSLog(@"Testing InventoryElements nilp? %@", InventoryElements);
	}
			 
    return self;
}

-(void)loadUserDefaults {
	//Load user settings
	NSLog(@"Loading User Defaults");
	NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
	//if ([defaults stringForKey:@"baseAppURL"]) baseAppURL = [defaults stringForKey:@"baseAppURL"];
	loggedIn = [defaults boolForKey:@"loggedIn"];
	if (loggedIn == YES) {
		username = [defaults stringForKey:@"username"];
		password = [defaults stringForKey:@"password"];
		site = [defaults stringForKey:@"site"];
		NSLog([NSString stringWithFormat:@"Defaults Found. User: %@ Password: %@ Site: %@", username, password, site]);
	}
	else NSLog(@"No Data to Load");
	[defaults release];
}

- (BOOL)login {
	BOOL loginSuccessful = NO;
	//piece together URL
	NSString *urlString = [NSString stringWithFormat:@"%@?module=RESTLogin&user_name=%@&password=%@",
						   baseAppURL, username, password];
	
	NSLog(urlString);
	//try login
	NSURLRequest *keyRequest = [NSURLRequest requestWithURL: [NSURL URLWithString:urlString]
												cachePolicy:NSURLRequestUseProtocolCachePolicy
												timeoutInterval:60.0];
	
	NSURLResponse *response = NULL;
	NSData *loginData = [NSURLConnection sendSynchronousRequest:keyRequest returningResponse:&response error:NULL];
	
	NSString *loginResponse = [[NSString alloc] initWithData:loginData encoding:NSASCIIStringEncoding];
	
	//handle login response
	if([loginResponse isEqual:@"1"]) {
		loginSuccessful = YES;
	}
	
	loggedIn = loginSuccessful;
	
	return loginSuccessful;
}

-(NSURLRequest *)getURLForModule:(NSString *)moduleName {
	NSString *urlString = [self getURLStringForModule:moduleName];
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	return urlRequest;
}

-(NSString *)getURLStringForModule:(NSString *)moduleName {
	NSString *urlString = [NSString stringWithFormat:@"%@?module=%@&site=%@&user_name=%@&password=%@",
						   baseAppURL, moduleName, site, username, password];
	return urlString;
}

-(NSString *) getURLString:(NSString *)relativeURL {
	return [[[NSString alloc] initWithFormat:@"%@%@", serverName, relativeURL]  stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

- (void)fetchGameList {
	//init location list array
	if(gameList != nil) {
		[gameList release];
	}
	gameList = [NSMutableArray array];
	[gameList retain];
	
	//init url
	NSString *urlString = [NSString stringWithFormat:@"%@?module=RESTSelectGame&user_name=%@&password=%@",
									baseAppURL, username, password];
	NSLog(@"Fetching Game List from: %@", urlString );

	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
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
	//init location list array
	if(locationList != nil) {
		[locationList release];
	}
	locationList = [NSMutableArray array];
	[locationList retain];
	
	//init url
	NSString *urlString = [NSString stringWithFormat:@"%@?module=RESTMap&site=%@&user_name=%@&password=%@",
						   baseAppURL, site, username, password];
	NSLog([NSString stringWithFormat:@"Fetching All Locations from : %@", urlString]);
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
	
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
	
	//init url
	NSString *urlString = [self getURLStringForModule:@"Inventory&controller=SimpleREST"];	
	NSLog([NSString stringWithFormat:@"Fetching Inventory from : %@", urlString]);
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
	
	XMLParserDelegate *parserDelegate = [[XMLParserDelegate alloc] initWithDictionary:InventoryElements
																		   andResults:inventory forNotification:@"ReceivedInventory"];
	[parser setDelegate:parserDelegate];
	
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
	
	//init url
	NSString *urlString = [NSString stringWithFormat:@"%@?module=RESTAsync&site=%@&user_name=%@&password=%@&latitude=%f&longitude=%f",
						   baseAppURL, site, username, password, lastLocation.coordinate.latitude, lastLocation.coordinate.longitude];
	
	NSLog([NSString stringWithFormat:@"Fetching Nearby Locations from : %@", urlString]);
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
	
	NearbyLocationsListParserDelegate *nearbyLocationsListParserDelegate = [[NearbyLocationsListParserDelegate alloc] initWithNearbyLocationsList:nearbyLocationsList];
	[parser setDelegate:nearbyLocationsListParserDelegate];
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

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


@implementation AppModel

@synthesize baseAppURL;
@synthesize loggedIn;
@synthesize username;
@synthesize password;
@synthesize currentModule;
@synthesize site;
@synthesize gameList;
@synthesize locationList;
@synthesize nearbyLocationsList;
@synthesize lastLatitude;
@synthesize lastLongitude;
@synthesize lastLocationAccuracy;
@synthesize inventory;


-(void)loadUserDefaults {
	//Load user settings
	NSLog(@"Loading User Defaults");
	NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
	if ([defaults stringForKey:@"baseAppURL"]) baseAppURL = [defaults stringForKey:@"baseAppURL"];
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
	NSString *urlString = [NSString stringWithFormat:@"%@?module=RESTLogin&site=%@&user_name=%@&password=%@",
						   baseAppURL, site, username, password];
	
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
	NSString *urlString = [NSString stringWithFormat:@"%@?module=%@&site=%@&user_name=%@&password=%@",
									baseAppURL, moduleName, site, username, password];
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	return urlRequest;
}

-(NSString *)getURLStringForModule:(NSString *)moduleName {
	NSString *urlString = [NSString stringWithFormat:@"%@?module=%@&site=%@&user_name=%@&password=%@",
						   baseAppURL, moduleName, site, username, password];
	return urlString;
}

- (void)fetchGameList {
	//init location list array
	if(gameList != nil) {
		[gameList release];
	}
	gameList = [NSMutableArray array];
	[gameList retain];
	
	//init url
	NSString *urlString = [NSString stringWithFormat:@"%@?module=RESTSelectGame&site=%@&user_name=%@&password=%@",
									baseAppURL, site, username, password];

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
	//init inventory array
	if(inventory != nil) {
		[inventory release];
	}
	inventory = [NSMutableArray array];
	[inventory retain];
	
	//init url
	NSString *urlString = [NSString stringWithFormat:@"%@?module=RESTInventory&site=%@&user_name=%@&password=%@",
						   baseAppURL, site, username, password];
	NSLog([NSString stringWithFormat:@"Fetching Inventory from : %@", urlString]);
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
	
	InventoryParserDelegate *inventoryParserDelegate = [[InventoryParserDelegate alloc] initWithInventory:inventory];
	[parser setDelegate:inventoryParserDelegate];
	
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
	NSString *urlString = [NSString stringWithFormat:@"%@?module=RESTAsync&site=%@&user_name=%@&password=%@&latitude=%@&longitude=%@",
						   baseAppURL, site, username, password, self.lastLatitude, self.lastLongitude];
	
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
    [super dealloc];
}

@end

//
//  AppModel.h
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "Game.h"
#import "Node.h";
#import "XMLParserDelegate.h"

extern NSDictionary *InventoryElements;
extern NSDictionary *NearbyLocationsElements;

@interface AppModel : NSObject {
	NSUserDefaults *defaults;
	NSString *serverName;
	NSString *baseAppURL;
	BOOL loggedIn;
	NSString *username;
	NSString *password;
	UIViewController *currentModule;
	NSString *site;
	NSMutableArray *gameList;
	NSMutableArray *locationList;
	NSMutableArray *nearbyLocationsList;
	CLLocation *lastLocation;
	NSMutableArray *inventory;
	NSMutableArray *nodeList;
	NSMutableArray *npcList;
}

@property(copy) NSString *serverName;
@property(copy, readwrite) NSString *baseAppURL;
@property(readwrite) BOOL loggedIn;
@property(copy, readwrite) NSString *username;
@property(copy, readwrite) NSString *password;
@property(copy, readwrite) UIViewController *currentModule;
@property(copy, readwrite) NSString *site;
@property(copy, readwrite) NSMutableArray *gameList;	
@property(copy, readwrite) NSMutableArray *locationList;	
@property(copy, readwrite) NSMutableArray *nearbyLocationsList;	
@property(copy, readwrite) CLLocation *lastLocation;	
@property(copy, readwrite) NSMutableArray *inventory;	
@property(retain, readwrite) NSMutableArray *nodeList;
@property(retain, readwrite) NSMutableArray *npcList;

-(id)init;
-(void)loadUserDefaults;
-(void)clearUserDefaults;
-(void)saveUserDefaults;
-(void)initUserDefaults;
-(BOOL)login;
-(void)fetchGameList;
-(void)fetchLocationList;
-(void)fetchInventory;
-(void)fetchNode: (NSString *)fromURL;
-(void)fetchConversations: (NSString *)fromURL;
-(void)updateServerLocationAndfetchNearbyLocationList;
-(NSMutableURLRequest *) getURLForModule:(NSString *)moduleName;
-(NSString *)getURLStringForModule:(NSString *)moduleName;
-(NSString *) getURLString:(NSString *)relativeURL;
-(NSMutableURLRequest *)getURL:(NSString *)relativeURL;
-(NSMutableURLRequest *)getEngineURL:(NSString *)relativeURL;
-(NSString *) getEngineURLString:(NSString *)relativeURL;
-(NSData *) fetchURLData: (NSURLRequest *)request;


@end

@interface AppModel()
-(void)startParsing: (NSData *)data usingDelegate:(XMLParserDelegate *)delegate;
@end


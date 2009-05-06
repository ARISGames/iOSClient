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

extern NSDictionary *InventoryElements;

@interface AppModel : NSObject {
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

-(id)init;
-(void)loadUserDefaults;
-(BOOL)login;
-(void)fetchGameList;
-(void)fetchLocationList;
-(void)fetchInventory;
-(void)updateServerLocationAndfetchNearbyLocationList;
-(NSURLRequest *) getURLForModule:(NSString *)moduleName;
-(NSString *)getURLStringForModule:(NSString *)moduleName;
-(NSString *) getURLString:(NSString *)relativeURL;

@end

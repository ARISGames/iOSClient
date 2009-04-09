//
//  AppModel.h
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h";

@interface AppModel : NSObject {
	NSString *baseAppURL;
	BOOL loggedIn;
	NSString *username;
	NSString *password;
	UIViewController *currentModule;
	NSString *site;
	NSMutableArray *gameList;
	NSMutableArray *locationList;
	NSMutableArray *nearbyLocationsList;
	NSString *lastLatitude;
	NSString *lastLongitude;
	float lastLocationAccuracy;
	NSMutableArray *inventory;
}

@property(copy, readwrite) NSString *baseAppURL;
@property(readwrite) BOOL loggedIn;
@property(copy, readwrite) NSString *username;
@property(copy, readwrite) NSString *password;
@property(copy, readwrite) UIViewController *currentModule;
@property(copy, readwrite) NSString *site;
@property(copy, readwrite) NSMutableArray *gameList;	
@property(copy, readwrite) NSMutableArray *locationList;	
@property(copy, readwrite) NSMutableArray *nearbyLocationsList;	
@property(copy, readwrite) NSString *lastLatitude;
@property(copy, readwrite) NSString *lastLongitude;
@property(readwrite) float lastLocationAccuracy;
@property(copy, readwrite) NSMutableArray *inventory;	

-(void)loadUserDefaults;
-(BOOL)login;
-(void)fetchGameList;
-(void)fetchLocationList;
-(void)fetchInventory;
-(void)updateServerLocationAndfetchNearbyLocationList;
-(NSURLRequest *) getURLForModule:(NSString *)moduleName;
-(NSString *)getURLStringForModule:(NSString *)moduleName;

@end

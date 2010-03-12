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
#import "Item.h"
#import "Node.h"
#import "Npc.h"

extern NSDictionary *InventoryElements;

@interface AppModel : NSObject {
	NSUserDefaults *defaults;
	NSString *serverName;
	NSString *baseAppURL;
	NSString *jsonServerBaseURL;
	NSString *site;
	int gameId;
	UIViewController *currentModule;
	UIAlertView *networkAlert;
	
	BOOL loggedIn;
	int playerId;
	NSString *username;
	NSString *password;
	CLLocation *playerLocation;

	NSMutableArray *gameList;
	NSMutableArray *locationList;
	NSInteger locationListHash;
	NSMutableArray *playerList;
	NSMutableArray *nearbyLocationsList;
	NSMutableArray *inventory;
	NSInteger inventoryHash; 
	NSMutableDictionary *questList;
	NSInteger questListHash;
	NSMutableDictionary *mediaList;
}

@property(copy) NSString *serverName;
@property(copy, readwrite) NSString *baseAppURL;
@property(copy, readwrite) NSString *jsonServerBaseURL;
@property(readwrite) BOOL loggedIn;
@property(copy, readwrite) NSString *username;
@property(copy, readwrite) NSString *password;
@property(readwrite) int playerId;
@property(copy, readwrite) UIViewController *currentModule;
@property(copy, readwrite) NSString *site;
@property(readwrite) int gameId;
@property(copy, readwrite) NSMutableArray *gameList;	
@property(copy, readwrite) NSMutableArray *locationList;
@property(copy, readwrite) NSMutableArray *playerList;
@property(copy, readwrite) NSMutableDictionary *questList;
@property(copy, readwrite) NSMutableDictionary *mediaList;
@property(copy, readwrite) NSMutableArray *nearbyLocationsList;	
@property(copy, readwrite) CLLocation *playerLocation;	
@property(copy, readwrite) NSMutableArray *inventory;

@property(retain) UIAlertView *networkAlert;


- (id)init;
- (void)loadUserDefaults;
- (void)clearUserDefaults;
- (void)saveUserDefaults;
- (void)initUserDefaults;

- (BOOL)login;

- (id) fetchFromService:(NSString *)aService usingMethod:(NSString *)aMethod 
			   withArgs:(NSArray *)arguments usingParser:(SEL)aSelector;

- (void)fetchGameList;
- (void)fetchLocationList;
- (void)forceUpdateOnNextLocationListFetch;
- (void)fetchMediaList;
- (void)fetchInventory;
- (void)fetchQuestList;
- (Item *)fetchItem:(int)itemId;
- (Node *)fetchNode:(int)nodeId;
- (Npc *)fetchNpc:(int)npcId;
	
- (void)updateServerLocationAndfetchNearbyLocationList;
- (void)updateServerNodeViewed: (int)nodeId;
- (void)updateServerItemViewed: (int)itemId;
- (void)updateServerPickupItem: (int)itemId fromLocation: (int)locationId;
- (void)updateServerDropItemHere: (int)itemId;
- (void)updateServerDestroyItem: (int)itemId;
- (void)resetPlayerEvents;
- (void)resetPlayerItems;
- (void)createItemForImage: (UIImage *)image;
- (BOOL)registerNewUser:(NSString*)userName password:(NSString*)pass 
			  firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email;

- (Item *)parseItemFromDictionary: (NSDictionary *)itemDictionary;
- (Node *)parseNodeFromDictionary: (NSDictionary *)nodeDictionary;
- (Npc *)parseNpcFromDictionary: (NSDictionary *)npcDictionary;
- (void)updateServerGameSelected;
-(NSObject<QRCodeProtocol> *)fetchQRCode:(NSString*)QRcodeId;

@end

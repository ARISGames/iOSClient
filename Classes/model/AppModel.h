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
#import "Media.h"

extern NSDictionary *InventoryElements;

@interface AppModel : NSObject {
	NSUserDefaults *defaults;
	NSString *serverName;
	NSString *baseAppURL;
	NSString *jsonServerBaseURL;
	NSString *site;
	int gameId;
	int gamePcMediaId;
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
	NSMutableDictionary *gameMediaList;
	NSMutableDictionary *gameItemList;
	NSMutableDictionary *gameNodeList;
	NSMutableDictionary *gameNpcList;

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
@property(readwrite) int gamePcMediaId;
@property(copy, readwrite) NSMutableArray *gameList;	
@property(nonatomic, retain) NSMutableArray *locationList;
@property(copy, readwrite) NSMutableArray *playerList;
@property(copy, readwrite) NSMutableDictionary *questList;
@property(copy, readwrite) NSMutableArray *nearbyLocationsList;	
@property(copy, readwrite) CLLocation *playerLocation;	
@property(nonatomic, retain) NSMutableArray *inventory;
@property(retain) UIAlertView *networkAlert;

@property(copy, readwrite) NSMutableDictionary *gameMediaList;
@property(copy, readwrite) NSMutableDictionary *gameItemList;
@property(copy, readwrite) NSMutableDictionary *gameNodeList;
@property(copy, readwrite) NSMutableDictionary *gameNpcList;


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
- (void)fetchGameMediaList;
- (void)fetchGameItemList;
- (void)fetchGameNodeList;
- (void)fetchInventory;
- (void)fetchQuestList;
- (Item *)fetchItem:(int)itemId;
- (Node *)fetchNode:(int)nodeId;
- (Npc *)fetchNpc:(int)npcId;
- (Media *)mediaForMediaId:(int)mId;

	
- (void)updateServerLocationAndfetchNearbyLocationList;
- (void)updateServerNodeViewed: (int)nodeId;
- (void)updateServerItemViewed: (int)itemId;
- (void)updateServerNpcViewed: (int)npcId;
- (void)updateServerMapViewed;
- (void)updateServerQuestsViewed;
- (void)updateServerInventoryViewed;
- (void)updateServerPickupItem: (int)itemId fromLocation: (int)locationId;
- (void)updateServerDropItemHere: (int)itemId;
- (void)updateServerDestroyItem: (int)itemId;
- (void)startOverGame;
- (void)silenceNextServerUpdate;
- (BOOL)registerNewUser:(NSString*)userName password:(NSString*)pass 
			  firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email;


- (Item *)parseItemFromDictionary: (NSDictionary *)itemDictionary;
- (Node *)parseNodeFromDictionary: (NSDictionary *)nodeDictionary;
- (Npc *)parseNpcFromDictionary: (NSDictionary *)npcDictionary;
- (void)updateServerGameSelected;
- (NSObject<QRCodeProtocol> *)fetchQRCode:(NSString*)QRcodeId;

@end

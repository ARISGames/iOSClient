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
#import "JSONResult.h"

extern NSDictionary *InventoryElements;

@interface AppModel : NSObject {
	NSUserDefaults *defaults;
	NSURL *serverURL;
	Game *currentGame;
	UIViewController *currentModule;
	UIAlertView *networkAlert;
	
	BOOL loggedIn;
	int playerId;
	NSString *username;
	NSString *password;
	CLLocation *playerLocation;

	NSMutableArray *gameList;
	NSMutableArray *locationList;
	NSString *locationListHash;
	NSMutableArray *playerList;
	NSMutableArray *nearbyLocationsList;
	NSMutableDictionary *inventory;
	NSString *inventoryHash; 
	NSMutableDictionary *questList;
	NSString *questListHash;
	NSMutableDictionary *gameMediaList;
	NSMutableDictionary *gameItemList;
	NSMutableDictionary *gameNodeList;
	NSMutableDictionary *gameNpcList;
	
	//Training Flags
	BOOL hasSeenNearbyTabTutorial;
	BOOL hasSeenQuestsTabTutorial;
	BOOL hasSeenMapTabTutorial;
	BOOL hasSeenInventoryTabTutorial;
    
    //Fetcher Flags
    BOOL currentlyFetchingLocationList;
    BOOL currentlyFetchingInventory;
    BOOL currentlyFetchingQuestList;
    BOOL currentlyUpdatingServerWithPlayerLocation;
    BOOL currentlyUpdatingServerWithMapViewed;
    BOOL currentlyUpdatingServerWithQuestsViewed;
    BOOL currentlyUpdatingServerWithInventoryViewed;


}

@property(nonatomic, retain) NSURL *serverURL;

@property(readwrite) BOOL loggedIn;
@property(copy, readwrite) NSString *username;
@property(copy, readwrite) NSString *password;
@property(readwrite) int playerId;
@property(copy, readwrite) UIViewController *currentModule;
@property(nonatomic,retain) Game *currentGame;

@property(copy, readwrite) NSMutableArray *gameList;	
@property(nonatomic, retain) NSMutableArray *locationList;
@property(nonatomic, retain) NSString *locationListHash;
@property(copy, readwrite) NSMutableArray *playerList;
@property(copy, readwrite) NSMutableDictionary *questList;
@property(nonatomic, retain) NSString *questListHash;
@property(copy, readwrite) NSMutableArray *nearbyLocationsList;	
@property(nonatomic, retain) CLLocation *playerLocation;	
@property(nonatomic, retain) NSMutableDictionary *inventory;
@property(nonatomic, retain) NSString *inventoryHash;
@property(retain) UIAlertView *networkAlert;

@property(copy, readwrite) NSMutableDictionary *gameMediaList;
@property(copy, readwrite) NSMutableDictionary *gameItemList;
@property(copy, readwrite) NSMutableDictionary *gameNodeList;
@property(copy, readwrite) NSMutableDictionary *gameNpcList;

//Training Flags
@property(readwrite) BOOL hasSeenNearbyTabTutorial;
@property(readwrite) BOOL hasSeenQuestsTabTutorial;
@property(readwrite) BOOL hasSeenMapTabTutorial;
@property(readwrite) BOOL hasSeenInventoryTabTutorial;

//Fetcher Flags
@property(readwrite) BOOL currentlyFetchingLocationList;
@property(readwrite) BOOL currentlyFetchingInventory;
@property(readwrite) BOOL currentlyFetchingQuestList;
@property(readwrite) BOOL currentlyUpdatingServerWithPlayerLocation;
@property(readwrite) BOOL currentlyUpdatingServerWithMapViewed;
@property(readwrite) BOOL currentlyUpdatingServerWithQuestsViewed;
@property(readwrite) BOOL currentlyUpdatingServerWithInventoryViewed;

- (id)init;
- (void)setPlayerLocation:(CLLocation *) newLocation;	


- (void)loadUserDefaults;
- (void)clearUserDefaults;
- (void)saveUserDefaults;
- (void)initUserDefaults;

- (void)login;

- (id) fetchFromService:(NSString *)aService usingMethod:(NSString *)aMethod 
			   withArgs:(NSArray *)arguments usingParser:(SEL)aSelector;

- (void)fetchGameList;
- (void)fetchLocationList;
- (void)forceUpdateOnNextLocationListFetch;
- (void)resetAllPlayerLists;
- (void)fetchAllGameLists;
- (void)fetchAllPlayerLists;
- (void)fetchInventory;
- (void)fetchQuestList;
- (void)fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId;
- (void)fetchGameNpcListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameMediaListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameItemListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameNodeListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (Item *)fetchItem:(int)itemId;
- (Node *)fetchNode:(int)nodeId;
- (Npc *)fetchNpc:(int)npcId;
- (Media *)mediaForMediaId:(int)mId;
- (Item *)itemForItemId: (int)mId;
- (Node *)nodeForNodeId: (int)mId;
- (Npc *)npcForNpcId: (int)mId;


- (void)createItemAndGiveToPlayerFromFileData:(NSData *)fileData fileName:(NSString *)fileName 
										title:(NSString *)title description:(NSString*)description;
	
- (void)updateServerWithPlayerLocation;
- (void)updateServerNodeViewed: (int)nodeId;
- (void)updateServerItemViewed: (int)itemId;
- (void)updateServerNpcViewed: (int)npcId;
- (void)updateServerMapViewed;
- (void)updateServerQuestsViewed;
- (void)updateServerInventoryViewed;
- (void)updateServerPickupItem: (int)itemId fromLocation: (int)locationId qty: (int)qty;
- (void)updateServerDropItemHere: (int)itemId qty:(int)qty;
- (void)updateServerDestroyItem: (int)itemId qty:(int)qty;
- (void)startOverGame;
- (void)silenceNextServerUpdate;

- (void)modifyQuantity: (int)quantityModifier forLocationId: (int)locationId;
- (void)removeItemFromInventory: (Item*)item qtyToRemove:(int)qty;

- (void)registerNewUser:(NSString*)userName password:(NSString*)pass 
			  firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email;
- (void)parseGameListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameMediaListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameNpcListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameItemListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameNodeListFromJSON: (JSONResult *)jsonResult;
- (Item *)parseItemFromDictionary: (NSDictionary *)itemDictionary;
- (Node *)parseNodeFromDictionary: (NSDictionary *)nodeDictionary;
- (Npc *)parseNpcFromDictionary: (NSDictionary *)npcDictionary;
- (void)updateServerGameSelected;
- (void)fetchQRCode:(NSString*)QRcodeId;

@end

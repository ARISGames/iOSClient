//
//  AppModel.h
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "SynthesizeSingleton.h"
#import "Game.h"
#import "Item.h"
#import "Node.h"
#import "Npc.h"
#import "Media.h"
#import "WebPage.h"

extern NSDictionary *InventoryElements;

@interface AppModel : NSObject {
	NSUserDefaults *defaults;
	NSURL *serverURL;
    BOOL showGamesInDevelopment;
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
    NSMutableDictionary *gameWebPageList;

	//Training Flags
	BOOL hasSeenNearbyTabTutorial;
	BOOL hasSeenQuestsTabTutorial;
	BOOL hasSeenMapTabTutorial;
	BOOL hasSeenInventoryTabTutorial;
    BOOL profilePic;
}


@property(nonatomic, retain) NSURL *serverURL;
@property(readwrite) BOOL loggedIn;
@property(readwrite) BOOL showGamesInDevelopment;
@property(readwrite) BOOL profilePic;



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
@property(copy, readwrite) NSMutableDictionary *gameWebPageList;


//Training Flags
@property(readwrite) BOOL hasSeenNearbyTabTutorial;
@property(readwrite) BOOL hasSeenQuestsTabTutorial;
@property(readwrite) BOOL hasSeenMapTabTutorial;
@property(readwrite) BOOL hasSeenInventoryTabTutorial;


+ (AppModel *)sharedAppModel;

- (id)init;
- (void)setPlayerLocation:(CLLocation *) newLocation;	
- (void)loadUserDefaults;
- (void)clearUserDefaults;
- (void)saveUserDefaults;
- (void)initUserDefaults;

- (void)modifyQuantity: (int)quantityModifier forLocationId: (int)locationId;
- (void)removeItemFromInventory: (Item*)item qtyToRemove:(int)qty;

- (Media *)mediaForMediaId:(int)mId;
- (Item *)itemForItemId: (int)mId;
- (Node *)nodeForNodeId: (int)mId;
- (Npc *)npcForNpcId: (int)mId;
- (WebPage *)webPageForWebPageID: (int)mId;

@end

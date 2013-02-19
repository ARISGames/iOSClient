//
//  AppModel.h
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreData/CoreData.h>
#import "Game.h"
#import "Location.h"
#import "Item.h"
#import "Node.h"
#import "Npc.h"
#import "Media.h"
#import "WebPage.h"
#import "Panoramic.h"
#import "Note.h"
#import "MediaCache.h"
#import "UploadMan.h"
#import "Overlay.h"

@interface AppModel : NSObject <UIAccelerometerDelegate>
{
	NSUserDefaults *defaults;
	NSURL *serverURL;
    BOOL showGamesInDevelopment;
    BOOL showPlayerOnMap;
    BOOL museumMode;
    BOOL skipGameDetails;
    BOOL inGame;
	Game *currentGame;
	UIAlertView *networkAlert;

    CMMotionManager *motionManager;

	BOOL loggedIn;
	int playerId;
	int fallbackGameId;
    int playerMediaId;
    int groupGame;
	NSString *groupName;
	NSString *userName;
	NSString *displayName;
	NSString *password;
	CLLocation *playerLocation;
    
    NSMutableArray *oneGameGameList;
	NSMutableArray *nearbyGameList;
    NSMutableArray *searchGameList;
    NSMutableArray *popularGameList;
    NSMutableArray *recentGamelist;
	NSMutableArray *locationList;
	NSMutableArray *playerList;
	NSMutableArray *nearbyLocationsList;

    NSString *playerNoteListHash;
    NSString *gameNoteListHash;
    NSString *overlayListHash;

	NSMutableDictionary *gameMediaList;
	NSMutableDictionary *gameItemList;
	NSMutableDictionary *gameNodeList;
	NSMutableDictionary *gameNpcList;
    NSMutableDictionary *gameWebPageList;
    NSMutableDictionary *gamePanoramicList;
    NSMutableDictionary *gameNoteList;
    NSMutableDictionary *playerNoteList;
    NSMutableArray *gameTagList;
    NSMutableArray *overlayList;

    NSArray *gameTabList;
    NSArray *defaultGameTabList;

    UIProgressView *progressBar;

    BOOL overlayIsVisible;

    //Accelerometer Data
    float averageAccelerometerReadingX;
    float averageAccelerometerReadingY;
    float averageAccelerometerReadingZ;
    
	//Training Flags
	BOOL hasSeenNearbyTabTutorial;
	BOOL hasSeenQuestsTabTutorial;
	BOOL hasSeenMapTabTutorial;
	BOOL hasSeenInventoryTabTutorial;
    BOOL profilePic,tabsReady,hidePlayers,isGameNoteList;
    BOOL hasReceivedMediaList;
    
    BOOL currentlyInteractingWithObject;

    //CORE Data
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    UploadMan *uploadManager;
    MediaCache *mediaCache;
}

@property(nonatomic, strong) NSURL *serverURL;
@property(readwrite) BOOL loggedIn;
@property(readwrite) BOOL showGamesInDevelopment;
@property(readwrite) BOOL showPlayerOnMap;
@property(readwrite) BOOL museumMode;
@property(readwrite) BOOL skipGameDetails;
@property(readwrite) BOOL inGame;

@property(nonatomic, retain) CMMotionManager *motionManager;

@property(readwrite) BOOL profilePic;

@property(readwrite) BOOL hidePlayers;
@property(readwrite) BOOL isGameNoteList;

@property(readwrite) BOOL hasReceivedMediaList;

@property(readwrite) BOOL overlayIsVisible;

@property(readwrite) float averageAccelerometerReadingX;
@property(readwrite) float averageAccelerometerReadingY;
@property(readwrite) float averageAccelerometerReadingZ;

@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *groupName;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) NSString *password;
@property(readwrite) int groupGame;
@property(readwrite) int playerId;
@property(readwrite) int fallbackGameId;//Used only to recover from crashes
@property(readwrite) int playerMediaId;

@property(nonatomic, strong) Game *currentGame;

@property(nonatomic, strong) NSURL *fileToDeleteURL;
@property(nonatomic, strong) NSMutableArray *oneGameGameList;
@property(nonatomic, strong) NSMutableArray *nearbyGameList;
@property(nonatomic, strong) NSMutableArray *searchGameList;
@property(nonatomic, strong) NSMutableArray *popularGameList;
@property(nonatomic, strong) NSMutableArray *recentGameList;	
@property(nonatomic, strong) NSMutableArray *locationList;
@property(nonatomic, strong) NSMutableArray *playerList;

@property(nonatomic, strong) NSMutableArray *nearbyLocationsList;	
@property(nonatomic, strong) CLLocation *playerLocation;
@property(nonatomic, strong) NSString *playerNoteListHash;
@property(nonatomic, strong) NSString *gameNoteListHash;
@property(nonatomic, strong) NSString *overlayListHash;


@property(nonatomic, strong) NSMutableDictionary *gameNoteList;
@property(nonatomic, strong) NSMutableDictionary *playerNoteList;
@property(nonatomic, strong) NSMutableArray *gameTagList;
@property(nonatomic, strong) NSMutableArray *overlayList;

@property(nonatomic, strong) NSMutableDictionary *gameMediaList;
@property(nonatomic, strong) NSMutableDictionary *gameItemList;
@property(nonatomic, strong) NSMutableDictionary *gameNodeList;
@property(nonatomic, strong) NSArray *gameTabList;
@property(nonatomic, strong) NSArray *defaultGameTabList;

@property(nonatomic, strong) NSMutableDictionary *gameNpcList;
@property(nonatomic, strong) NSMutableDictionary *gameWebPageList;

@property(nonatomic, strong) NSMutableDictionary *gamePanoramicList;

@property(nonatomic, strong) UIAlertView *networkAlert;
@property(nonatomic, strong)UIProgressView *progressBar;

//Training Flags
@property(readwrite) BOOL hasSeenNearbyTabTutorial;
@property(readwrite) BOOL hasSeenQuestsTabTutorial;
@property(readwrite) BOOL hasSeenMapTabTutorial;
@property(readwrite) BOOL hasSeenInventoryTabTutorial;
@property(readwrite) BOOL tabsReady;

@property(readwrite) BOOL currentlyInteractingWithObject;

// CORE Data
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong) UploadMan *uploadManager;
@property(nonatomic, strong) MediaCache *mediaCache;

+ (AppModel *)sharedAppModel;

- (id)init;
- (void)setPlayerLocation:(CLLocation *) newLocation;	
- (void)loadUserDefaults;
- (void)clearUserDefaults;
- (void)saveUserDefaults;
- (void)saveCOREData;
- (void)initUserDefaults;
- (void)clearGameLists;
- (void)modifyQuantity: (int)quantityModifier forLocationId: (int)locationId;
- (void)removeItemFromInventory: (Item*)item qtyToRemove:(int)qty;

- (Media *)mediaForMediaId:(int)mId;
- (Item *)itemForItemId: (int)mId;
- (Node *)nodeForNodeId: (int)mId;
- (Npc *)npcForNpcId: (int)mId;
- (WebPage *)webPageForWebPageID: (int)mId;
- (Panoramic *)panoramicForPanoramicId: (int)mId;
- (Note *)noteForNoteId:(int)mId playerListYesGameListNo:(BOOL)playerorGame;
- (Location *)locationForLocationId: (int)lId;

@end

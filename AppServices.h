//
//  AppServices.h
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "AppModel.h"
#import "Game.h"
#import "Item.h"
#import "Node.h"
#import "Npc.h"
#import "Media.h"
#import "WebPage.h"
#import "Panoramic.h"
#import "JSONResult.h"
#import "JSONConnection.h"
#import "JSONResult.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "ARISAppDelegate.h"
#import "Comment.h"



@interface AppServices : NSObject {
    //Fetcher Flags
    BOOL currentlyFetchingLocationList;
    BOOL currentlyFetchingInventory;
    BOOL currentlyFetchingQuestList;
    BOOL currentlyFetchingGamesList;
    BOOL currentlyUpdatingServerWithPlayerLocation;
    BOOL currentlyUpdatingServerWithMapViewed;
    BOOL currentlyUpdatingServerWithQuestsViewed;
    BOOL currentlyUpdatingServerWithInventoryViewed;
}

//Fetcher Flags
@property(readwrite) BOOL currentlyFetchingLocationList;
@property(readwrite) BOOL currentlyFetchingInventory;
@property(readwrite) BOOL currentlyFetchingQuestList;
@property(readwrite) BOOL currentlyFetchingGamesList;
@property(readwrite) BOOL currentlyUpdatingServerWithPlayerLocation;
@property(readwrite) BOOL currentlyUpdatingServerWithMapViewed;
@property(readwrite) BOOL currentlyUpdatingServerWithQuestsViewed;
@property(readwrite) BOOL currentlyUpdatingServerWithInventoryViewed;  


+ (AppServices *)sharedAppServices;


- (void)login;
- (id) fetchFromService:(NSString *)aService usingMethod:(NSString *)aMethod 
			   withArgs:(NSArray *)arguments usingParser:(SEL)aSelector;

- (void)fetchGameListWithDistanceFilter: (int)distanceInMeters locational:(BOOL)locationalOrNonLocational;
- (void)fetchRecentGameListForPlayer;
- (void)fetchMiniGamesListLocations;
- (void)fetchOneGame:(int)gameId;

- (void)fetchLocationList;
- (void)forceUpdateOnNextLocationListFetch;
- (void)fetchGameListBySearch: (NSString *) searchText;
- (void)resetAllPlayerLists;
- (void)fetchAllGameLists;
- (void)resetAllGameLists;
- (void)fetchAllPlayerLists;
- (void)fetchInventory;
- (void)fetchQuestList;
- (void)fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId;
- (void)fetchGameNpcListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameMediaListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameItemListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameNodeListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameWebpageListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGamePanoramicListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (Item *)fetchItem:(int)itemId;
- (Node *)fetchNode:(int)nodeId;
- (Npc *)fetchNpc:(int)npcId;


- (void)createItemAndGiveToPlayerFromFileData:(NSData *)fileData fileName:(NSString *)fileName 
										title:(NSString *)title description:(NSString*)description;

- (void)uploadImageForMatching:(NSData *)fileData;

- (void)updateServerWithPlayerLocation;
- (void)updateServerNodeViewed: (int)nodeId;
- (void)updateServerItemViewed: (int)itemId;
- (void)updateServerWebPageViewed: (int)webPageId;
- (void)updateServerPanoramicViewed: (int)panoramicId;
- (void)updateServerNpcViewed: (int)npcId;
- (void)updateServerMapViewed;
- (void)updateServerQuestsViewed;
- (void)updateServerInventoryViewed;
- (void)updateServerPickupItem: (int)itemId fromLocation: (int)locationId qty: (int)qty;
- (void)updateServerDropItemHere: (int)itemId qty:(int)qty;
- (void)updateServerDestroyItem: (int)itemId qty:(int)qty;
- (void)startOverGame;
- (void)silenceNextServerUpdate;

- (void)registerNewUser:(NSString*)userName password:(NSString*)pass 
			  firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email;
- (void)parseGameListFromJSON: (JSONResult *)jsonResult;
- (Game *)parseGame:(NSDictionary *)gameSource;
- (void)parseGameMediaListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameNpcListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameItemListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameNodeListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameWebPageListFromJSON: (JSONResult *)jsonResult;
- (Location*)parseLocationFromDictionary: (NSDictionary *)locationDictionary;
- (Item *)parseItemFromDictionary: (NSDictionary *)itemDictionary;
- (Node *)parseNodeFromDictionary: (NSDictionary *)nodeDictionary;
- (Npc *)parseNpcFromDictionary: (NSDictionary *)npcDictionary;
-(WebPage *)parseWebPageFromDictionary: (NSDictionary *)webPageDictionary;
-(Panoramic *)parsePanoramicFromDictionary: (NSDictionary *)webPageDictionary;
- (void)updateServerGameSelected;
- (void)fetchQRCode:(NSString*)QRcodeId;
- (void)saveComment:(NSString*)comment game:(int)gameId starRating:(int)rating;
- (void)parseSaveCommentResponseFromJSON: (JSONResult *)jsonResult;

@end

//
//  AppServices.h
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppModel.h"
#import "Game.h"
#import "Tab.h"
#import "Item.h"
#import "Node.h"
#import "Npc.h"
#import "Media.h"
#import "WebPage.h"
#import "Panoramic.h"
#import "PanoramicMedia.h"
#import "JSONResult.h"
#import "JSONConnection.h"
#import "JSONResult.h"
#import "JSON.h"
#import "ARISAppDelegate.h"
#import "Comment.h"
#import "Note.h"
#import "NoteContent.h"
#import <MapKit/MapKit.h>
#import "Tag.h"
#import "ARISUploader.h"


@interface AppServices : NSObject {
    //Fetcher Flags
    BOOL currentlyFetchingLocationList,currentlyFetchingGameNoteList,currentlyFetchingPlayerNoteList;
    BOOL currentlyFetchingInventory;
    BOOL currentlyFetchingQuestList;
    BOOL currentlyFetchingGamesList;
    BOOL currentlyUpdatingServerWithPlayerLocation;
    BOOL currentlyUpdatingServerWithMapViewed;
    BOOL currentlyUpdatingServerWithQuestsViewed;
    BOOL currentlyUpdatingServerWithInventoryViewed;
}

extern NSString *const kARISServerServicePackage;

//Fetcher Flags
@property(readwrite) BOOL currentlyFetchingLocationList;
@property(readwrite) BOOL currentlyFetchingInventory;
@property(readwrite) BOOL currentlyFetchingGameNoteList;
@property(readwrite) BOOL currentlyFetchingPlayerNoteList;
@property(readwrite) BOOL currentlyFetchingQuestList;
@property(readwrite) BOOL currentlyFetchingGamesList;
@property(readwrite) BOOL currentlyUpdatingServerWithPlayerLocation;
@property(readwrite) BOOL currentlyUpdatingServerWithMapViewed;
@property(readwrite) BOOL currentlyUpdatingServerWithQuestsViewed;
@property(readwrite) BOOL currentlyUpdatingServerWithInventoryViewed;  


+ (AppServices *)sharedAppServices;


- (void)login;
-(void)setShowPlayerOnMap;
- (id) fetchFromService:(NSString *)aService usingMethod:(NSString *)aMethod 
			   withArgs:(NSArray *)arguments usingParser:(SEL)aSelector;

- (void)fetchGameListWithDistanceFilter: (int)distanceInMeters locational:(BOOL)locationalOrNonLocational;
- (void)fetchRecentGameListForPlayer;
- (void)fetchPopularGameListForTime: (int)time;
- (void)fetchMiniGamesListLocations;
- (void)fetchOneGame:(int)gameId;

- (void)fetchTabBarItemsForGame:(int)gameId;
- (void)fetchLocationList;
- (void)fetchGameListBySearch: (NSString *) searchText onPage:(int)page;
- (void)resetAllPlayerLists;
- (void)fetchAllGameLists;
- (void)resetAllGameLists;
- (void)fetchAllPlayerLists;
- (void)fetchInventory;
- (void)fetchQuestList;
- (void)fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId;
- (void)fetchGameNpcListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameMediaListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchOverlayListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameItemListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameNodeListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameWebpageListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGamePanoramicListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameNoteListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchPlayerNoteListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameTags;
- (Item *)fetchItem:(int)itemId;
- (Node *)fetchNode:(int)nodeId;
- (Npc *)fetchNpc:(int)npcId;
- (Note *)fetchNote:(int)noteId;
- (void)createItemAndPlaceOnMap:(Item *)item;
- (void)commitInventoryTrade:(int)gameId fromMe:(int)playerOneId toYou:(int)playerTwoId giving:(NSArray *)gifts receiving:(NSArray *)receipts;
- (void)updateItem:(Item *) item;
- (void)createItemAndGivetoPlayer: (Item *) item;
- (void)uploadImageForMatching:(NSURL *)fileURL;

- (void) uploadContentToNoteWithFileURL:(NSURL *)fileURL name:(NSString *)name noteId:(int) noteId type: (NSString *)type;
- (void) addContentToNoteWithText:(NSString *)text type:(NSString *) type mediaId:(int) mediaId andNoteId:(int)noteId andFileURL:(NSURL *)fileURL;
- (int)createNote;
- (void)updateServerDropNoteHere: (int)noteId atCoordinate:(CLLocationCoordinate2D) coordinate;
- (void)deleteNoteContentWithContentId:(int) contentId;
- (void)deleteNoteWithNoteId: (int) noteId;
- (void)deleteNoteLocationWithNoteId: (int) noteId;
- (void)updateNoteContent:(int)contentId text:(NSString *)text;
- (void)updateNoteContent:(int)contentId title:(NSString *)text;
- (void)resetAndEmailNewPassword:(NSString *)email;
- (void)addTagToNote:(int)noteId tagName:(NSString *)tag;
- (void)deleteTagFromNote:(int)noteId tagId:(int)tagId;
- (int) addCommentToNoteWithId: (int)noteId andTitle:(NSString *)title;
- (void)updateCommentWithId: (int)noteId andTitle:(NSString *)title andRefresh:(BOOL)refresh;
- (void)likeNote:(int)noteId;
- (void)unLikeNote:(int)noteId;
- (void)updateServerWithPlayerLocation;
- (void)updateServerNodeViewed: (int)nodeId fromLocation:(int)locationId;
- (void)updateServerItemViewed: (int)itemId fromLocation:(int)locationId;
- (void)updateServerWebPageViewed: (int)webPageId fromLocation:(int)locationId;
- (void)updateServerPanoramicViewed: (int)panoramicId fromLocation:(int)locationId;
- (void)updateServerNpcViewed: (int)npcId fromLocation:(int)locationId;
- (void)updateServerMapViewed;
- (void)updateServerQuestsViewed;
- (void)updateServerInventoryViewed;
- (void)updateServerPickupItem: (int)itemId fromLocation: (int)locationId qty: (int)qty;
- (void)updateServerDropItemHere: (int)itemId qty:(int)qty;
- (void)updateServerDestroyItem: (int)itemId qty:(int)qty;
- (void)updateNoteWithNoteId:(int)noteId title:(NSString *) title publicToMap:(BOOL)publicToMap publicToList:(BOOL)publicToList;
- (void)startOverGame:(int)gameId;
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
- (void)parseGamePanoramicListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameTabListFromJSON:(JSONResult *)jsonResult;
- (void)parseGameNoteListFromJSON: (JSONResult *)jsonResult;
- (void)parsePlayerNoteListFromJSON: (JSONResult *)jsonResult;

- (void)parseRecentGameListFromJSON: (JSONResult *)jsonResult;
- (void)parseGameTagsListFromJSON: (JSONResult *)jsonResult;

- (Location*)parseLocationFromDictionary: (NSDictionary *)locationDictionary;
- (Item *)parseItemFromDictionary: (NSDictionary *)itemDictionary;
- (Node *)parseNodeFromDictionary: (NSDictionary *)nodeDictionary;
- (Npc *)parseNpcFromDictionary: (NSDictionary *)npcDictionary;
- (WebPage *)parseWebPageFromDictionary: (NSDictionary *)webPageDictionary;
- (Panoramic *)parsePanoramicFromDictionary: (NSDictionary *)webPageDictionary;
- (Tab *)parseTabFromDictionary:(NSDictionary *)tabDictionary;
- (Note *)parseNoteFromDictionary: (NSDictionary *)noteDictionary;

- (void)updateServerGameSelected;
- (void)fetchQRCode:(NSString*)QRcodeId;
- (void)saveComment:(NSString*)comment game:(int)gameId starRating:(int)rating;
- (void)parseSaveCommentResponseFromJSON: (JSONResult *)jsonResult;
- (void)sendNotificationToNoteViewer;
- (void)sendNotificationToNotebookViewer;
-(void)fetchPlayerNoteListAsync;

@end

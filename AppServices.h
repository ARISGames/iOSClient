//
//  AppServices.h
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"
#import "AppModel.h"
#import "MyCLController.h"
#import "Location.h"
#import "Game.h"
#import "Tab.h"
#import "Item.h"
#import "Node.h"
#import "Npc.h"
#import "Media.h"
#import "WebPage.h"
#import "Panoramic.h"
#import "Quest.h"
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


@interface AppServices : NSObject

extern NSString *const kARISServerServicePackage;

+ (AppServices *)sharedAppServices;

- (void)resetCurrentlyFetchingVars;

//Player
- (void)login;
- (void)registerNewUser:(NSString*)userName
               password:(NSString*)pass
			  firstName:(NSString*)firstName
               lastName:(NSString*)lastName
                  email:(NSString*)email;
- (void)createUserAndLoginWithGroup:(NSString *)groupName;
- (void)uploadPlayerPicMediaWithFileURL:(NSURL *)fileURL;
- (void)updatePlayer:(int)playerId withName:(NSString *)name andImage:(int)mid;
- (void)resetAndEmailNewPassword:(NSString *)email;
- (void)setShowPlayerOnMap;

//Game Picker
- (void)fetchGameListWithDistanceFilter:(int)distanceInMeters locational:(BOOL)locationalOrNonLocational;
- (void)fetchRecentGameListForPlayer;
- (void)fetchPopularGameListForTime: (int)time;
- (void)fetchGameListBySearch:(NSString *)searchText onPage:(int)page;

- (void)fetchOneGameGameList:(int)gameId;

- (void)fetchTabBarItemsForGame:(int)gameId; //This should probably just be part of "fetchGame".

//Fetch Player State
- (void)resetAllPlayerLists;
- (void)fetchAllPlayerLists;
- (void)fetchPlayerLocationList;
- (void)fetchPlayerQuestList;
- (void)fetchPlayerInventory;
- (void)fetchPlayerOverlayList;
- (void)fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId;

//Fetch Game Data (ONLY CALLED ONCE PER GAME!!)
- (void)resetAllGameLists;
- (void)fetchAllGameLists;
- (void)fetchGameOverlayListAsynchronously:  (BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameNpcListAsynchronously:      (BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameMediaListAsynchronously:    (BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameItemListAsynchronously:     (BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameNodeListAsynchronously:     (BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameWebpageListAsynchronously:  (BOOL)YesForAsyncOrNoForSync;
- (void)fetchGamePanoramicListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void)fetchGameNoteTagsAsynchronously:     (BOOL)YesForAsyncOrNoForSync;

- (void)fetchGameNoteListAsynchronously:     (BOOL)YesForAsyncOrNoForSync;
- (void)fetchPlayerNoteListAsynchronously:   (BOOL)YesForAsyncOrNoForSync;

//Get Specific Data (technically, these being called is a sign that the "fetch game data" functions failed somewhere...)
- (void)fetchMedia:(int)mediaId;
- (Item *)fetchItem:(int)itemId;
- (Node *)fetchNode:(int)nodeId;
- (Npc *)fetchNpc:(int)npcId;
- (Note *)fetchNote:(int)noteId;

- (void)commitInventoryTrade:(int)gameId fromMe:(int)playerOneId toYou:(int)playerTwoId giving:(NSString *)giftsJSON receiving:(NSString *)receiptsJSON;
- (void)uploadImageForMatching:(NSURL *)fileURL;

//Note Stuff
- (int)createNote;
- (int)createNoteStartIncomplete;
- (void)setNoteCompleteForNoteId:(int)noteId;
- (void)updateNoteWithNoteId:(int)noteId title:(NSString *)title publicToMap:(BOOL)publicToMap publicToList:(BOOL)publicToList;
- (void)deleteNoteWithNoteId:(int)noteId;
- (void)dropNote:(int)noteId atCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)addContentToNoteWithText:(NSString *)text type:(NSString *)type mediaId:(int)mediaId andNoteId:(int)noteId andFileURL:(NSURL *)fileURL;
- (void)uploadContentToNoteWithFileURL:(NSURL *)fileURL name:(NSString *)name noteId:(int)noteId type:(NSString *)type;
- (void)deleteNoteContentWithContentId:(int)contentId;
- (void)deleteNoteLocationWithNoteId:(int)noteId;
- (void)updateNoteContent:(int)contentId text:(NSString *)text;
- (void)updateNoteContent:(int)contentId title:(NSString *)title;
- (void)addTagToNote:(int)noteId tagName:(NSString *)tag;
- (void)deleteTagFromNote:(int)noteId tagId:(int)tagId;
- (int)addCommentToNoteWithId:(int)noteId andTitle:(NSString *)title;
- (void)updateCommentWithId:(int)noteId andTitle:(NSString *)title andRefresh:(BOOL)refresh;
- (void)likeNote:(int)noteId;
- (void)unLikeNote:(int)noteId;

//Tell server of state
- (void)updateServerWithPlayerLocation;
- (void)updateServerNodeViewed:(int)nodeId fromLocation:(int)locationId;
- (void)updateServerItemViewed:(int)itemId fromLocation:(int)locationId;
- (void)updateServerWebPageViewed:(int)webPageId fromLocation:(int)locationId;
- (void)updateServerPanoramicViewed:(int)panoramicId fromLocation:(int)locationId;
- (void)updateServerNpcViewed:(int)npcId fromLocation:(int)locationId;
- (void)updateServerMapViewed;
- (void)updateServerQuestsViewed;
- (void)updateServerInventoryViewed;
- (void)updateServerPickupItem:(int)itemId fromLocation:(int)locationId qty:(int)qty;
- (void)updateServerDropItemHere:(int)itemId qty:(int)qty;
- (void)updateServerDestroyItem:(int)itemId qty:(int)qty;
- (void)updateServerInventoryItem:(int)itemId qty:(int)qty;
- (void)updateServerAddInventoryItem:(int)itemId addQty:(int)qty;
- (void)updateServerRemoveInventoryItem:(int)itemId removeQty:(int)qty;

//Parse server responses
- (NSMutableArray *)parseGameListFromJSON:(JSONResult *)jsonResult;
- (void)parseGameMediaListFromJSON:       (JSONResult *)jsonResult;
- (void)parseGameNpcListFromJSON:         (JSONResult *)jsonResult;
- (void)parseGameItemListFromJSON:        (JSONResult *)jsonResult;
- (void)parseGameNodeListFromJSON:        (JSONResult *)jsonResult;
- (void)parseGameWebPageListFromJSON:     (JSONResult *)jsonResult;
- (void)parseGamePanoramicListFromJSON:   (JSONResult *)jsonResult;
- (void)parseGameTabListFromJSON:         (JSONResult *)jsonResult;
- (void)parseGameNoteListFromJSON:        (JSONResult *)jsonResult;
- (void)parsePlayerNoteListFromJSON:      (JSONResult *)jsonResult;
- (void)parseRecentGameListFromJSON:      (JSONResult *)jsonResult;
- (void)parseGameTagsListFromJSON:        (JSONResult *)jsonResult;
- (void)parseGameCommentResponseFromJSON: (JSONResult *)jsonResult;

//Parse individual pieces of server response
- (Game *)     parseGameFromDictionary:     (NSDictionary *)gameSource;
- (Location *) parseLocationFromDictionary: (NSDictionary *)locationDictionary;
- (Item *)     parseItemFromDictionary:     (NSDictionary *)itemDictionary;
- (Node *)     parseNodeFromDictionary:     (NSDictionary *)nodeDictionary;
- (Npc *)      parseNpcFromDictionary:      (NSDictionary *)npcDictionary;
- (WebPage *)  parseWebPageFromDictionary:  (NSDictionary *)webPageDictionary;
- (Panoramic *)parsePanoramicFromDictionary:(NSDictionary *)webPageDictionary;
- (Tab *)      parseTabFromDictionary:      (NSDictionary *)tabDictionary;
- (Note *)     parseNoteFromDictionary:     (NSDictionary *)noteDictionary;

- (void)updateServerGameSelected;
- (void)fetchQRCode:(NSString*)QRcodeId;
- (void)saveGameComment:(NSString*)comment game:(int)gameId starRating:(int)rating;
- (void)sendNotificationToNoteViewer;
- (void)sendNotificationToNotebookViewer;
- (void)fetchPlayerNoteListAsync;
- (void)startOverGame:(int)gameId;

@end

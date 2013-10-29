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
#import "JSONConnection.h"
#import "ARISAppDelegate.h"
#import "Comment.h"
#import "Note.h"
#import "NoteContent.h"
#import "Tag.h"
#import "ARISUploader.h"

@interface AppServices : NSObject

+ (AppServices *)sharedAppServices;

- (void) resetCurrentlyFetchingVars;

//Player
- (void) loginUserName:(NSString *)username password:(NSString *)password userInfo:(NSMutableDictionary *)dict;
- (void) registerNewUser:(NSString*)userName password:(NSString*)pass firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email;
- (void) createUserAndLoginWithGroup:(NSString *)groupName;
- (void) uploadPlayerPicMediaWithFileURL:(NSURL *)fileURL;
- (void) updatePlayer:(int)playerId withName:(NSString *)name andImage:(int)mid;
- (void) resetAndEmailNewPassword:(NSString *)email;
- (void) setShowPlayerOnMap;

//Game Picker
- (void) fetchNearbyGameListWithDistanceFilter:(int)distanceInMeters;
- (void) fetchAnywhereGameList;
- (void) fetchRecentGameListForPlayer;
- (void) fetchPopularGameListForTime:(int)time;
- (void) fetchGameListBySearch:(NSString *)searchText onPage:(int)page;

- (void) fetchOneGameGameList:(int)gameId;

//Fetch Player State
- (void) resetAllPlayerLists;
- (void) fetchAllPlayerLists;
- (void) fetchPlayerLocationList;
- (void) fetchPlayerQuestList;
- (void) fetchPlayerInventory;
- (void) fetchPlayerOverlayList;
- (void) fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId;

//Fetch Game Data (ONLY CALLED ONCE PER GAME!!)
- (void) resetAllGameLists;
- (void) fetchAllGameLists;
- (void) fetchGameMediaListAsynchronously:    (BOOL)YesForAsyncOrNoForSync;
- (void) fetchTabBarItemsAsynchronously:      (BOOL)YesForAsyncOrNoForSync;
- (void) fetchGameOverlayListAsynchronously:  (BOOL)YesForAsyncOrNoForSync;
- (void) fetchGameNpcListAsynchronously:      (BOOL)YesForAsyncOrNoForSync;
- (void) fetchGameItemListAsynchronously:     (BOOL)YesForAsyncOrNoForSync;
- (void) fetchGameNodeListAsynchronously:     (BOOL)YesForAsyncOrNoForSync;
- (void) fetchGameWebPageListAsynchronously:  (BOOL)YesForAsyncOrNoForSync;
- (void) fetchGamePanoramicListAsynchronously:(BOOL)YesForAsyncOrNoForSync;
- (void) fetchGameNoteTagsAsynchronously:     (BOOL)YesForAsyncOrNoForSync;

- (void) fetchGameNoteListAsynchronously:      (BOOL)YesForAsyncOrNoForSync;
- (void) fetchPlayerNoteListAsynchronously:    (BOOL)YesForAsyncOrNoForSync;

//Should only be called in the case of a media appearing in the game that didn't exist when the game was initially launched (eg- someone took a picture)
- (void) fetchMedia:(int)mediaId;

- (void) commitInventoryTrade:(int)gameId fromMe:(int)playerOneId toYou:(int)playerTwoId giving:(NSString *)giftsJSON receiving:(NSString *)receiptsJSON;

//Note Stuff
- (int) createNote;
- (int) createNoteStartIncomplete;
- (void) setNoteCompleteForNoteId:(int)noteId;
- (void) updateNoteWithNoteId:(int)noteId title:(NSString *)title publicToMap:(BOOL)publicToMap publicToList:(BOOL)publicToList;
- (void) deleteNoteWithNoteId:(int)noteId;
- (void) dropNote:(int)noteId atCoordinate:(CLLocationCoordinate2D)coordinate;
- (void) addContentToNoteWithText:(NSString *)text type:(NSString *)type mediaId:(int)mediaId andNoteId:(int)noteId andFileURL:(NSURL *)fileURL;
- (void) uploadContentToNoteWithFileURL:(NSURL *)fileURL name:(NSString *)name noteId:(int)noteId type:(NSString *)type;
- (void) deleteNoteContentWithContentId:(int)contentId;
- (void) deleteNoteLocationWithNoteId:(int)noteId;
- (void) updateNoteContent:(int)contentId text:(NSString *)text;
- (void) updateNoteContent:(int)contentId title:(NSString *)title;
- (void) addTagToNote:(int)noteId tagName:(NSString *)tag;
- (void) deleteTagFromNote:(int)noteId tagId:(int)tagId;
- (int) addCommentToNoteWithId:(int)noteId andTitle:(NSString *)title;
- (void) updateCommentWithId:(int)noteId andTitle:(NSString *)title andRefresh:(BOOL)refresh;
- (void) likeNote:(int)noteId;
- (void) unLikeNote:(int)noteId;

//Tell server of state
- (void) updateServerWithPlayerLocation;
- (void) updateServerLocationViewed:(int)locationId;
- (void) updateServerNodeViewed:(int)nodeId fromLocation:(int)locationId;
- (void) updateServerItemViewed:(int)itemId fromLocation:(int)locationId;
- (void) updateServerWebPageViewed:(int)webPageId fromLocation:(int)locationId;
- (void) updateServerPanoramicViewed:(int)panoramicId fromLocation:(int)locationId;
- (void) updateServerNpcViewed:(int)npcId fromLocation:(int)locationId;
- (void) updateServerMapViewed;
- (void) updateServerQuestsViewed;
- (void) updateServerInventoryViewed;
- (void) updateServerPickupItem:(int)itemId fromLocation:(int)locationId qty:(int)qty;
- (void) updateServerDropItemHere:(int)itemId qty:(int)qty;
- (void) updateServerDestroyItem:(int)itemId qty:(int)qty;
- (void) updateServerInventoryItem:(int)itemId qty:(int)qty;
- (void) updateServerAddInventoryItem:(int)itemId addQty:(int)qty;
- (void) updateServerRemoveInventoryItem:(int)itemId removeQty:(int)qty;

//Parse server responses
- (NSMutableArray *) parseGameListFromJSON:(ServiceResult *)result;
- (void) parseGameMediaListFromJSON:       (ServiceResult *)result;
- (void) parseGameNpcListFromJSON:         (ServiceResult *)result;
- (void) parseGameItemListFromJSON:        (ServiceResult *)result;
- (void) parseGameNodeListFromJSON:        (ServiceResult *)result;
- (void) parseGameWebPageListFromJSON:     (ServiceResult *)result;
- (void) parseGamePanoramicListFromJSON:   (ServiceResult *)result;
- (void) parseGameTabListFromJSON:         (ServiceResult *)result;
- (void) parseGameNoteListFromJSON:        (ServiceResult *)result;
- (void) parsePlayerNoteListFromJSON:      (ServiceResult *)result;
- (void) parseRecentGameListFromJSON:      (ServiceResult *)result;
- (void) parseGameTagsListFromJSON:        (ServiceResult *)result;

//Parse individual pieces of server response
- (Tab *) parseTabFromDictionary:(NSDictionary *)tabDictionary;

- (void) updateServerGameSelected;
- (void) fetchQRCode:(NSString*)QRcodeId;
- (void) saveGameComment:(NSString*)comment game:(int)gameId starRating:(int)rating;
- (void) sendNotificationToNoteViewer;
- (void) sendNotificationToNotebookViewer;
- (void) fetchPlayerNoteListAsync;
- (void) startOverGame:(int)gameId;

@end


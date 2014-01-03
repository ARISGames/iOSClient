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
#import "ARISAppDelegate.h"
#import "Comment.h"
#import "Note.h"
#import "Tag.h"
#import "ARISConnection.h"
#import "ARISMediaLoader.h"

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
- (void) fetchAllPlayerLists;
- (void) fetchPlayerLocationList;
- (void) fetchPlayerQuestList;
- (void) fetchPlayerInventory;
- (void) fetchPlayerOverlayList;
- (void) fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId;

//Fetch Game Data (ONLY CALLED ONCE PER GAME!!)
- (void) fetchAllGameLists;
- (void) fetchGameMediaList;
- (void) fetchTabBarItems;
- (void) fetchGameOverlayList;
- (void) fetchGameNpcList;
- (void) fetchGameItemList;
- (void) fetchGameNodeList;
- (void) fetchGameWebPageList;
- (void) fetchGamePanoramicList;
- (void) fetchGameNoteTags;

- (void) fetchNoteListPage:(int)page;
- (void) fetchNoteWithId:(int)noteId;

//Should only be called in the case of a media appearing in the game that didn't exist when the game was initially launched (eg- someone took a picture)
- (void) fetchMediaMeta:(Media *)m;
- (void) loadMedia:(Media *)m delegate:(id<ARISMediaLoaderDelegate>)d;

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
- (void) addTagToNote:(int)noteId tagName:(NSString *)tag;
- (void) deleteTagFromNote:(int)noteId tagId:(int)tagId;
- (int) addCommentToNoteWithId:(int)noteId andTitle:(NSString *)title;
- (void) updateCommentWithId:(int)noteId andTitle:(NSString *)title andRefresh:(BOOL)refresh;
- (void) likeNote:(int)noteId;
- (void) unLikeNote:(int)noteId;
- (void) uploadNote:(Note *)n;

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

//Parse individual pieces of server response
- (Tab *) parseTabFromDictionary:(NSDictionary *)tabDictionary;

- (void) updateServerGameSelected;
- (void) fetchQRCode:(NSString*)QRcodeId;
- (void) saveGameComment:(NSString*)comment game:(int)gameId starRating:(int)rating;
- (void) startOverGame:(int)gameId;

@end


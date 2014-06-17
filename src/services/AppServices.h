//
//  AppServices.h
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARISMediaLoader.h"

#define _SERVICES_ [AppServices sharedAppServices]
#define _SERVICES_MEDIA_ [AppServices sharedAppServices].mediaLoader

@interface AppServices : NSObject
{
    ARISMediaLoader *mediaLoader;  
}

@property (nonatomic, strong) ARISMediaLoader *mediaLoader;

+ (AppServices *)sharedAppServices;

- (void) retryFailedRequests;

- (void) createUserWithName:(NSString *)user_name displayName:(NSString *)display_name groupName:(NSString *)group_name email:(NSString *)email password:(NSString *)password;
- (void) logInUserWithName:(NSString *)user_name password:(NSString *)password;

- (void) fetchGame:(int)game_id;
- (void) fetchNearbyGames;
- (void) fetchAnywhereGames;
- (void) fetchRecentGames;
- (void) fetchPopularGames;
- (void) fetchSearchGames:(NSString *)s;

- (void) fetchMedia; - (void) fetchMediaId:(int)media_id;
- (void) fetchPlaques;
- (void) fetchItems;
- (void) fetchDialogs;
- (void) fetchDialogCharacters;
- (void) fetchDialogScripts;
- (void) fetchWebPages;
- (void) fetchQuests;
- (void) fetchInstances;
- (void) fetchTriggers;
- (void) fetchTabs;

- (void) fetchLogsForPlayer;
- (void) fetchInstancesForPlayer;
- (void) fetchTriggersForPlayer;
- (void) fetchQuestsForPlayer;
- (void) fetchTabsForPlayer;

- (void) logPlayerMoved;
- (void) logPlayerViewedTabId:(int)tab_id;
- (void) logPlayerViewedPlaqueId:(int)plaque_id;
- (void) logPlayerViewedItemId:(int)item_id;
- (void) logPlayerViewedDialogId:(int)dialog_id;
- (void) logPlayerViewedDialogScriptId:(int)dialog_script_id;
- (void) logPlayerViewedWebPageId:(int)web_page_id;
- (void) logPlayerViewedInstanceId:(int)instance_id;
- (void) logPlayerTriggeredTriggerId:(int)trigger_id;

//Fetch Game Data (ONLY CALLED ONCE PER GAME!!)
- (void) fetchNoteListPage:(int)page;
- (void) fetchNoteTagLists;
- (void) fetchNoteWithId:(int)noteId;

//Note Stuff
- (void) deleteNoteWithNoteId:(int)noteId;
//- (void) dropNote:(int)noteId atCoordinate:(CLLocationCoordinate2D)coordinate;

//- (void) uploadNote:(Note *)n;
//- (void) addComment:(NSString *)c fromPlayer:(User *)p toNote:(Note *)n;

//Tell server of state
- (void) updateServerWithPlayerLocation;
- (void) updateServerLocationViewed:(int)locationId;
- (void) updateServerPlaqueViewed:(int)plaque_id fromLocation:(int)locationId;
- (void) updateServerItemViewed:(int)item_id fromLocation:(int)locationId;
- (void) updateServerWebPageViewed:(int)web_page_id fromLocation:(int)locationId;
- (void) updateServerDialogViewed:(int)dialog_id fromLocation:(int)locationId;
- (void) updateServerPickupItem:(int)item_id fromLocation:(int)locationId qty:(int)qty;
- (void) updateServerDropItemHere:(int)item_id qty:(int)qty;
- (void) updateServerDestroyItem:(int)item_id qty:(int)qty;
- (void) updateServerInventoryItem:(int)item_id qty:(int)qty;
- (void) updateServerAddInventoryItem:(int)item_id addQty:(int)qty;
- (void) updateServerRemoveInventoryItem:(int)item_id removeQty:(int)qty;

- (void) updateServerGameSelected;
- (void) fetchQRCode:(NSString*)QRcodeId;
- (void) saveGameComment:(NSString*)comment titled:(NSString*)t game:(int)game_id starRating:(int)rating;
- (void) startOverGame:(int)game_id;

@end

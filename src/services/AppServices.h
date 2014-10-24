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

@class Note;
@class Tag;

@interface AppServices : NSObject
{
    ARISMediaLoader *mediaLoader;  
}

@property (nonatomic, strong) ARISMediaLoader *mediaLoader;

+ (AppServices *)sharedAppServices;
- (void) setServer:(NSString *)s;

- (void) retryFailedRequests;

- (void) createUserWithName:(NSString *)user_name displayName:(NSString *)display_name groupName:(NSString *)group_name email:(NSString *)email password:(NSString *)password;
- (void) logInUserWithName:(NSString *)user_name password:(NSString *)password;

- (void) fetchGame:(int)game_id;
- (void) fetchNearbyGames;
- (void) fetchAnywhereGames;
- (void) fetchRecentGames;
- (void) fetchPopularGames;
- (void) fetchSearchGames:(NSString *)s;
- (void) fetchMineGames;
- (void) fetchPlayerPlayedGame:(int)game_id;

- (void) fetchScenes;
- (void) touchSceneForPlayer;
- (void) fetchMedias;
- (void) fetchPlaques;
- (void) fetchItems;
- (void) touchItemsForPlayer; //an odd request- but IS a game-level fetch (calls GAME_PIECE_RECEIVED)
- (void) fetchDialogs;
- (void) fetchDialogCharacters;
- (void) fetchDialogScripts;
- (void) fetchDialogOptions;
- (void) fetchWebPages;
- (void) fetchNotes;
- (void) fetchTags;
- (void) fetchObjectTags;
- (void) fetchEvents;
- (void) fetchQuests;
- (void) fetchInstances;
- (void) fetchTriggers;
- (void) fetchOverlays;
- (void) fetchTabs;

- (void) fetchLogsForPlayer;
- (void) fetchSceneForPlayer; //literally a number... oh well
- (void) fetchInstancesForPlayer;
- (void) fetchTriggersForPlayer;
- (void) fetchOverlaysForPlayer;
- (void) fetchQuestsForPlayer;
- (void) fetchTabsForPlayer;
- (void) fetchOptionsForPlayerForDialog:(int)dialog_id script:(int)dialog_script_id; //doesn't need to be called during game load

- (void) setQtyForInstanceId:(int)instance_id qty:(int)qty;
- (void) setPlayerSceneId:(int)scene_id;
- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m; //actually does full media upload

- (void) logPlayerEnteredGame;
- (void) logPlayerResetGame:(int)game_id;
- (void) logPlayerMoved;
- (void) logPlayerViewedTabId:(int)tab_id;
- (void) logPlayerViewedPlaqueId:(int)plaque_id;
- (void) logPlayerViewedItemId:(int)item_id;
- (void) logPlayerViewedDialogId:(int)dialog_id;
- (void) logPlayerViewedDialogScriptId:(int)dialog_script_id;
- (void) logPlayerViewedWebPageId:(int)web_page_id;
- (void) logPlayerViewedNoteId:(int)note_id;
- (void) logPlayerViewedSceneId:(int)scene_id;
- (void) logPlayerViewedInstanceId:(int)instance_id;
- (void) logPlayerTriggeredTriggerId:(int)trigger_id;
- (void) logPlayerReceivedItemId:(int)item_id qty:(int)qty;
- (void) logPlayerLostItemId:(int)item_id qty:(int)qty;
- (void) logPlayerSetSceneId:(int)scene_id;

//for mid-game fetches. these are failsafes, and oughtn't occur. 
//if you are editing your game mid-play, expect undefined behavior
- (void) fetchSceneById:(int)scene_id;
- (void) fetchMediaById:(int)media_id;
- (void) fetchPlaqueById:(int)plaque_id;
- (void) fetchItemById:(int)item_id;
- (void) fetchDialogById:(int)dialog_id;
- (void) fetchDialogCharacterById:(int)character_id;
- (void) fetchDialogScriptById:(int)script_id;
- (void) fetchDialogOptionById:(int)option_id;
- (void) fetchWebPageById:(int)web_page_id;
- (void) fetchNoteById:(int)note_id;
- (void) fetchTagById:(int)tag_id;
- (void) fetchEventById:(int)event_id;
- (void) fetchQuestById:(int)quest_id;
- (void) fetchInstanceById:(int)instance_id;
- (void) fetchTriggerById:(int)trigger_id;
- (void) fetchOverlayById:(int)overlay_id;
- (void) fetchTabById:(int)tab_id;

@end

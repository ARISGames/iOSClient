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
@class NoteComment;
@class Tag;
@class Trigger;

@interface AppServices : NSObject
{
    ARISMediaLoader *mediaLoader;
}

@property (nonatomic, strong) ARISMediaLoader *mediaLoader;

+ (AppServices *)sharedAppServices;
- (void) setServer:(NSString *)s;

- (void) retryFailedRequests;

- (void) createUserWithName:(NSString *)user_name displayName:(NSString *)display_name groupName:(NSString *)group_name email:(NSString *)email password:(NSString *)password;
- (void) generateUserFromGroup:(NSString *)group_name;
- (void) logInUserWithName:(NSString *)user_name password:(NSString *)password;
- (void) resetPasswordForEmail:(NSString *)email;
- (void) changePasswordFrom:(NSString *)oldp to:(NSString *)newp;
- (void) updatePlayerName:(NSString *)display_name;
- (void) updatePlayerMedia:(Media *)media;

- (void) fetchGame:(long)game_id;
- (void) fetchNearbyGames;
- (void) fetchAnywhereGames;
- (void) fetchRecentGames;
- (void) fetchPopularGamesInterval:(NSString *)i;
- (void) fetchSearchGames:(NSString *)s;
- (void) fetchMineGames;
- (void) fetchPlayerPlayedGame:(long)game_id;

- (void) fetchUsers; //TBD what this actually does...
- (void) fetchScenes;
- (void) touchSceneForPlayer;
- (void) fetchGroups;
- (void) touchGroupForPlayer;
- (void) fetchMedias;
- (void) fetchPlaques;
- (void) fetchItems;
- (void) touchItemsForPlayer; //an odd request- but IS a game-level fetch (calls GAME_PIECE_RECEIVED)
- (void) touchItemsForGame; //an odd request- but IS a game-level fetch (calls GAME_PIECE_RECEIVED)
- (void) touchItemsForGroup; //an odd request- but IS a game-level fetch (calls GAME_PIECE_RECEIVED)
- (void) fetchDialogs;
- (void) fetchDialogCharacters;
- (void) fetchDialogScripts;
- (void) fetchDialogOptions;
- (void) fetchWebPages;
- (void) fetchNotes;
- (void) fetchNoteComments;
- (void) fetchTags;
- (void) fetchObjectTags;
- (void) fetchEvents;
- (void) fetchQuests;
- (void) fetchInstances;
- (void) fetchTriggers;
- (void) fetchFactories;
- (void) fetchOverlays;
- (void) fetchTabs;
- (void) fetchRequirementRoots;
- (void) fetchRequirementAnds;
- (void) fetchRequirementAtoms;

- (void) fetchLogsForPlayer;
- (void) fetchSceneForPlayer; //literally a number... oh well
- (void) fetchGroupForPlayer; //literally a number... oh well
- (void) fetchInstancesForPlayer;
- (void) fetchTriggersForPlayer;
- (void) fetchOverlaysForPlayer;
- (void) fetchQuestsForPlayer;
- (void) fetchTabsForPlayer;
- (void) fetchOptionsForPlayerForDialog:(long)dialog_id script:(long)dialog_script_id; //doesn't need to be called during game load

- (void) setQtyForInstanceId:(long)instance_id qty:(long)qty;
- (void) setPlayerSceneId:(long)scene_id;
- (void) setPlayerGroupId:(long)group_id;
- (void) dropItem:(long)item_id qty:(long)qty;
- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr; //actually does full media upload
- (void) updateNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr;
- (void) deleteNoteId:(long)note_id;
- (void) createNoteComment:(NoteComment *)n;
- (void) updateNoteComment:(NoteComment *)n;
- (void) deleteNoteCommentId:(long)note_comment_id;

- (void) logPlayerEnteredGame;
- (void) logPlayerResetGame:(long)game_id;
- (void) logPlayerMoved;
- (void) logPlayerViewedTabId:(long)tab_id;
- (void) logPlayerViewedPlaqueId:(long)plaque_id;
- (void) logPlayerViewedItemId:(long)item_id;
- (void) logPlayerViewedDialogId:(long)dialog_id;
- (void) logPlayerViewedDialogScriptId:(long)dialog_script_id;
- (void) logPlayerViewedWebPageId:(long)web_page_id;
- (void) logPlayerViewedNoteId:(long)note_id;
- (void) logPlayerViewedSceneId:(long)scene_id;
- (void) logPlayerViewedInstanceId:(long)instance_id;
- (void) logPlayerTriggeredTriggerId:(long)trigger_id;
- (void) logPlayerReceivedItemId:(long)item_id qty:(long)qty;
- (void) logPlayerLostItemId:(long)item_id qty:(long)qty;
- (void) logGameReceivedItemId:(long)item_id qty:(long)qty;
- (void) logGameLostItemId:(long)item_id qty:(long)qty;
- (void) logGroupReceivedItemId:(long)item_id qty:(long)qty;
- (void) logGroupLostItemId:(long)item_id qty:(long)qty;
- (void) logPlayerSetSceneId:(long)scene_id;
- (void) logPlayerJoinedGroupId:(long)group_id;
- (void) logPlayerRanEventPackageId:(long)event_package_id;
- (void) logPlayerCompletedQuestId:(long)quest_id;

//for mid-game fetches. these are failsafes, and oughtn't occur.
//if you are editing your game mid-play, expect undefined behavior
- (void) fetchUserById:(long)user_id;
- (void) fetchSceneById:(long)scene_id;
- (void) fetchGroupById:(long)group_id;
- (void) fetchMediaById:(long)media_id;
- (void) fetchPlaqueById:(long)plaque_id;
- (void) fetchItemById:(long)item_id;
- (void) fetchDialogById:(long)dialog_id;
- (void) fetchDialogCharacterById:(long)character_id;
- (void) fetchDialogScriptById:(long)script_id;
- (void) fetchDialogOptionById:(long)option_id;
- (void) fetchWebPageById:(long)web_page_id;
- (void) fetchNoteById:(long)note_id;
- (void) fetchTagById:(long)tag_id;
- (void) fetchEventById:(long)event_id;
- (void) fetchQuestById:(long)quest_id;
- (void) fetchInstanceById:(long)instance_id;
- (void) fetchTriggerById:(long)trigger_id;
- (void) fetchFactoryById:(long)factory_id;
- (void) fetchOverlayById:(long)overlay_id;
- (void) fetchTabById:(long)tab_id;

@end

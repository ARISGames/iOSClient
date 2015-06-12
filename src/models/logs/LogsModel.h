//
//  LogsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Log.h"
#import "Tab.h"

@interface LogsModel : NSObject

- (Log *) logForId:(long)log_id;
- (void) requestPlayerLogs;
- (void) clearPlayerData;
- (void) clearGameData;
- (BOOL) gameInfoRecvd;

- (void) playerEnteredGame;
- (void) playerMoved;
- (void) playerViewedTabId:(long)tab_id;
- (void) playerViewedContent:(NSString *)content id:(long)content_id;
- (void) playerViewedInstanceId:(long)instance_id;
- (void) playerTriggeredTriggerId:(long)trigger_id;
- (void) playerReceivedItemId:(long)item_id qty:(long)qty;
- (void) playerLostItemId:(long)item_id qty:(long)qty;
- (void) gameReceivedItemId:(long)item_id qty:(long)qty;
- (void) gameLostItemId:(long)item_id qty:(long)qty;
- (void) groupReceivedItemId:(long)item_id qty:(long)qty;
- (void) groupLostItemId:(long)item_id qty:(long)qty;
- (void) playerChangedSceneId:(long)scene_id;
- (void) playerCompletedQuestId:(long)quest_id;

- (BOOL) hasLogType:(NSString *)type;
- (BOOL) hasLogType:(NSString *)type content:(long)content_id;
- (BOOL) hasLogType:(NSString *)type content:(long)content_id qty:(long)qty;

@end

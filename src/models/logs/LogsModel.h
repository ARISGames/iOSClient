//
//  LogsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Log.h"
#import "Tab.h"

@interface LogsModel : ARISModel

- (Log *) logForId:(long)log_id;
- (void) requestPlayerLogs;

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
- (void) playerChangedGroupId:(long)group_id;
- (void) playerRanEventPackageId:(long)event_package_id;
- (void) playerCompletedQuestId:(long)quest_id;
- (void) playerUploadedMedia:(long)media_id Location:(CLLocation *)loc;
- (void) playerUploadedMediaImage:(long)media_id Location:(CLLocation *)loc;
- (void) playerUploadedMediaAudio:(long)media_id Location:(CLLocation *)loc;
- (void) playerUploadedMediaVideo:(long)media_id Location:(CLLocation *)loc;

- (BOOL) hasLogType:(NSString *)type;
- (BOOL) hasLogType:(NSString *)type content:(long)content_id;
- (BOOL) hasLogType:(NSString *)type content:(long)content_id qty:(long)qty;

- (long) countLogsOfType:(NSString *)type;
- (long) countLogsOfType:(NSString *)type Within:(long)distance Lat:(double)lat Long:(double)lng;

@end


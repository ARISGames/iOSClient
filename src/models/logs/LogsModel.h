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

- (Log *) logForId:(int)log_id;
- (void) requestPlayerLogs;
- (void) clearPlayerData;

- (void) playerEnteredGame;
- (void) playerMoved;
- (void) playerViewedTabId:(int)tab_id;
- (void) playerViewedContent:(NSString *)content id:(int)content_id;
- (void) playerViewedInstanceId:(int)instance_id;
- (void) playerTriggeredTriggerId:(int)trigger_id;
- (void) playerReceivedItemId:(int)item_id qty:(int)qty;
- (void) playerLostItemId:(int)item_id qty:(int)qty;
- (void) playerChangedSceneId:(int)scene_id;

@end

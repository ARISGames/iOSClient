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

- (void) playerMoved;
- (void) playerViewedTabId:(int)tab_id;
- (void) playerViewedContent:(NSString *)content id:(int)content_id;
- (void) playerViewedInstanceId:(int)instance_id;
- (void) playerTriggeredTriggerId:(int)trigger_id;

@end

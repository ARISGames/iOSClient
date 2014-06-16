//
//  LogsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Log.h"

@interface LogsModel : NSObject

- (Log *) logForId:(int)log_id;
- (void) requestPlayerLogs;
- (void) clearPlayerData;

@end

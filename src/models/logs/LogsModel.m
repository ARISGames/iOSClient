//
//  LogsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c, 
// we can't know what data we're invalidating by replacing a ptr

#import "LogsModel.h"
#import "AppServices.h"

@interface LogsModel()
{
    NSMutableDictionary *logs;
}

@end

@implementation LogsModel

- (id) init
{
    if(self = [super init])
    {
        [self clearPlayerData];
        _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_LOGS_RECEIVED",self,@selector(logsReceived:),nil);
    }
    return self;
}

- (void) clearPlayerData
{
    logs = [[NSMutableDictionary alloc] init];
}

- (void) logsReceived:(NSNotification *)notif
{
    [self updateLogs:[notif.userInfo objectForKey:@"logs"]];
}

- (void) updateLogs:(NSArray *)newLogs
{
    Log *newLog;
    NSNumber *newLogId;
    for(int i = 0; i < newLogs.count; i++)
    {
      newLog = [newLogs objectAtIndex:i];
      newLogId = [NSNumber numberWithInt:newLog.log_id];
      if(![logs objectForKey:newLogId]) [logs setObject:newLog forKey:newLogId];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_LOGS_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (void) requestPlayerLogs
{
    [_SERVICES_ fetchLogsForPlayer];
}

- (Log *) logForId:(int)log_id
{
  return [logs objectForKey:[NSNumber numberWithInt:log_id]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


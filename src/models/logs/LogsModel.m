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
    for(long i = 0; i < newLogs.count; i++)
    {
      newLog = [newLogs objectAtIndex:i];
      newLogId = [NSNumber numberWithLong:newLog.log_id];
      if(![logs objectForKey:newLogId]) [logs setObject:newLog forKey:newLogId];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_LOGS_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (void) requestPlayerLogs
{
    [_SERVICES_ fetchLogsForPlayer];
}

- (Log *) logForId:(long)log_id
{
  return [logs objectForKey:[NSNumber numberWithLong:log_id]];
}

- (void) playerEnteredGame
{
    [_SERVICES_ logPlayerEnteredGame];
    [self playerMoved]; //start off with a move to set location
}

- (void) playerMoved
{
    [_SERVICES_ logPlayerMoved];
    _ARIS_NOTIF_SEND_(@"USER_MOVED",nil,nil); 
}

- (void) playerViewedTabId:(long)tab_id
{
    [_SERVICES_ logPlayerViewedTabId:tab_id]; 
}

- (void) playerViewedContent:(NSString *)content id:(long)content_id
{
    if([content isEqualToString:@"PLAQUE"])        [_SERVICES_ logPlayerViewedPlaqueId:content_id];  
    if([content isEqualToString:@"ITEM"])          [_SERVICES_ logPlayerViewedItemId:content_id];   
    if([content isEqualToString:@"DIALOG"])        [_SERVICES_ logPlayerViewedDialogId:content_id];   
    if([content isEqualToString:@"DIALOG_SCRIPT"]) [_SERVICES_ logPlayerViewedDialogScriptId:content_id];   
    if([content isEqualToString:@"WEB_PAGE"])      [_SERVICES_ logPlayerViewedWebPageId:content_id];   
    if([content isEqualToString:@"NOTE"])          [_SERVICES_ logPlayerViewedNoteId:content_id];   
    if([content isEqualToString:@"SCENE"])         [_SERVICES_ logPlayerViewedSceneId:content_id];   
}

- (void) playerViewedInstanceId:(long)instance_id
{
    [_SERVICES_ logPlayerViewedInstanceId:instance_id];  
}

- (void) playerTriggeredTriggerId:(long)trigger_id
{
    [_SERVICES_ logPlayerTriggeredTriggerId:trigger_id];   
}

- (void) playerReceivedItemId:(long)item_id qty:(long)qty
{
    [_SERVICES_ logPlayerReceivedItemId:item_id qty:qty];
}

- (void) playerLostItemId:(long)item_id qty:(long)qty
{
    [_SERVICES_ logPlayerLostItemId:item_id qty:qty];
}

- (void) playerChangedSceneId:(long)scene_id
{
    [_SERVICES_ logPlayerSetSceneId:scene_id];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


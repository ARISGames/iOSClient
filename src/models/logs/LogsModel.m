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
#import "AppModel.h"
#import "AppServices.h"
#import "SBJson.h"

@interface LogsModel()
{
    NSMutableDictionary *logs;
    long local_log_id; //starts at 1, no way it will ever catch up to actual logs
}

@end

@implementation LogsModel

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
        _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_LOGS_RECEIVED",self,@selector(logsReceived:),nil);
    }
    return self;
}

- (void) requestPlayerData
{
  [self requestPlayerLogs];
}
- (void) clearPlayerData
{
  logs = [[NSMutableDictionary alloc] init];
  local_log_id = 1;
  n_player_data_received = 0;
}
- (long) nPlayerDataToReceive
{
  return 1;
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
    n_player_data_received++;
    _ARIS_NOTIF_SEND_(@"PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (void) addLogType:(NSString *)type content:(long)content_id qty:(long)qty location:(CLLocation *)loc
{
  Log *l = [[Log alloc] init];
  l.log_id = local_log_id++;
  l.event_type = type;
  l.content_id = content_id;
  l.qty = qty;
  if (loc) l.location = loc;
  [logs setObject:l forKey:[NSNumber numberWithLong:l.log_id]];
}

- (void) addLogType:(NSString *)type content:(long)content_id qty:(long)qty
{
  [self addLogType:type content:content_id qty:qty location:nil];
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
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerEnteredGame];
  [self playerMoved]; //start off with a move to set location
}

- (void) playerMoved
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerMoved];
  _ARIS_NOTIF_SEND_(@"USER_MOVED",nil,nil);
}

- (void) playerViewedTabId:(long)tab_id
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerViewedTabId:tab_id];
  [self addLogType:@"VIEW_TAB" content:tab_id qty:0];
}

- (void) playerViewedContent:(NSString *)content id:(long)content_id
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
  {
    if([content isEqualToString:@"PLAQUE"])        [_SERVICES_ logPlayerViewedPlaqueId:content_id];
    if([content isEqualToString:@"ITEM"])          [_SERVICES_ logPlayerViewedItemId:content_id];
    if([content isEqualToString:@"DIALOG"])        [_SERVICES_ logPlayerViewedDialogId:content_id];
    if([content isEqualToString:@"DIALOG_SCRIPT"]) [_SERVICES_ logPlayerViewedDialogScriptId:content_id];
    if([content isEqualToString:@"WEB_PAGE"])      [_SERVICES_ logPlayerViewedWebPageId:content_id];
    if([content isEqualToString:@"NOTE"])          [_SERVICES_ logPlayerViewedNoteId:content_id];
    if([content isEqualToString:@"SCENE"])         [_SERVICES_ logPlayerViewedSceneId:content_id];
  }

  if([content isEqualToString:@"PLAQUE"])        [self addLogType:@"VIEW_PLAQUE" content:content_id qty:0];
  if([content isEqualToString:@"ITEM"])          [self addLogType:@"VIEW_ITEM" content:content_id qty:0];
  if([content isEqualToString:@"DIALOG"])        [self addLogType:@"VIEW_DIALOG" content:content_id qty:0];
  if([content isEqualToString:@"DIALOG_SCRIPT"]) [self addLogType:@"VIEW_DIALOG_SCRIPT" content:content_id qty:0];
  if([content isEqualToString:@"WEB_PAGE"])      [self addLogType:@"VIEW_WEB_PAGE" content:content_id qty:0];
  if([content isEqualToString:@"NOTE"])          [self addLogType:@"VIEW_NOTE" content:content_id qty:0];
  if([content isEqualToString:@"SCENE"])         [self addLogType:@"CHANGE_SCENE" content:content_id qty:0];

  [_MODEL_QUESTS_ logAnyNewlyCompletedQuests];
}

- (void) playerViewedInstanceId:(long)instance_id
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerViewedInstanceId:instance_id];
  [self addLogType:@"VIEW_INSTANCE" content:instance_id qty:0];
}

- (void) playerTriggeredTriggerId:(long)trigger_id
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerTriggeredTriggerId:trigger_id];
  [self addLogType:@"TRIGGER_TRIGGER" content:trigger_id qty:0];
}

- (void) playerReceivedItemId:(long)item_id qty:(long)qty
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerReceivedItemId:item_id qty:qty];
  [self addLogType:@"RECEIVE_ITEM" content:item_id qty:qty];
  [_MODEL_QUESTS_ logAnyNewlyCompletedQuests];
}

- (void) playerLostItemId:(long)item_id qty:(long)qty
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerLostItemId:item_id qty:qty];
  [self addLogType:@"LOSE_ITEM" content:item_id qty:qty];
  [_MODEL_QUESTS_ logAnyNewlyCompletedQuests];
}

- (void) gameReceivedItemId:(long)item_id qty:(long)qty
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logGameReceivedItemId:item_id qty:qty];
  [self addLogType:@"GAME_RECEIVE_ITEM" content:item_id qty:qty];
  [_MODEL_QUESTS_ logAnyNewlyCompletedQuests];
}

- (void) gameLostItemId:(long)item_id qty:(long)qty
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logGameLostItemId:item_id qty:qty];
  [self addLogType:@"GAME_LOSE_ITEM" content:item_id qty:qty];
  [_MODEL_QUESTS_ logAnyNewlyCompletedQuests];
}

- (void) groupReceivedItemId:(long)item_id qty:(long)qty
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logGroupReceivedItemId:item_id qty:qty];
  [self addLogType:@"GROUP_RECEIVE_ITEM" content:item_id qty:qty];
  [_MODEL_QUESTS_ logAnyNewlyCompletedQuests];
}

- (void) groupLostItemId:(long)item_id qty:(long)qty
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logGroupLostItemId:item_id qty:qty];
  [self addLogType:@"GROUP_LOSE_ITEM" content:item_id qty:qty];
  [_MODEL_QUESTS_ logAnyNewlyCompletedQuests];
}

- (void) playerChangedSceneId:(long)scene_id
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerSetSceneId:scene_id];
  [self addLogType:@"CHANGE_SCENE" content:scene_id qty:0];
}

- (void) playerChangedGroupId:(long)group_id
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerJoinedGroupId:group_id];
  [self addLogType:@"JOIN_GROUP" content:group_id qty:0];
}

- (void) playerRanEventPackageId:(long)event_package_id
{
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ logPlayerRanEventPackageId:event_package_id];
  [self addLogType:@"RUN_EVENT_PACKAGE" content:event_package_id qty:0];
  [_MODEL_QUESTS_ logAnyNewlyCompletedQuests];
}

- (void) playerCompletedQuestId:(long)quest_id
{
  //let server figure it out on its own, for now
  //if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
  //  [_SERVICES_ logPlayerCompletedQuestId:quest_id];
  [self addLogType:@"COMPLETE_QUEST" content:quest_id qty:0];
  [_MODEL_QUESTS_ logAnyNewlyCompletedQuests];
}

- (void) playerUploadedMedia:(long)media_id Location:(CLLocation *)loc
{
  [self addLogType:@"UPLOAD_MEDIA_ITEM" content:media_id qty:0 location:loc];
}

- (void) playerUploadedMediaImage:(long)media_id Location:(CLLocation *)loc
{
  [self addLogType:@"UPLOAD_MEDIA_ITEM_IMAGE" content:media_id qty:0 location:loc];
}

- (void) playerUploadedMediaAudio:(long)media_id Location:(CLLocation *)loc
{
  [self addLogType:@"UPLOAD_MEDIA_ITEM_AUDIO" content:media_id qty:0 location:loc];
}

- (void) playerUploadedMediaVideo:(long)media_id Location:(CLLocation *)loc
{
  [self addLogType:@"UPLOAD_MEDIA_ITEM_VIDEO" content:media_id qty:0 location:loc];
}

- (BOOL) hasLogType:(NSString *)type
{
  NSArray *alllogs = [logs allValues];
  for(int i = 0; i < alllogs.count; i++)
  {
    Log *l = alllogs[i];
    if([l.event_type isEqualToString:type])
      return YES;
  }
  return NO;
}

- (BOOL) hasLogType:(NSString *)type content:(long)content_id
{
  NSArray *alllogs = [logs allValues];
  for(int i = 0; i < alllogs.count; i++)
  {
    Log *l = alllogs[i];
    if([l.event_type isEqualToString:type] &&
       l.content_id == content_id)
      return YES;
  }
  return NO;
}

- (BOOL) hasLogType:(NSString *)type content:(long)content_id qty:(long)qty
{
  NSArray *alllogs = [logs allValues];
  for(int i = 0; i < alllogs.count; i++)
  {
    Log *l = alllogs[i];
    if([l.event_type isEqualToString:type] &&
       l.content_id == content_id &&
       l.qty == qty)
      return YES;
  }
  return NO;
}

- (long) countLogsOfType:(NSString *)type
{
  NSArray *alllogs = [logs allValues];
  long qty = 0;
  for (int i = 0; i < alllogs.count; i++)
  {
    Log *l = alllogs[i];
    if (type && ![l.event_type isEqualToString:type]) {
      continue;
    }
    qty++;
  }
  return qty;
}

- (long) countLogsOfType:(NSString *)type Within:(long)distance Lat:(double)lat Long:(double)lng
{
  NSArray *alllogs = [logs allValues];
  long qty = 0;
  for (int i = 0; i < alllogs.count; i++)
  {
    Log *l = alllogs[i];
    if (type && ![l.event_type isEqualToString:type]) {
      continue;
    }
    if ([l.location distanceFromLocation:[[CLLocation alloc] initWithLatitude:lat longitude:lng]] > distance) {
      continue;
    }
    qty++;
  }
  return qty;
}

- (NSString *) serializedName
{
  return @"logs";
}

- (NSString *) serializePlayerData
{
  NSArray *logs_a = [logs allValues];
  Log *l_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"logs\":["];
  for(long i = 0; i < logs_a.count; i++)
  {
    l_o = logs_a[i];
    [r appendString:[l_o serialize]];
    if(i != logs_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializePlayerData:(NSString *)data
{
  [self clearPlayerData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_logs = d_data[@"logs"];
  for(long i = 0; i < d_logs.count; i++)
  {
    Log *l = [[Log alloc] initWithDictionary:d_logs[i]];
    [logs setObject:l forKey:[NSNumber numberWithLong:l.log_id]];
  }
  
  n_player_data_received = [self nPlayerDataToReceive];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


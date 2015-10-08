//
//  GroupsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "GroupsModel.h"
#import "AppModel.h"
#import "AppServices.h"
#import "SBJson.h"

@interface GroupsModel()
{
  NSMutableDictionary *groups;
}

@end

@implementation GroupsModel

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_GROUPS_RECEIVED",self,@selector(groupsReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_GROUP_TOUCHED",self,@selector(groupTouched:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_GROUP_RECEIVED",self,@selector(playerGroupReceived:),nil);
  }
  return self;
}

- (void) requestGameData
{
  [self requestGroups];
  [self touchPlayerGroup];
}
- (void) clearGameData
{
  groups = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 2;
}

- (void) requestPlayerData
{
  [self requestPlayerGroup];
}
- (void) clearPlayerData
{
  playerGroup = nil;
  n_player_data_received = 0;
}
- (long) nPlayerDataToReceive
{
  return 1;
}

- (void) groupsReceived:(NSNotification *)notif
{
  [self updateGroups:notif.userInfo[@"groups"]];
}

- (void) playerGroupReceived:(NSNotification *)notif
{
  Group *s = [self groupForId:((Group *)notif.userInfo[@"group"]).group_id];
  [self updatePlayerGroup:s];
}

- (void) groupTouched:(NSNotification *)notif
{
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_GROUP_TOUCHED",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) updateGroups:(NSArray *)newGroups
{
  Group *newGroup;
  NSNumber *newGroupId;
  for(long i = 0; i < newGroups.count; i++)
  {
    newGroup = [newGroups objectAtIndex:i];
    newGroupId = [NSNumber numberWithLong:newGroup.group_id];
    if(!groups[newGroupId]) [groups setObject:newGroup forKey:newGroupId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_GROUPS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) updatePlayerGroup:(Group *)newGroup
{
  playerGroup = newGroup;
  n_player_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_GROUPS_PLAYER_GROUP_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (void) requestGroups
{
  [_SERVICES_ fetchGroups];
}

- (void) touchPlayerGroup
{
  [_SERVICES_ touchGroupForPlayer];
}

- (void) requestPlayerGroup
{
  if([self playerDataReceived] &&
     ![_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
  {
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_GROUP_RECEIVED",nil,@{@"group":playerGroup}); //just return current
  }
  if(![self playerDataReceived] ||
     [_MODEL_GAME_.network_level isEqualToString:@"HYBRID"] ||
     [_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
    [_SERVICES_ fetchGroupForPlayer];
}

- (Group *) playerGroup
{
  return playerGroup;
}

- (void) setPlayerGroup:(Group *)g
{
  playerGroup = g;
  [_MODEL_LOGS_ playerChangedGroupId:g.group_id];
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ setPlayerGroupId:g.group_id];
  _ARIS_NOTIF_SEND_(@"MODEL_GROUPS_PLAYER_GROUP_AVAILABLE",nil,nil);
}

// null group (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Group *) groupForId:(long)group_id
{
  if(!group_id) return [[Group alloc] init];
  return groups[[NSNumber numberWithLong:group_id]];
}

- (NSString *) serializedName
{
  return @"groups";
}

- (NSString *) serializeGameData
{
  NSArray *groups_a = [groups allValues];
  Group *g_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"groups\":["];
  for(long i = 0; i < groups_a.count; i++)
  {
    g_o = groups_a[i];
    [r appendString:[g_o serialize]];
    if(i != groups_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_groups = d_data[@"groups"];
  for(long i = 0; i < d_groups.count; i++)
  {
    Group *g = [[Group alloc] initWithDictionary:d_groups[i]];
    [groups setObject:g forKey:[NSNumber numberWithLong:g.group_id]];
  }
}

- (NSString *) serializePlayerData
{
  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"group\":"];
  [r appendString:[playerGroup serialize]];
  [r appendString:@"}"];
  return r;
}

- (void) deserializePlayerData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  Group *g = [[Group alloc] initWithDictionary:d_data[@"group"]];
  playerGroup = [_MODEL_GROUPS_ groupForId:g.group_id];
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

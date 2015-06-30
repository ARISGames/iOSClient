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

@interface GroupsModel()
{
    NSMutableDictionary *groups;
    long game_info_recvd;
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

- (void) clearGameData
{
    groups = [[NSMutableDictionary alloc] init];
    game_info_recvd = 0;
}

- (BOOL) gameInfoRecvd
{
  return game_info_recvd >= 2;
}

- (void) clearPlayerData
{
    playerGroup = nil;
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
    game_info_recvd++;
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
    game_info_recvd++;
    _ARIS_NOTIF_SEND_(@"MODEL_GROUPS_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) updatePlayerGroup:(Group *)newGroup
{
    playerGroup = newGroup;
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
    [_SERVICES_ fetchGroupForPlayer];
}

- (Group *) playerGroup
{
    return playerGroup;
}

- (void) setPlayerGroup:(Group *)s
{
    playerGroup = s;
    [_MODEL_LOGS_ playerChangedGroupId:s.group_id];
    [_SERVICES_ setPlayerGroupId:s.group_id];
    _ARIS_NOTIF_SEND_(@"MODEL_GROUPS_PLAYER_GROUP_AVAILABLE",nil,nil);
}

// null group (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Group *) groupForId:(long)group_id
{
  if(!group_id) return [[Group alloc] init];
  return groups[[NSNumber numberWithLong:group_id]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

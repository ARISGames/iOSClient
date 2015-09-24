//
//  QuestsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "QuestsModel.h"
#import "AppModel.h"
#import "AppServices.h"

@interface QuestsModel()
{
  NSMutableDictionary *quests;

  NSArray *visibleActiveQuests;
  NSArray *visibleCompleteQuests;
}

@end

@implementation QuestsModel

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_QUESTS_RECEIVED",self,@selector(questsReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_QUESTS_RECEIVED",self,@selector(playerQuestsReceived:),nil);
  }
  return self;
}

- (void) requestPlayerData
{
  [self requestPlayerQuests];
}
- (void) clearPlayerData
{
  visibleActiveQuests = [[NSArray alloc] init];
  visibleCompleteQuests = [[NSArray alloc] init];
  n_player_data_received = 0;
}
- (long) nPlayerDataToReceive
{
  return 1;
}

- (void) requestGameData
{
  [self requestQuests];
}
- (void) clearGameData
{
  [self clearPlayerData];
  quests = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) questsReceived:(NSNotification *)notif
{
  [self updateQuests:[notif.userInfo objectForKey:@"quests"]];
}

- (void) updateQuests:(NSArray *)newQuests
{
  Quest *newQuest;
  NSNumber *newQuestId;
  for(long i = 0; i < newQuests.count; i++)
  {
    newQuest = [newQuests objectAtIndex:i];
    newQuestId = [NSNumber numberWithLong:newQuest.quest_id];
    if(![quests objectForKey:newQuestId]) [quests setObject:newQuest forKey:newQuestId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_QUESTS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestQuests       { [_SERVICES_ fetchQuests]; }

- (void) requestPlayerQuests
{
  if([self playerDataReceived] &&
     ![_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
  {
    [self logAnyNewlyCompletedQuests];
    NSDictionary *pquests =
      @{
        @"active"   : [[NSMutableArray alloc] init],
        @"complete" : [[NSMutableArray alloc] init]
      };
    NSArray *qs = [quests allValues];
    for(int i = 0; i < qs.count; i++)
    {
      Quest *q = qs[i];
      if([_MODEL_REQUIREMENTS_ evaluateRequirementRoot:q.active_requirement_root_package_id])
      {
        if([_MODEL_LOGS_ hasLogType:@"COMPLETE_QUEST" content:q.quest_id])
          [pquests[@"complete"] addObject:q];
        else
          [pquests[@"active"] addObject:q];
      }
    }
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_QUESTS_RECEIVED",nil,pquests);
  }
  if(![self playerDataReceived] ||
     [_MODEL_GAME_.network_level isEqualToString:@"HYBRID"] ||
     [_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
    [_SERVICES_ fetchQuestsForPlayer];
}

- (void) logAnyNewlyCompletedQuests
{
  NSArray *qs = [quests allValues];
  for(int i = 0; i < qs.count; i++)
  {
    Quest *q = qs[i];
    if(![_MODEL_LOGS_ hasLogType:@"COMPLETE_QUEST" content:q.quest_id])
    {
      if([_MODEL_REQUIREMENTS_ evaluateRequirementRoot:q.complete_requirement_root_package_id])
      {
        [_MODEL_REQUIREMENTS_ evaluateRequirementRoot:q.complete_requirement_root_package_id];
        [_MODEL_LOGS_ playerCompletedQuestId:q.quest_id];
      }
    }
  }
}

//admittedly a bit silly, but a great way to rid any risk of deviation from flyweight by catching it at the beginning
- (NSArray *) conformQuestListToFlyweight:(NSArray *)newQuests
{
  NSMutableArray *conformingQuests = [[NSMutableArray alloc] init];
  Quest *q;
  for(long i = 0; i < newQuests.count; i++)
  {
    if((q = [self questForId:((Quest *)newQuests[i]).quest_id]))
      [conformingQuests addObject:q];
  }

  return conformingQuests;
}

- (void) playerQuestsReceived:(NSNotification *)notification
{
  [self updateCompleteQuests:[self conformQuestListToFlyweight:[notification.userInfo objectForKey:@"complete"]]];
  [self updateActiveQuests:[self conformQuestListToFlyweight:[notification.userInfo objectForKey:@"active"]]];
  n_player_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (void) updateActiveQuests:(NSArray *)newQuests
{
  NSDictionary *deltas = [self findDeltasInNew:newQuests fromOld:visibleActiveQuests];
  visibleActiveQuests = newQuests; //assumes already conforms to flyweight

  NSArray *addedDeltas = deltas[@"added"];
  if(addedDeltas.count > 0)
    _ARIS_NOTIF_SEND_(@"MODEL_QUESTS_ACTIVE_NEW_AVAILABLE",nil,deltas);
  for(long i = 0; i < addedDeltas.count; i++)
    [_MODEL_EVENTS_ runEventPackageId:((Quest *)addedDeltas[i]).active_event_package_id];

  NSArray *removedDeltas = deltas[@"removed"];
  if(removedDeltas.count > 0)
    _ARIS_NOTIF_SEND_(@"MODEL_QUESTS_ACTIVE_LESS_AVAILABLE",nil,deltas);
}

- (void) updateCompleteQuests:(NSArray *)newQuests
{
  NSDictionary *deltas = [self findDeltasInNew:newQuests fromOld:visibleCompleteQuests];
  visibleCompleteQuests = newQuests; //assumes already conforms to flyweight

  NSArray *addedDeltas = deltas[@"added"];
  if(addedDeltas.count > 0)
    _ARIS_NOTIF_SEND_(@"MODEL_QUESTS_COMPLETE_NEW_AVAILABLE",nil,deltas);
  for(long i = 0; i < addedDeltas.count; i++)
    [_MODEL_EVENTS_ runEventPackageId:((Quest *)addedDeltas[i]).complete_event_package_id];

  NSArray *removedDeltas = deltas[@"removed"];
  if(removedDeltas.count > 0)
    _ARIS_NOTIF_SEND_(@"MODEL_QUESTS_COMPLETE_LESS_AVAILABLE",nil,deltas);
}

//finds deltas in quest lists generally, so I can just use same code for complete/active
- (NSDictionary *) findDeltasInNew:(NSArray *)newQuests fromOld:(NSArray *)oldQuests
{
  NSDictionary *qDeltas = @{ @"added":[[NSMutableArray alloc] init], @"removed":[[NSMutableArray alloc] init] };

  //placeholders for comparison
  Quest *newQuest;
  Quest *oldQuest;

  //find added
  BOOL newq;
  for(long i = 0; i < newQuests.count; i++)
  {
    newq = YES;
    newQuest = newQuests[i];
    for(long j = 0; j < oldQuests.count; j++)
    {
      oldQuest = oldQuests[j];
      if(newQuest.quest_id == oldQuest.quest_id) newq = NO;
    }
    if(newq) [qDeltas[@"added"] addObject:newQuests[i]];
  }

  //find removed
  BOOL removed;
  for(long i = 0; i < oldQuests.count; i++)
  {
    removed = YES;
    oldQuest = oldQuests[i];
    for(long j = 0; j < newQuests.count; j++)
    {
      newQuest = newQuests[j];
      if(newQuest.quest_id == oldQuest.quest_id) removed = NO;
    }
    if(removed) [qDeltas[@"removed"] addObject:oldQuests[i]];
  }

  return qDeltas;
}

- (Quest *) questForId:(long)quest_id
{
  if(!quest_id) return [[Quest alloc] init];
  return [quests objectForKey:[NSNumber numberWithLong:quest_id]];
}

- (NSArray *) visibleActiveQuests
{
  return visibleActiveQuests;
}

- (NSArray *) visibleCompleteQuests
{
  return visibleCompleteQuests;
}

- (NSString *) serializeModel
{
  NSArray *quests_a = [quests allValues];
  Quest *q_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"quests\":["];
  for(long i = 0; i < quests_a.count; i++)
  {
    q_o = quests_a[i];
    [r appendString:[q_o serialize]];
    if(i != quests_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeModel:(NSString *)data
{

}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

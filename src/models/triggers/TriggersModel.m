//
//  TriggersModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "TriggersModel.h"
#import "AppServices.h"
#import "AppModel.h"
#import "SBJson.h"

@interface TriggersModel()
{
  NSMutableDictionary *triggers;
  NSArray *playerTriggers;

  NSMutableDictionary *blacklist; //list of ids attempting / attempted and failed to load
}
@end

@implementation TriggersModel

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];

    _ARIS_NOTIF_LISTEN_(@"SERVICES_TRIGGERS_RECEIVED",self,@selector(triggersReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_TRIGGER_RECEIVED",self,@selector(triggerReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_TRIGGERS_RECEIVED",self,@selector(playerTriggersReceived:),nil);
  }
  return self;
}

- (void) requestPlayerData
{
  [self requestPlayerTriggers];
}
- (void) clearPlayerData
{
  playerTriggers = [[NSArray alloc] init];
  n_player_data_received = 0;
}
- (long) nPlayerDataToReceive
{
  return 1;
}

- (void) requestGameData
{
  [self requestTriggers];
}
- (void) clearGameData
{
  [self clearPlayerData];
  triggers  = [[NSMutableDictionary alloc] init];
  blacklist = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) triggersReceived:(NSNotification *)notif
{
  [self updateTriggers:notif.userInfo[@"triggers"]];
}

- (void) triggerReceived:(NSNotification *)notif
{
  [self updateTriggers:@[notif.userInfo[@"trigger"]]];
}

- (void) updateTriggers:(NSArray *)newTriggers
{
  Trigger *newTrigger;
  NSNumber *newTriggerId;
  NSMutableArray *invalidatedTriggers = [[NSMutableArray alloc] init];
  for(long i = 0; i < newTriggers.count; i++)
  {
    newTrigger = [newTriggers objectAtIndex:i];
    newTriggerId = [NSNumber numberWithLong:newTrigger.trigger_id];
    if(![triggers objectForKey:newTriggerId])
    {
      [triggers setObject:newTrigger forKey:newTriggerId];
      [blacklist removeObjectForKey:[NSNumber numberWithLong:newTriggerId]];
    }
    else
      if(![[triggers objectForKey:newTriggerId] mergeDataFromTrigger:newTrigger])
        [invalidatedTriggers addObject:[triggers objectForKey:newTriggerId]];
  }
  if(invalidatedTriggers.count) _ARIS_NOTIF_SEND_(@"MODEL_TRIGGERS_INVALIDATED",nil,@{@"invalidated_triggers":invalidatedTriggers});

  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_TRIGGERS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (NSArray *) conformTriggersListToFlyweight:(NSArray *)newTriggers
{
  NSMutableArray *conformingTriggers = [[NSMutableArray alloc] init];
  NSMutableArray *invalidatedTriggers = [[NSMutableArray alloc] init];
  for(long i = 0; i < newTriggers.count; i++)
  {
    Trigger *newt = newTriggers[i];
    Trigger *exist = [self triggerForId:newt.trigger_id];

    if(exist)
    {
      if(![exist mergeDataFromTrigger:newt]) [invalidatedTriggers addObject:exist];
      [conformingTriggers addObject:exist];
    }
    else
    {
      [triggers setObject:newt forKey:[NSNumber numberWithLong:newt.trigger_id]];
      [conformingTriggers addObject:newt];
    }
  }
  if(invalidatedTriggers.count) _ARIS_NOTIF_SEND_(@"MODEL_TRIGGERS_INVALIDATED",nil,@{@"invalidated_triggers":invalidatedTriggers});
  return conformingTriggers;
}

- (void) playerTriggersReceived:(NSNotification *)notif
{
  [self updatePlayerTriggers:[self conformTriggersListToFlyweight:notif.userInfo[@"triggers"]]];
}

- (void) updatePlayerTriggers:(NSArray *)newTriggers
{
  NSMutableArray *addedTriggers = [[NSMutableArray alloc] init];
  NSMutableArray *removedTriggers = [[NSMutableArray alloc] init];

  //placeholders for comparison
  Trigger *newTrigger;
  Trigger *oldTrigger;

  //find added
  BOOL new;
  for(long i = 0; i < newTriggers.count; i++)
  {
    new = YES;
    newTrigger = newTriggers[i];
    for(long j = 0; j < playerTriggers.count; j++)
    {
      oldTrigger = playerTriggers[j];
      if(newTrigger.trigger_id == oldTrigger.trigger_id) new = NO;
    }
    if(new) [addedTriggers addObject:newTriggers[i]];
  }

  //find removed
  BOOL removed;
  for(long i = 0; i < playerTriggers.count; i++)
  {
    removed = YES;
    oldTrigger = playerTriggers[i];
    for(long j = 0; j < newTriggers.count; j++)
    {
      newTrigger = newTriggers[j];
      if(newTrigger.trigger_id == oldTrigger.trigger_id) removed = NO;
    }
    if(removed) [removedTriggers addObject:playerTriggers[i]];
  }

  playerTriggers = newTriggers;
  n_player_data_received++;

  if(addedTriggers.count > 0)   _ARIS_NOTIF_SEND_(@"MODEL_TRIGGERS_NEW_AVAILABLE",nil,@{@"added":addedTriggers});
  if(removedTriggers.count > 0) _ARIS_NOTIF_SEND_(@"MODEL_TRIGGERS_LESS_AVAILABLE",nil,@{@"removed":removedTriggers});
  _ARIS_NOTIF_SEND_(@"MODEL_PLAYER_TRIGGERS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (void) requestTriggers { [_SERVICES_ fetchTriggers]; }
- (void) requestTrigger:(long)t { [_SERVICES_ fetchTriggerById:t]; }
- (void) requestPlayerTriggers
{
  if([self playerDataReceived] &&
     ![_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
  {
    NSMutableArray *ptrigs = [[NSMutableArray alloc] init];
    NSArray *ts = [triggers allValues];
    for(int i = 0; i < ts.count; i++)
    {
      Trigger *t = ts[i];
      if(t.scene_id == _MODEL_SCENES_.playerScene.scene_id  && [_MODEL_REQUIREMENTS_ evaluateRequirementRoot:t.requirement_root_package_id])
        [ptrigs addObject:t];
    }
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_TRIGGERS_RECEIVED",nil,@{@"triggers":ptrigs});
  }
  if(![self playerDataReceived] ||
     [_MODEL_GAME_.network_level isEqualToString:@"HYBRID"] ||
     [_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
    [_SERVICES_ fetchTriggersForPlayer];
}

// null trigger (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Trigger *) triggerForId:(long)trigger_id
{
  if(!trigger_id) return [[Trigger alloc] init];
  Trigger *t = [triggers objectForKey:[NSNumber numberWithLong:trigger_id]];
  if(!t)
  {
    [blacklist setObject:@"true" forKey:[NSNumber numberWithLong:trigger_id]];
    [self requestTrigger:trigger_id];
    return [[Trigger alloc] init];
  }
  return t;
}

- (NSArray *) triggersForInstanceId:(long)instance_id
{
  NSMutableArray *a = [[NSMutableArray alloc] init];
  for(long i = 0; i < triggers.count; i++)
  {
    Trigger *t = [triggers allValues][i];
    if(t.instance_id == instance_id)
      [a addObject:t];
  }
  return a;
}

- (Trigger *) triggerForQRCode:(NSString *)code
{
  Trigger *t;
  for(long i = 0; i < playerTriggers.count; i++)
  {
    t = playerTriggers[i];
    if([t.type isEqualToString:@"QR"] && [t.qr_code isEqualToString:code]) return t;
  }
  return nil;
}

- (NSArray *) playerTriggers
{
  return playerTriggers;
}

- (void) expireTriggersForInstanceId:(long)instance_id
{
  NSMutableArray *newTriggers = [[NSMutableArray alloc] init];
  for(long i = 0; i < playerTriggers.count; i++)
  {
    if(((Trigger *)playerTriggers[i]).instance_id != instance_id)
      [newTriggers addObject:playerTriggers[i]];
  }
  [self updatePlayerTriggers:newTriggers];
}

- (NSString *) serializedName
{
  return @"triggers";
}

- (NSString *) serializeGameData
{
  NSArray *triggers_a = [triggers allValues];
  Trigger *t_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"triggers\":["];
  for(long i = 0; i < triggers_a.count; i++)
  {
    t_o = triggers_a[i];
    [r appendString:[t_o serialize]];
    if(i != triggers_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_triggers = d_data[@"triggers"];
  for(long i = 0; i < d_triggers.count; i++)
  {
    Trigger *t = [[Trigger alloc] initWithDictionary:d_triggers[i]];
    [triggers setObject:t forKey:[NSNumber numberWithLong:t.trigger_id]];
  }
}

- (NSString *) serializePlayerData
{
  NSArray *triggers_a = playerTriggers;
  Trigger *t_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"triggers\":["];
  for(long i = 0; i < triggers_a.count; i++)
  {
    t_o = triggers_a[i];
    [r appendString:[t_o serialize]];
    if(i != triggers_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializePlayerData:(NSString *)data
{
  [self clearPlayerData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_triggers = d_data[@"triggers"];
  NSMutableArray *pts = [[NSMutableArray alloc] init];
  for(long i = 0; i < d_triggers.count; i++)
  {
    Trigger *t = [[Trigger alloc] initWithDictionary:d_triggers[i]];
    [pts addObject:[_MODEL_TRIGGERS_ triggerForId:t.trigger_id]];
  }
  playerTriggers = pts;
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


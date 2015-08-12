//
//  InstancesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "InstancesModel.h"
#import "AppServices.h"
#import "AppModel.h"

@interface InstancesModel()
{
  NSMutableDictionary *instances;
  NSMutableDictionary *blacklist; //list of ids attempting / attempted and failed to load
}
@end

@implementation InstancesModel

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];

    _ARIS_NOTIF_LISTEN_(@"SERVICES_INSTANCES_RECEIVED",self,@selector(gameInstancesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_INSTANCES_RECEIVED",self,@selector(playerInstancesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_INSTANCE_RECEIVED",self,@selector(instanceReceived:),nil);
  }
  return self;
}

- (void) requestGameData
{
  [self requestInstances];
}
- (void) clearGameData
{
  [self clearPlayerData]; //not actually necessary- just removes player owned from list
  instances = [[NSMutableDictionary alloc] init]; //will get cleared here anyway
  blacklist = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) requestPlayerData
{
  [self requestPlayerInstances];
}
- (void) clearPlayerData
{
  NSArray *insts = [instances allValues];
  for(long i = 0; i < insts.count; i++)
  {
    if(((Instance *)insts[i]).owner_id == _MODEL_PLAYER_.user_id)
      [instances removeObjectForKey:[NSNumber numberWithLong:((Instance *)insts[i]).instance_id]];
  }
  n_player_data_received = 0;
}
- (long) nPlayerDataToReceive
{
  return 1;
}

//only difference at this point is notification sent- all other functionality same (merge into all known insts)
- (void) playerInstancesReceived:(NSNotification *)notif
{ 
  [self updateInstances:[notif.userInfo objectForKey:@"instances"]]; 
  n_player_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);
}
- (void) gameInstancesReceived:(NSNotification *)notif
{
  [self updateInstances:[notif.userInfo objectForKey:@"instances"]];
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}
- (void) instanceReceived:(NSNotification *)notif
{ [self updateInstances:@[[notif.userInfo objectForKey:@"instance"]]]; }

- (void) updateInstances:(NSArray *)newInstances
{
  Instance *newInstance;
  NSNumber *newInstanceId;

  NSDictionary *playerDeltas = @{@"added":[[NSMutableArray alloc] init],@"lost":[[NSMutableArray alloc] init]};
  NSDictionary *gameDeltas   = @{@"added":[[NSMutableArray alloc] init],@"lost":[[NSMutableArray alloc] init]};
  for(long i = 0; i < newInstances.count; i++)
  {
    newInstance = [newInstances objectAtIndex:i];
    newInstanceId = [NSNumber numberWithLong:newInstance.instance_id];
    if(![instances objectForKey:newInstanceId])
    {
      //No instance exists- give player instance with 0 qty and let it be updated like all the others
      Instance *fakeExistingInstance = [[Instance alloc] init];
      [fakeExistingInstance mergeDataFromInstance:newInstance];
      fakeExistingInstance.qty = 0;
      [instances setObject:fakeExistingInstance forKey:newInstanceId];
      [blacklist removeObjectForKey:[NSNumber numberWithLong:newInstanceId]];
    }

    Instance *existingInstance = [instances objectForKey:newInstanceId];
    long delta = newInstance.qty-existingInstance.qty;
    [existingInstance mergeDataFromInstance:newInstance];

    NSDictionary *d = @{@"instance":existingInstance,@"delta":[NSNumber numberWithLong:delta]};
    if(existingInstance.owner_id == _MODEL_PLAYER_.user_id)
    {
      if(![self playerDataReceived]) //only local should be making changes to player. fixes race cond (+1, -1, +1 notifs)
      {
        if(delta > 0) [((NSMutableArray *)playerDeltas[@"added"]) addObject:d];
        if(delta < 0) [((NSMutableArray *)playerDeltas[@"lost" ]) addObject:d];
      }
    }
    else
    {
      //race cond (above) still applies here, but notifs oughtn't be a problem, and fixes self over time
      if(delta > 0) [((NSMutableArray *)gameDeltas[@"added"]) addObject:d];
      if(delta < 0) [((NSMutableArray *)gameDeltas[@"lost" ]) addObject:d];
    }
  }

  [self sendNotifsForGameDeltas:gameDeltas playerDeltas:playerDeltas];
}

- (void) sendNotifsForGameDeltas:(NSDictionary *)gameDeltas playerDeltas:(NSDictionary *)playerDeltas
{
  if(playerDeltas)
  {
    if(((NSArray *)playerDeltas[@"added"]).count > 0) _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_PLAYER_GAINED",nil,playerDeltas);
    if(((NSArray *)playerDeltas[@"lost"]).count  > 0) _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_PLAYER_LOST",  nil,playerDeltas);
    _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_PLAYER_AVAILABLE",nil,playerDeltas);
  }

  if(gameDeltas)
  {
    if(((NSArray *)gameDeltas[@"added"]).count > 0) _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_GAINED",nil,gameDeltas);
    if(((NSArray *)gameDeltas[@"lost"]).count  > 0) _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_LOST",  nil,gameDeltas);
    _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_AVAILABLE",nil,gameDeltas);
  }
}

- (void) requestInstances       { [_SERVICES_ fetchInstances];   }
- (void) requestInstance:(long)i { [_SERVICES_ fetchInstanceById:i];   }
- (void) requestPlayerInstances
{
  if([self playerDataReceived] && [_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
  {
    NSArray *pinsts = [instances allValues];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_INSTANCES_RECEIVED",nil,@{@"instances":pinsts});
  }
  else [_SERVICES_ fetchInstancesForPlayer];
}

- (long) setQtyForInstanceId:(long)instance_id qty:(long)qty
{
  Instance *i = [self instanceForId:instance_id];
  if(!i) return 0;
  if(qty < 0) qty = 0;

  long oldQty = i.qty;
  i.qty = qty;
  NSDictionary *deltas;
  if(qty > oldQty) deltas = @{@"lost":@[],@"added":@[@{@"instance":i,@"delta":[NSNumber numberWithLong:qty-oldQty]}]};
  if(qty < oldQty) deltas = @{@"added":@[],@"lost":@[@{@"instance":i,@"delta":[NSNumber numberWithLong:qty-oldQty]}]};

  if(deltas)
  {
    if([i.owner_type isEqualToString:@"USER"] && i.owner_id == _MODEL_PLAYER_.user_id)
      [self sendNotifsForGameDeltas:nil playerDeltas:deltas];
    else if([i.owner_type isEqualToString:@"GAME_CONTENT"])
      [self sendNotifsForGameDeltas:deltas playerDeltas:nil];
  }

  [_SERVICES_ setQtyForInstanceId:instance_id qty:qty];
  return qty;
}

// null instance (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Instance *) instanceForId:(long)instance_id
{
  if(!instance_id) return [[Instance alloc] init];
  Instance *i = [instances objectForKey:[NSNumber numberWithLong:instance_id]];
  if(!i)
  {
    [blacklist setObject:@"true" forKey:[NSNumber numberWithLong:instance_id]];
    [self requestInstance:instance_id];
    return [[Instance alloc] init];
  }
  return i;
}

- (NSArray *) instancesForType:(NSString *)object_type id:(long)object_id
{
  NSMutableArray *a = [[NSMutableArray alloc] init];
  for(long i = 0; i < instances.count; i++)
  {
    Instance *inst = [instances allValues][i];
    if(inst.object_id == object_id && [inst.object_type isEqualToString:object_type])
      [a addObject:inst];
  }
  return a;
}

- (NSArray *) playerInstances
{
  NSMutableArray *pInstances = [[NSMutableArray alloc] init];
  NSArray *allInstances = [instances allValues];
  for(long i = 0; i < allInstances.count; i++)
  {
    Instance *inst = allInstances[i];
    if([inst.owner_type isEqualToString:@"USER"] &&
        inst.owner_id == _MODEL_PLAYER_.user_id)
      [pInstances addObject:allInstances[i]];
  }
  return pInstances;
}

- (NSArray *) gameOwnedInstances
{
  NSMutableArray *gInstances = [[NSMutableArray alloc] init];
  NSArray *allInstances = [instances allValues];
  for(long i = 0; i < allInstances.count; i++)
  {
    Instance *inst = allInstances[i];
    if([inst.owner_type isEqualToString:@"GAME"])
      [gInstances addObject:allInstances[i]];
  }
  return gInstances;
}

- (NSArray *) groupOwnedInstances
{
  NSMutableArray *gInstances = [[NSMutableArray alloc] init];
  NSArray *allInstances = [instances allValues];
  for(long i = 0; i < allInstances.count; i++)
  {
    Instance *inst = allInstances[i];
    if([inst.owner_type isEqualToString:@"GROUP"] &&
        inst.owner_id == _MODEL_GROUPS_.playerGroup.group_id)
      [gInstances addObject:allInstances[i]];
  }
  return gInstances;
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

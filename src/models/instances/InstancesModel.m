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
        _ARIS_NOTIF_LISTEN_(@"SERVICES_INSTANCE_RECEIVED",self,@selector(instanceReceived:),nil);
        _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_INSTANCES_RECEIVED",self,@selector(playerInstancesReceived:),nil); 
    }
    return self;
}

- (void) clearPlayerData
{
    NSArray *insts = [instances allValues];
    for(int i = 0; i < insts.count; i++)
    {
        if(((Instance *)insts[i]).owner_id == _MODEL_PLAYER_.user_id)
            [instances removeObjectForKey:[NSNumber numberWithInt:((Instance *)insts[i]).instance_id]];
    }
}

- (void) clearGameData
{
    [self clearPlayerData]; //not actually necessary- just removes player owned from list
    instances = [[NSMutableDictionary alloc] init]; //will get cleared here anyway
    blacklist = [[NSMutableDictionary alloc] init];
}

//only difference is notification sent- all other functionality same
- (void) playerInstancesReceived:(NSNotification *)notif 
{ [self updateInstances:[notif.userInfo objectForKey:@"instances"] player:YES]; }
- (void) gameInstancesReceived:(NSNotification *)notif 
{ [self updateInstances:[notif.userInfo objectForKey:@"instances"] player:NO]; }
- (void) instancesReceived:(NSNotification *)notif 
{ [self updateInstances:@[[notif.userInfo objectForKey:@"instance"]] player:NO]; }

- (void) updateInstances:(NSArray *)newInstances player:(BOOL)player
{
    Instance *newInstance;
    NSNumber *newInstanceId;
    
    NSDictionary *deltas = @{@"added":[[NSMutableArray alloc] init],@"lost":[[NSMutableArray alloc] init]};
    for(int i = 0; i < newInstances.count; i++)
    {
      newInstance = [newInstances objectAtIndex:i];
      newInstanceId = [NSNumber numberWithInt:newInstance.instance_id];
      if(![instances objectForKey:newInstanceId])
      {
        //No instance exists- give player instance with 0 qty and let it be updated like all the others
        Instance *fakeExistingInstance = [[Instance alloc] init];
        [fakeExistingInstance mergeDataFromInstance:newInstance];
        fakeExistingInstance.qty = 0;
        [instances setObject:fakeExistingInstance forKey:newInstanceId];
        [blacklist removeObjectForKey:[NSNumber numberWithInt:newInstanceId]];
      }
      
      Instance *existingInstance = [instances objectForKey:newInstanceId];
      int delta = newInstance.qty-existingInstance.qty;
      BOOL gained = (existingInstance.qty < newInstance.qty);
      BOOL lost   = (existingInstance.qty > newInstance.qty);
      [existingInstance mergeDataFromInstance:newInstance];
        
      NSDictionary *d = @{@"instance":existingInstance,@"delta":[NSNumber numberWithInt:delta]};
      if(gained) [((NSMutableArray *)deltas[@"added"]) addObject:d];
      if(lost)   [((NSMutableArray *)deltas[@"lost"]) addObject:d];
    }
    
    if(player)
    {
        if(((NSArray *)deltas[@"added"]).count > 0) 
            _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_PLAYER_GAINED",nil,deltas);
        if(((NSArray *)deltas[@"lost"]).count  > 0) _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_PLAYER_LOST",  nil,deltas);
        _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_PLAYER_AVAILABLE",nil,deltas);
        _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);
    }
    else
    {
        if(((NSArray *)deltas[@"added"]).count > 0) _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_GAINED",nil,deltas);
        if(((NSArray *)deltas[@"lost"]).count  > 0) _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_LOST",  nil,deltas);
        _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_AVAILABLE",nil,deltas);
        _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
    }
}

- (void) requestInstances       { [_SERVICES_ fetchInstances];   }
- (void) requestInstance:(int)i { [_SERVICES_ fetchInstanceById:i];   }
- (void) requestPlayerInstances { [_SERVICES_ fetchInstancesForPlayer]; }

// null instance (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Instance *) instanceForId:(int)instance_id
{
  if(!instance_id) return [[Instance alloc] init];
  Instance *i = [instances objectForKey:[NSNumber numberWithInt:instance_id]];
  if(!i)
  {
    [blacklist setObject:@"true" forKey:[NSNumber numberWithInt:instance_id]];
    [self requestInstance:instance_id];
    return [[Instance alloc] init];
  }
  return i;
}

- (NSArray *) instancesForType:(NSString *)object_type id:(int)object_id
{
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for(int i = 0; i < instances.count; i++)
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
    for(int i = 0; i < allInstances.count; i++)
    {
        if(((Instance *)allInstances[i]).owner_id == _MODEL_PLAYER_.user_id) 
            [pInstances addObject:allInstances[i]];
    }
    return pInstances;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

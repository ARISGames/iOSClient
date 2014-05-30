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
}
@end

@implementation InstancesModel

- (id) init
{
    if(self = [super init])
    {
        [self clearPlayerData];
        
        _ARIS_NOTIF_LISTEN_(@"SERVICES_INSTANCES_RECEIVED",self,@selector(instancesReceived:),nil);
        _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_INSTANCES_RECEIVED",self,@selector(instancesReceived:),nil); 
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
    instances = [[NSMutableDictionary alloc] init]; 
}

- (void) instancesReceived:(NSNotification *)notif
{
    [self updateInstances:[notif.userInfo objectForKey:@"instances"]];
}

- (void) updateInstances:(NSArray *)newInstances
{
    Instance *newInstance;
    NSNumber *newInstanceId;
    for(int i = 0; i < newInstances.count; i++)
    {
      newInstance = [newInstances objectAtIndex:i];
      newInstanceId = [NSNumber numberWithInt:newInstance.instance_id];
      if(![instances objectForKey:newInstanceId]) [instances setObject:newInstance forKey:newInstanceId];
      else [[instances objectForKey:newInstanceId] mergeDataFromInstance:newInstance];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_INSTANCES_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_RECEIVED",nil,nil);
}

- (void) requestGameInstances   { [_SERVICES_ fetchInstancesForGame];   }
- (void) requestPlayerInstances { [_SERVICES_ fetchInstancesForPlayer]; }

- (Instance *) instanceForId:(int)instance_id
{
  return [instances objectForKey:[NSNumber numberWithInt:instance_id]];
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

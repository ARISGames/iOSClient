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

@interface TriggersModel()
{
    NSMutableDictionary *triggers;
    NSArray *playerTriggers;
}
@end

@implementation TriggersModel

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];

        _ARIS_NOTIF_LISTEN_(@"SERVICES_TRIGGERS_RECEIVED",self,@selector(triggersReceived:),nil);
        _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_TRIGGERS_RECEIVED",self,@selector(playerTriggersReceived:),nil);
    }
    return self;
}

- (void) clearPlayerData
{
    playerTriggers = [[NSArray alloc] init];
}

- (void) clearGameData
{
    [self clearPlayerData];
    triggers = [[NSMutableDictionary alloc] init];
}

- (void) triggersReceived:(NSNotification *)notif
{
    [self updateTriggers:notif.userInfo[@"triggers"]];
}

- (void) updateTriggers:(NSArray *)newTriggers
{
    Trigger *newTrigger;
    NSNumber *newTriggerId;
    for(int i = 0; i < newTriggers.count; i++)
    {
      newTrigger = [newTriggers objectAtIndex:i];
      newTriggerId = [NSNumber numberWithInt:newTrigger.trigger_id];
      if(![triggers objectForKey:newTriggerId])
        [triggers setObject:newTrigger forKey:newTriggerId];
      else
        [[triggers objectForKey:newTriggerId] mergeDataFromTrigger:newTrigger];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_TRIGGERS_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (NSArray *) conformTriggersListToFlyweight:(NSArray *)newTriggers
{
    NSMutableArray *conformingTriggers = [[NSMutableArray alloc] init];
    for(int i = 0; i < newTriggers.count; i++)
        [conformingTriggers addObject:[self triggerForId:((Trigger *)newTriggers[i]).trigger_id]];
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
    for(int i = 0; i < newTriggers.count; i++)
    {
        new = YES;
        newTrigger = newTriggers[i];
        for(int j = 0; j < playerTriggers.count; j++)
        {
            oldTrigger = playerTriggers[j];
            if(newTrigger.trigger_id == oldTrigger.trigger_id) new = NO;
        }
        if(new) [addedTriggers addObject:newTriggers[i]];
    }

    //find removed
    BOOL removed;
    for(int i = 0; i < playerTriggers.count; i++)
    {
        removed = YES;
        oldTrigger = playerTriggers[i];
        for(int j = 0; j < newTriggers.count; j++)
        {
            newTrigger = newTriggers[j];
            if(newTrigger.trigger_id == oldTrigger.trigger_id) removed = NO;
        }
        if(removed) [removedTriggers addObject:playerTriggers[i]];
    }

    playerTriggers = newTriggers;
    if(addedTriggers.count > 0)   _ARIS_NOTIF_SEND_(@"MODEL_TRIGGERS_NEW_AVAILABLE",nil,@{@"added":addedTriggers});
    if(removedTriggers.count > 0) _ARIS_NOTIF_SEND_(@"MODEL_TRIGGERS_LESS_AVAILABLE",nil,@{@"removed":removedTriggers});
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (void) requestTriggers       { [_SERVICES_ fetchTriggers];   }
- (void) requestPlayerTriggers { [_SERVICES_ fetchTriggersForPlayer]; }

- (Trigger *) triggerForId:(int)trigger_id
{
  return [triggers objectForKey:[NSNumber numberWithInt:trigger_id]];
}

- (NSArray *) playerTriggers
{
  return playerTriggers;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


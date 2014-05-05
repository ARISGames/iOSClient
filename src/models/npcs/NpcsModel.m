//
//  NpcsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c, 
// we can't know what data we're invalidating by replacing a ptr

#import "NpcsModel.h"

@interface NpcsModel()
{
    NSMutableDictionary *npcs;
}

@end

@implementation NpcsModel

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameNpcsReceived:) name:@"GameNpcsReceived" object:nil];
    }
    return self;
}

- (void) clearGameData
{
    npcs = [[NSMutableDictionary alloc] init];
}

- (void) gameNpcsReceived:(NSNotification *)notif
{
    [self updateNpcs:[notif.userInfo objectForKey:@"npcs"]];
}

- (void) updateNpcs:(NSArray *)newNpcs
{
    Npc *newNpc;
    NSNumber *newNpcId;
    for(int i = 0; i < [newNpcs count]; i++)
    {
      newNpc = [newNpcs objectAtIndex:i];
      newNpcId = [NSNumber numberWithInt:newNpc.npc_id];
      if(![npcs objectForKey:newNpcId]) [npcs setObject:newNpc forKey:newNpcId];
    }
}

- (Npc *) npcForId:(int)npc_id
{
  return [npcs objectForKey:[NSNumber numberWithInt:npc_id]];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

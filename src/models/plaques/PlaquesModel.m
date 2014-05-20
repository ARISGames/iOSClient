//
//  PlaquesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c, 
// we can't know what data we're invalidating by replacing a ptr

#import "PlaquesModel.h"

@interface PlaquesModel()
{
    NSMutableDictionary *plaques;
}

@end

@implementation PlaquesModel

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
  _ARIS_NOTIF_LISTEN_(@"GamePlaquesReceived",self,@selector(gamePlaquesReceived:),nil);
    }
    return self;
}

- (void) clearGameData
{
    plaques = [[NSMutableDictionary alloc] init];
}

- (void) gamePlaquesReceived:(NSNotification *)notif
{
    [self updatePlaques:[notif.userInfo objectForKey:@"plaques"]];
}

- (void) updatePlaques:(NSArray *)newPlaques
{
    Plaque *newPlaque;
    NSNumber *newPlaqueId;
    for(int i = 0; i < newPlaques.count; i++)
    {
      newPlaque = [newPlaques objectAtIndex:i];
      newPlaqueId = [NSNumber numberWithInt:newPlaque.plaque_id];
      if(![plaques objectForKey:newPlaqueId]) [plaques setObject:newPlaque forKey:newPlaqueId];
    }
}

- (Plaque *) plaqueForId:(int)plaque_id
{
  return [plaques objectForKey:[NSNumber numberWithInt:plaque_id]];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

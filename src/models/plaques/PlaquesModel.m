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
#import "AppServices.h"

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
        _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAQUES_RECEIVED",self,@selector(plaquesReceived:),nil);
    }
    return self;
}

- (void) clearGameData
{
    plaques = [[NSMutableDictionary alloc] init];
}

- (void) plaquesReceived:(NSNotification *)notif
{
    [self updatePlaques:notif.userInfo[@"plaques"]];
}

- (void) updatePlaques:(NSArray *)newPlaques
{
    Plaque *newPlaque;
    NSNumber *newPlaqueId;
    for(int i = 0; i < newPlaques.count; i++)
    {
      newPlaque = [newPlaques objectAtIndex:i];
      newPlaqueId = [NSNumber numberWithInt:newPlaque.plaque_id];
      if(!plaques[newPlaqueId]) [plaques setObject:newPlaque forKey:newPlaqueId];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_PLAQUES_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestPlaques
{
    [_SERVICES_ fetchPlaques];
}

// null plaque (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Plaque *) plaqueForId:(int)plaque_id
{
  if(!plaque_id) return [[Plaque alloc] init];
  return plaques[[NSNumber numberWithInt:plaque_id]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

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
#import "SBJson.h"

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

- (void) requestGameData
{
  [self requestPlaques];
}
- (void) clearGameData
{
    plaques = [[NSMutableDictionary alloc] init];
    n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) plaquesReceived:(NSNotification *)notif
{
    [self updatePlaques:notif.userInfo[@"plaques"]];
}

- (void) updatePlaques:(NSArray *)newPlaques
{
    Plaque *newPlaque;
    NSNumber *newPlaqueId;
    for(long i = 0; i < newPlaques.count; i++)
    {
      newPlaque = [newPlaques objectAtIndex:i];
      newPlaqueId = [NSNumber numberWithLong:newPlaque.plaque_id];
      if(!plaques[newPlaqueId]) [plaques setObject:newPlaque forKey:newPlaqueId];
    }
    n_game_data_received++;
    _ARIS_NOTIF_SEND_(@"MODEL_PLAQUES_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestPlaques
{
    [_SERVICES_ fetchPlaques];
}

// null plaque (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Plaque *) plaqueForId:(long)plaque_id
{
  if(!plaque_id) return [[Plaque alloc] init];
  return plaques[[NSNumber numberWithLong:plaque_id]];
}

- (NSString *) serializedName
{
  return @"plaques";
}

- (NSString *) serializeGameData
{
  NSArray *plaques_a = [plaques allValues];
  Plaque *p_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"plaques\":["];
  for(long i = 0; i < plaques_a.count; i++)
  {
    p_o = plaques_a[i];
    [r appendString:[p_o serialize]];
    if(i != plaques_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_plaques = d_data[@"plaques"];
  for(long i = 0; i < d_plaques.count; i++)
  {
    Plaque *p = [[Plaque alloc] initWithDictionary:d_plaques[i]];
    [plaques setObject:p forKey:[NSNumber numberWithLong:p.plaque_id]];
  }
  n_game_data_received = [self nGameDataToReceive];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

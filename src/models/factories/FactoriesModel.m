//
//  FactoriesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "FactoriesModel.h"
#import "AppServices.h"
#import "SBJson.h"

@interface FactoriesModel()
{
  NSMutableDictionary *factories;
}

@end

@implementation FactoriesModel

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_FACTORIES_RECEIVED",self,@selector(factoriesReceived:),nil);
  }
  return self;
}

- (void) requestGameData
{
  [self requestFactories];
}
- (void) clearGameData
{
  factories = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) factoriesReceived:(NSNotification *)notif
{
  [self updateFactories:notif.userInfo[@"factories"]];
}

- (void) updateFactories:(NSArray *)newFactories
{
  Factory *newFactory;
  NSNumber *newFactoryId;
  for(long i = 0; i < newFactories.count; i++)
  {
    newFactory = [newFactories objectAtIndex:i];
    newFactoryId = [NSNumber numberWithLong:newFactory.factory_id];
    if(!factories[newFactoryId]) [factories setObject:newFactory forKey:newFactoryId];
  }
  _ARIS_NOTIF_SEND_(@"MODEL_FACTORIES_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
  n_game_data_received = 1;
}

- (void) requestFactories
{
  [_SERVICES_ fetchFactories];
}

// null factory (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Factory *) factoryForId:(long)factory_id
{
  if(!factory_id) return [[Factory alloc] init];
  return factories[[NSNumber numberWithLong:factory_id]];
}

- (NSString *) serializedName
{
  return @"factories";
}

- (NSString *) serializeGameData
{
  NSArray *factories_a = [factories allValues];
  Factory *f_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"factories\":["];
  for(long i = 0; i < factories_a.count; i++)
  {
    f_o = factories_a[i];
    [r appendString:[f_o serialize]];
    if(i != factories_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_factories = d_data[@"factories"];
  for(long i = 0; i < d_factories.count; i++)
  {
    Factory *f = [[Factory alloc] initWithDictionary:d_factories[i]];
    [factories setObject:f forKey:[NSNumber numberWithLong:f.factory_id]];
  }
}

- (NSString *) serializePlayerData
{
  return @"";
}

- (void) deserializePlayerData:(NSString *)data
{

}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


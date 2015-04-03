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

- (void) clearGameData
{
    factories = [[NSMutableDictionary alloc] init];
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

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


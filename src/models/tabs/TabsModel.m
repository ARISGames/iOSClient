//
//  TabsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "TabsModel.h"
#import "AppModel.h"
#import "AppServices.h"
#import "SBJson.h"

@interface TabsModel()
{
  NSMutableDictionary *tabs;
  NSArray *playerTabs;
}

@end

@implementation TabsModel

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_TABS_RECEIVED",self,@selector(tabsReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_TABS_RECEIVED",self,@selector(playerTabsReceived:),nil);
  }
  return self;
}

- (void) requestPlayerData
{
  [self requestPlayerTabs];
}
- (void) clearPlayerData
{
  playerTabs = [[NSArray alloc] init];
  n_player_data_received = 0;
}
- (long) nPlayerDataToReceive
{
  return 1;
}

- (void) requestGameData
{
  [self requestTabs];
}
- (void) clearGameData
{
  [self clearPlayerData];
  tabs = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) tabsReceived:(NSNotification *)notif
{
  [self updateTabs:[notif.userInfo objectForKey:@"tabs"]];
}

- (void) updateTabs:(NSArray *)newTabs
{
  Tab *newTab;
  NSNumber *newTabId;
  for(long i = 0; i < newTabs.count; i++)
  {
    newTab = [newTabs objectAtIndex:i];
    newTabId = [NSNumber numberWithLong:newTab.tab_id];
    if(![tabs objectForKey:newTabId]) [tabs setObject:newTab forKey:newTabId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_TABS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestTabs       { [_SERVICES_ fetchTabs]; }

- (void) requestPlayerTabs
{
  if([self playerDataReceived] &&
     ![_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
  {
    NSMutableArray *ptabs = [[NSMutableArray alloc] init];
    NSArray *ts = [tabs allValues];
    for(int i = 0; i < ts.count; i++)
    {
      Tab *t = ts[i];
      if([_MODEL_REQUIREMENTS_ evaluateRequirementRoot:t.requirement_root_package_id])
        [ptabs addObject:t];
    }
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_TABS_RECEIVED",nil,@{@"tabs":ptabs});
  }
  if(![self playerDataReceived] ||
     [_MODEL_GAME_.network_level isEqualToString:@"HYBRID"] ||
     [_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
    [_SERVICES_ fetchTabsForPlayer];
}

//admittedly a bit silly, but a great way to rid any risk of deviation from flyweight by catching it at the beginning
- (NSArray *) conformTabListToFlyweight:(NSArray *)newTabs
{
  NSMutableArray *conformingTabs = [[NSMutableArray alloc] init];
  Tab *t;
  for(long i = 0; i < newTabs.count; i++)
  {
    if((t = [self tabForId:((Tab *)newTabs[i]).tab_id]))
      [conformingTabs addObject:t];
  }

  return conformingTabs;
}

- (void) playerTabsReceived:(NSNotification *)notification
{
  [self updatePlayerTabs:[self conformTabListToFlyweight:[notification.userInfo objectForKey:@"tabs"]]];
}

- (void) updatePlayerTabs:(NSArray *)newTabs
{
  NSDictionary *deltas = [self findDeltasInNew:newTabs fromOld:playerTabs];
  playerTabs = newTabs; //assumes already conforms to flyweight
  n_player_data_received++;
  if(((NSArray *)deltas[@"added"]).count > 0)
    _ARIS_NOTIF_SEND_(@"MODEL_TABS_NEW_AVAILABLE",nil,deltas);
  if(((NSArray *)deltas[@"removed"]).count > 0)
    _ARIS_NOTIF_SEND_(@"MODEL_TABS_LESS_AVAILABLE",nil,deltas);
  _ARIS_NOTIF_SEND_(@"PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (NSDictionary *) findDeltasInNew:(NSArray *)newTabs fromOld:(NSArray *)oldTabs
{
  NSDictionary *qDeltas = @{ @"added":[[NSMutableArray alloc] init], @"removed":[[NSMutableArray alloc] init] };

  //placeholders for comparison
  Tab *newTab;
  Tab *oldTab;

  //find added
  BOOL new;
  for(long i = 0; i < newTabs.count; i++)
  {
    new = YES;
    newTab = newTabs[i];
    for(long j = 0; j < oldTabs.count; j++)
    {
      oldTab = oldTabs[j];
      if(newTab.tab_id == oldTab.tab_id) new = NO;
    }
    if(new) [qDeltas[@"added"] addObject:newTabs[i]];
  }

  //find removed
  BOOL removed;
  for(long i = 0; i < oldTabs.count; i++)
  {
    removed = YES;
    oldTab = oldTabs[i];
    for(long j = 0; j < newTabs.count; j++)
    {
      newTab = newTabs[j];
      if(newTab.tab_id == oldTab.tab_id) removed = NO;
    }
    if(removed) [qDeltas[@"removed"] addObject:oldTabs[i]];
  }

  return qDeltas;
}

- (Tab *) tabForType:(NSString *)t
{
  Tab *tab;

  //first, search player tabs
  for(long i = 0; i < playerTabs.count; i++)
  {
    if([((Tab *)playerTabs[i]).type isEqualToString:t])
      tab = playerTabs[i];
  }
  if(tab) return tab;

  //if not found, try to get any game tab
  NSArray *gameTabs = [tabs allValues];
  for(long i = 0; i < gameTabs.count; i++)
  {
    if([((Tab *)gameTabs[i]).type isEqualToString:t])
      tab = gameTabs[i];
  }
  return tab;
}

- (Tab *) tabForId:(long)tab_id
{
  if(!tab_id) return [[Tab alloc] init];
  return [tabs objectForKey:[NSNumber numberWithLong:tab_id]];
}

- (NSArray *) playerTabs
{
  return playerTabs;
}

- (NSString *) serializedName
{
  return @"tabs";
}

- (NSString *) serializeGameData
{
  NSArray *tabs_a = [tabs allValues];
  Tab *t_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"tabs\":["];
  for(long i = 0; i < tabs_a.count; i++)
  {
    t_o = tabs_a[i];
    [r appendString:[t_o serialize]];
    if(i != tabs_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_tabs = d_data[@"tabs"];
  for(long i = 0; i < d_tabs.count; i++)
  {
    Tab *t = [[Tab alloc] initWithDictionary:d_tabs[i]];
    [tabs setObject:t forKey:[NSNumber numberWithLong:t.tab_id]];
  }
  n_game_data_received = [self nGameDataToReceive];
}

- (NSString *) serializePlayerData
{
  NSArray *tabs_a = playerTabs;
  Tab *t_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"tabs\":["];
  for(long i = 0; i < tabs_a.count; i++)
  {
    t_o = tabs_a[i];
    [r appendString:[t_o serialize]];
    if(i != tabs_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializePlayerData:(NSString *)data
{
  [self clearPlayerData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_tabs = d_data[@"tabs"];
  NSMutableArray *pts = [[NSMutableArray alloc] init];
  for(long i = 0; i < d_tabs.count; i++)
  {
    Tab *t = [[Tab alloc] initWithDictionary:d_tabs[i]];
    [pts addObject:[_MODEL_TABS_ tabForId:t.tab_id]];
  }
  playerTabs = pts;
  
  n_player_data_received = [self nPlayerDataToReceive];
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


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
#import "AppServices.h"

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

- (void) clearPlayerData
{
    playerTabs = [[NSArray alloc] init];
}

- (void) clearGameData
{
    [self clearPlayerData];
    tabs = [[NSMutableDictionary alloc] init];
}

- (void) tabsReceived:(NSNotification *)notif
{
    [self updateTabs:[notif.userInfo objectForKey:@"tabs"]];
}

- (void) updateTabs:(NSArray *)newTabs
{
    Tab *newTab;
    NSNumber *newTabId;
    for(int i = 0; i < newTabs.count; i++)
    {
      newTab = [newTabs objectAtIndex:i];
      newTabId = [NSNumber numberWithInt:newTab.tab_id];
      if(![tabs objectForKey:newTabId]) [tabs setObject:newTab forKey:newTabId];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_TABS_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestTabs       { [_SERVICES_ fetchTabs]; }
- (void) requestPlayerTabs { [_SERVICES_ fetchTabsForPlayer]; }

//admittedly a bit silly, but a great way to rid any risk of deviation from flyweight by catching it at the beginning
- (NSArray *) conformTabListToFlyweight:(NSArray *)newTabs
{
    NSMutableArray *conformingTabs = [[NSMutableArray alloc] init];
    for(int i = 0; i < newTabs.count; i++)
        [conformingTabs addObject:[self tabForId:((Tab *)newTabs[i]).tab_id]];

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
    if(((NSArray *)deltas[@"added"]).count > 0)
        _ARIS_NOTIF_SEND_(@"MODEL_TABS_NEW_AVAILABLE",nil,deltas);
    if(((NSArray *)deltas[@"removed"]).count > 0)
        _ARIS_NOTIF_SEND_(@"MODEL_TABS_LESS_AVAILABLE",nil,deltas); 
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);  
}

- (NSDictionary *) findDeltasInNew:(NSArray *)newTabs fromOld:(NSArray *)oldTabs
{
    NSDictionary *qDeltas = @{ @"added":[[NSMutableArray alloc] init], @"removed":[[NSMutableArray alloc] init] };

    //placeholders for comparison
    Tab *newTab;
    Tab *oldTab;  

    //find added
    BOOL new;
    for(int i = 0; i < newTabs.count; i++)
    {
        new = YES;
        newTab = newTabs[i];
        for(int j = 0; j < oldTabs.count; j++)
        {
            oldTab = oldTabs[j];
            if(newTab.tab_id == oldTab.tab_id) new = NO;
        }
        if(new) [qDeltas[@"added"] addObject:newTabs[i]];
    }

    //find removed
    BOOL removed;
    for(int i = 0; i < oldTabs.count; i++)
    {
        removed = YES;
        oldTab = oldTabs[i];
        for(int j = 0; j < newTabs.count; j++)
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
    for(int i = 0; i < tabs.count; i++)
    {
        if([((Tab *)playerTabs[i]).type isEqualToString:t])
            tab = playerTabs[i];
    }
    return tab;
}

- (Tab *) tabForId:(int)tab_id
{
  if(!tab_id) return [[Tab alloc] init];
  return [tabs objectForKey:[NSNumber numberWithInt:tab_id]];
}

- (NSArray *) playerTabs
{
    return playerTabs;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);               
}

@end

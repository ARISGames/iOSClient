//
//  GamesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c, 
// we can't know what data we're invalidating by replacing a ptr

#import "GamesModel.h"
#import "AppModel.h"
#import "AppServices.h"

@interface GamesModel()
{
  NSMutableDictionary *games;
  NSArray *nearbyGames;   NSDate *nearbyStamp; CLLocation *location;
  NSArray *anywhereGames; NSDate *anywhereStamp;
  NSArray *popularGames;  NSDate *popularStamp;
  NSArray *recentGames;   NSDate *recentStamp;
  NSArray *searchGames;   NSDate *searchStamp; NSString *search;
}

@end

@implementation GamesModel

- (id) init
{
  if(self = [super init])
  {
    [self clearData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_NEARBY_GAMES_RECEIVED",self,@selector(nearbyGamesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_ANYWHERE_GAMES_RECEIVED",self,@selector(anywhereGamesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_POPULAR_GAMES_RECEIVED",self,@selector(popularGamesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_RECENT_GAMES_RECEIVED",self,@selector(recentGamesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_SEARCH_GAMES_RECEIVED",self,@selector(searchGamesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_GAME_RECEIVED",self,@selector(gameReceived:),nil);
  }
  return self;
}

- (void) clearData
{
  [self invalidateData];
    
  games = [[NSMutableDictionary alloc] init];
    
  nearbyGames   = [[NSArray alloc] init];
  anywhereGames = [[NSArray alloc] init];
  popularGames  = [[NSArray alloc] init];
  recentGames   = [[NSArray alloc] init];
  searchGames   = [[NSArray alloc] init];
}

- (void) invalidateData
{
  nearbyStamp = nil; location = nil;
  anywhereStamp = nil;
  popularStamp = nil;
  recentStamp = nil;
  searchStamp = nil; search = nil; 
}

- (void) nearbyGamesReceived:(NSNotification *)n { [self updateNearbyGames:n.userInfo[@"games"]]; }
- (void) updateNearbyGames:(NSArray *)gs
{
  nearbyGames = [self updateGames:gs];
  _ARIS_NOTIF_SEND_(@"MODEL_NEARBY_GAMES_AVAILABLE",nil,nil); 
}

- (void) anywhereGamesReceived:(NSNotification *)n { [self updateAnywhereGames:n.userInfo[@"games"]]; }
- (void) updateAnywhereGames:(NSArray *)gs
{
  anywhereGames = [self updateGames:gs]; 
  _ARIS_NOTIF_SEND_(@"MODEL_ANYWHERE_GAMES_AVAILABLE",nil,nil);  
}

- (void) popularGamesReceived:(NSNotification *)n { [self updatePopularGames:n.userInfo[@"games"]]; }
- (void) updatePopularGames:(NSArray *)gs
{
  popularGames = [self updateGames:gs];  
  _ARIS_NOTIF_SEND_(@"MODEL_POPULAR_GAMES_AVAILABLE",nil,nil);   
}

- (void) recentGamesReceived:(NSNotification *)n { [self updateRecentGames:n.userInfo[@"games"]]; }
- (void) updateRecentGames:(NSArray *)gs
{
  recentGames = [self updateGames:gs];   
  _ARIS_NOTIF_SEND_(@"MODEL_RECENT_GAMES_AVAILABLE",nil,nil);    
}

- (void) searchGamesReceived:(NSNotification *)n { [self updateSearchGames:n.userInfo[@"games"]]; }
- (void) updateSearchGames:(NSArray *)gs
{
  searchGames = [self updateGames:gs];    
  _ARIS_NOTIF_SEND_(@"MODEL_SEARCH_GAMES_AVAILABLE",nil,nil);     
}

- (void) gameReceived:(NSNotification *)n { [self updateGame:n.userInfo[@"game"]]; }
- (Game *) updateGame:(Game *)g
{
  Game *existingG;
  if((existingG = [self gameForId:g.game_id])) [existingG mergeDataFromGame:g];
  else games[[NSNumber numberWithInt:g.game_id]] = g;
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_AVAILABLE",nil,@{@"game":[self gameForId:g.game_id]});      
    
  return games[[NSNumber numberWithInt:g.game_id]];
}

- (NSArray *) updateGames:(NSArray *)newGames
{
  NSMutableArray *mergedNewGames = [[NSMutableArray alloc] initWithCapacity:newGames.count];
  for(int i = 0; i < newGames.count; i++)
    [mergedNewGames addObject:[self updateGame:newGames[i]]];
  return mergedNewGames;
}

- (Game *) gameForId:(int)game_id
{
  return [games objectForKey:[NSNumber numberWithInt:game_id]];
}
- (void) requestGame:(int)game_id
{
    [_SERVICES_ fetchGame:game_id];
}
- (void) requestGameData:(int)game_id
{
    [_SERVICES_ fetchGame:game_id];
}

- (NSArray *) nearbyGames
{
    if(!nearbyStamp || [nearbyStamp timeIntervalSinceNow] > 120 ||
       (_MODEL_PLAYER_.location && (!location || 
        location.coordinate.latitude  != _MODEL_PLAYER_.location.coordinate.latitude || 
        location.coordinate.longitude != _MODEL_PLAYER_.location.coordinate.longitude
        )
       ))
    {
        nearbyStamp = [[NSDate alloc] init];
        location = [_MODEL_PLAYER_.location copy];
        [_SERVICES_ fetchNearbyGameList];  
    }
    
    return nearbyGames;
}

- (NSArray *) anywhereGames
{
    if(!anywhereStamp || [anywhereStamp timeIntervalSinceNow] > 120)
    {
        anywhereStamp = [[NSDate alloc] init]; 
        [_SERVICES_ fetchAnywhereGameList];   
    }
        
    return anywhereGames; 
}

- (NSArray *) popularGames
{
    if(!popularStamp || [popularStamp timeIntervalSinceNow] > 120) 
    {
        popularStamp = [[NSDate alloc] init]; 
        [_SERVICES_ fetchPopularGameList];    
    } 
        
    return popularGames;  
}

- (NSArray *) recentGames
{
    if(!recentStamp || [recentStamp timeIntervalSinceNow] > 120) 
    {
        recentStamp = [[NSDate alloc] init]; 
        [_SERVICES_ fetchRecentGameList];     
    }  
    
    return recentGames;   
}

- (NSArray *) searchGames:(NSString *)s
{
    if(!searchStamp || [searchStamp timeIntervalSinceNow] > 120 ||
       ![search isEqualToString:s]) 
    {
        searchStamp = [[NSDate alloc] init]; 
        search = s;
        [_SERVICES_ fetchSearchGameList:s];      
    }   
    
    return searchGames;    
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

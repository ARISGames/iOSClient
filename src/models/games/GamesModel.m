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

@interface GamesModel()
{
  NSMutableDictionary *games;
  NSMutableArray *nearbyGames;
  NSMutableArray *anywhereGames;
  NSMutableArray *popularGames;
  NSMutableArray *recentGames;
  NSMutableArray *searchGames; NSString *search;
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
  games = [[NSMutableDictionary alloc] init];
  nearbyGames   = [[NSMutableArray alloc] init];
  anywhereGames = [[NSMutableArray alloc] init];
  popularGames  = [[NSMutableArray alloc] init];
  recentGames   = [[NSMutableArray alloc] init];
  searchGames   = [[NSMutableArray alloc] init]; search = @"";
}

- (void) nearbyGamesReceived:(NSNotification *)n { [self updateNearbyGames:n.userInfo[@"games"]]; }
- (void) updateNearbyGames:(NSArray *)gs
{
  nearbyGames = [[NSMutableArray alloc] init];
  for(int i = 0; i < [gs count]; i++)
  {
    [self updateGame:gs[i]];
    [nearbyGames addObject:[self gameForId:((Game *)gs[i]).game_id]]; 
  }
}

- (void) anywhereGamesReceived:(NSNotification *)n { [self updateAnywhereGames:n.userInfo[@"games"]]; }
- (void) updateAnywhereGames:(NSArray *)gs
{
  anywhereGames = [[NSMutableArray alloc] init];
  for(int i = 0; i < [gs count]; i++)
  {
    [self updateGame:gs[i]];
    [anywhereGames addObject:[self gameForId:((Game *)gs[i]).game_id]]; 
  }
}

- (void) popularGamesReceived:(NSNotification *)n { [self updatePopularGames:n.userInfo[@"games"]]; }
- (void) updatePopularGames:(NSArray *)gs
{
  popularGames = [[NSMutableArray alloc] init];
  for(int i = 0; i < [gs count]; i++)
  {
    [self updateGame:gs[i]];
    [popularGames addObject:[self gameForId:((Game *)gs[i]).game_id]]; 
  }
}

- (void) recentGamesReceived:(NSNotification *)n { [self updateRecentGames:n.userInfo[@"games"]]; }
- (void) updateRecentGames:(NSArray *)gs
{
  recentGames = [[NSMutableArray alloc] init];
  for(int i = 0; i < [gs count]; i++)
  {
    [self updateGame:gs[i]];
    [recentGames addObject:[self gameForId:((Game *)gs[i]).game_id]]; 
  }
}

- (void) searchGamesReceived:(NSNotification *)n { [self updateSearchGames:n.userInfo[@"games"]]; }
- (void) updateSearchGames:(NSArray *)gs
{
  searchGames = [[NSMutableArray alloc] init];
  for(int i = 0; i < [gs count]; i++)
  {
    [self updateGame:gs[i]];
    [searchGames addObject:[self gameForId:((Game *)gs[i]).game_id]]; 
  }
}

- (void) gameReceived:(NSNotification *)n { [self updateGame:n.userInfo[@"game"]]; }
- (void) updateGame:(Game *)g
{
  Game *existingG;
  if((existingG = [self gameForId:g.game_id])) [existingG mergeDataFromGame:g];
  else games[[NSNumber numberWithInt:g.game_id]] = g;
}

- (void) updateGames:(NSArray *)newGames
{
  Game *newGame;
  NSNumber *newGameId;
  for(int i = 0; i < [newGames count]; i++)
  {
    newGame = [newGames objectAtIndex:i];
    newGameId = [NSNumber numberWithInt:newGame.game_id];
    if(![games objectForKey:newGameId]) [games setObject:newGame forKey:newGameId];
  }
}

- (Game *) gameForId:(int)game_id
{
  return [games objectForKey:[NSNumber numberWithInt:game_id]];
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

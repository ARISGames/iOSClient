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
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "AppServices.h"
#import "SBJson.h"

@interface GamesModel()
{
  NSMutableDictionary *games;
  NSArray *nearbyGames;     NSDate *nearbyStamp; CLLocation *location;
  NSArray *anywhereGames;   NSDate *anywhereStamp;
  NSArray *popularGames;    NSDate *popularStamp; NSString *interval;
  NSArray *recentGames;     NSDate *recentStamp;
  NSArray *searchGames;     NSDate *searchStamp; NSString *search;
  NSArray *mineGames;       NSDate *mineStamp;
  NSArray *downloadedGames; NSDate *downloadedStamp;
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
    _ARIS_NOTIF_LISTEN_(@"SERVICES_MINE_GAMES_RECEIVED",self,@selector(mineGamesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_DOWNLOADED_GAMES_RECEIVED",self,@selector(downloadedGamesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_GAME_RECEIVED",self,@selector(gameReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_PLAYED_GAME_RECEIVED",self,@selector(playerPlayedGameReceived:),nil);
  }
  return self;
}

- (void) clearData
{
  [self invalidateData];

  games = [[NSMutableDictionary alloc] init];

  nearbyGames     = [[NSArray alloc] init];
  anywhereGames   = [[NSArray alloc] init];
  popularGames    = [[NSArray alloc] init];
  recentGames     = [[NSArray alloc] init];
  searchGames     = [[NSArray alloc] init];
  mineGames       = [[NSArray alloc] init];
  downloadedGames = [[NSArray alloc] init];
}

- (void) invalidateData
{
  nearbyStamp = nil; location = nil;
  anywhereStamp = nil;
  popularStamp = nil; interval = nil;
  recentStamp = nil;
  searchStamp = nil; search = nil;
  mineStamp = nil;
  downloadedStamp = nil;
}

- (void) mergeInGame:(Game *)g { [self updateGames:@[g]]; }

- (void) nearbyGamesReceived:(NSNotification *)n { [self updateNearbyGames:n.userInfo[@"games"]]; }
- (void) updateNearbyGames:(NSArray *)gs { nearbyGames = [self updateGames:gs]; [self notifNearbyGames]; }
- (void) notifNearbyGames { _ARIS_NOTIF_SEND_(@"MODEL_NEARBY_GAMES_AVAILABLE",nil,nil); }

- (void) anywhereGamesReceived:(NSNotification *)n { [self updateAnywhereGames:n.userInfo[@"games"]]; }
- (void) updateAnywhereGames:(NSArray *)gs { anywhereGames = [self updateGames:gs]; [self notifAnywhereGames]; }
- (void) notifAnywhereGames { _ARIS_NOTIF_SEND_(@"MODEL_ANYWHERE_GAMES_AVAILABLE",nil,nil); }

- (void) popularGamesReceived:(NSNotification *)n { [self updatePopularGames:n.userInfo[@"games"]]; }
- (void) updatePopularGames:(NSArray *)gs { popularGames = [self updateGames:gs]; [self notifPopularGames]; }
- (void) notifPopularGames { _ARIS_NOTIF_SEND_(@"MODEL_POPULAR_GAMES_AVAILABLE",nil,nil); }

- (void) recentGamesReceived:(NSNotification *)n { [self updateRecentGames:n.userInfo[@"games"]]; }
- (void) updateRecentGames:(NSArray *)gs { recentGames = [self updateGames:gs]; [self notifRecentGames]; }
- (void) notifRecentGames { _ARIS_NOTIF_SEND_(@"MODEL_RECENT_GAMES_AVAILABLE",nil,nil); }

- (void) searchGamesReceived:(NSNotification *)n { [self updateSearchGames:n.userInfo[@"games"]]; }
- (void) updateSearchGames:(NSArray *)gs { searchGames = [self updateGames:gs]; [self notifSearchGames]; }
- (void) notifSearchGames { _ARIS_NOTIF_SEND_(@"MODEL_SEARCH_GAMES_AVAILABLE",nil,nil); }

- (void) mineGamesReceived:(NSNotification *)n { [self updateMineGames:n.userInfo[@"games"]]; }
- (void) updateMineGames:(NSArray *)gs { mineGames = [self updateGames:gs]; [self notifMineGames]; }
- (void) notifMineGames { _ARIS_NOTIF_SEND_(@"MODEL_MINE_GAMES_AVAILABLE",nil,nil); }

- (void) downloadedGamesReceived:(NSNotification *)n { [self updateDownloadedGames:n.userInfo[@"games"]]; }
- (void) updateDownloadedGames:(NSArray *)gs { downloadedGames = [self updateGames:gs]; [self notifDownloadedGames]; }
- (void) notifDownloadedGames { _ARIS_NOTIF_SEND_(@"MODEL_DOWNLOADED_GAMES_AVAILABLE",nil,nil); }

- (void) gameReceived:(NSNotification *)n { [self updateGame:n.userInfo[@"game"]]; }
- (Game *) updateGame:(Game *)g
{
  Game *existingG;
  if((existingG = [self gameForId:g.game_id])) [existingG mergeDataFromGame:g];
  else games[[NSNumber numberWithLong:g.game_id]] = g;
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_AVAILABLE",nil,@{@"game":[self gameForId:g.game_id]});

  return games[[NSNumber numberWithLong:g.game_id]];
}

- (NSArray *) updateGames:(NSArray *)newGames
{
  NSMutableArray *mergedNewGames = [[NSMutableArray alloc] initWithCapacity:newGames.count];
  for(long i = 0; i < newGames.count; i++)
    [mergedNewGames addObject:[self updateGame:newGames[i]]];
  return mergedNewGames;
}

- (Game *) gameForId:(long)game_id
{
  return [games objectForKey:[NSNumber numberWithLong:game_id]];
}
- (void) requestGame:(long)game_id
{
  [_SERVICES_ fetchGame:game_id];
}
- (void) playerResetGame:(long)game_id
{
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];;
  SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
  
  Game *g = [_MODEL_GAMES_ gameForId:game_id];
  
  //reset any stores (manually because infrastructure to access server might not exist)
  NSError *error;
  NSString *file;
  NSString *folder = [[_MODEL_ applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",g.game_id]];
  [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error]; //if folder doesn't exist...
  NSString *contents;
  NSString *newcontents;
  NSDictionary *items_json;
  NSMutableDictionary *json;
  NSData *data;
  
  //first grab items
  file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_game.json",@"items"]];
  contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
  items_json = [jsonParser objectWithString:contents];

  //logs
  file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",@"logs"]];
  contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
  newcontents = @"{\"logs\":[]}";
  data = [newcontents dataUsingEncoding:NSUTF8StringEncoding];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  
  //groups
  file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",@"groups"]];
  contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
  newcontents = @"{\"group\":{\"name\":\"\",\"group_id\":\"0\"}}";
  data = [newcontents dataUsingEncoding:NSUTF8StringEncoding];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  
  //quests
  file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",@"quests"]];
  contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
  newcontents = @"{\"complete_quests\":[],\"active_quests\":[]}";
  data = [newcontents dataUsingEncoding:NSUTF8StringEncoding];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  
  //tabs
  file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",@"tabs"]];
  contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
  newcontents = @"{\"tabs\":[]}";
  data = [newcontents dataUsingEncoding:NSUTF8StringEncoding];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  
  //scene
  file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",@"scene"]];
  contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
  newcontents = @"{}";
  data = [newcontents dataUsingEncoding:NSUTF8StringEncoding];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  
  //triggers
  file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",@"triggers"]];
  contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
  newcontents = @"{\"triggers\":[]}";
  data = [newcontents dataUsingEncoding:NSUTF8StringEncoding];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  
  //scene
  file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",@"scene"]];
  contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
  newcontents = @"{}";
  data = [newcontents dataUsingEncoding:NSUTF8StringEncoding];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  
  //player instances
  file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",@"player_instances"]];
  contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
  //json = [jsonParser objectWithString:@"{\"instances\":[]}"];
  json = [[NSMutableDictionary alloc] init];
  [json setObject:[[NSMutableArray alloc] init] forKey:@"instances"];
  for(long i = 0; i < ((NSArray *)items_json[@"items"]).count; i++)
  {
    [((NSMutableArray*)json[@"instances"]) addObject:[[NSMutableArray alloc] init]];
    NSString *key;
    key = @"";
    [((NSMutableDictionary *)((NSMutableArray*)json[@"instances"])) setObject:((NSDictionary *)((NSArray *)items_json[@"items"])[i])[key] forKey:key];
  }
  newcontents = [jsonWriter stringWithObject:json];
  data = [newcontents dataUsingEncoding:NSUTF8StringEncoding];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  
  
  [_SERVICES_ logPlayerResetGame:game_id];
}

- (NSArray *) pingNearbyGames
{
  if(!nearbyStamp || [nearbyStamp timeIntervalSinceNow] < -10 ||
      (_MODEL_PLAYER_.location && (!location ||
                                   location.coordinate.latitude  != _MODEL_PLAYER_.location.coordinate.latitude ||
                                   location.coordinate.longitude != _MODEL_PLAYER_.location.coordinate.longitude
                                  )
      ))
  {
    nearbyStamp = [[NSDate alloc] init];
    location = [_MODEL_PLAYER_.location copy];
    [_SERVICES_ fetchNearbyGames];
  }
  else [self performSelector:@selector(notifNearbyGames) withObject:nil afterDelay:1];

  return nearbyGames;
}
- (NSArray *) nearbyGames { return nearbyGames; }

- (NSArray *) pingAnywhereGames
{
  if(!anywhereStamp || [anywhereStamp timeIntervalSinceNow] < -10)
  {
    anywhereStamp = [[NSDate alloc] init];
    [_SERVICES_ fetchAnywhereGames];
  }
  else [self performSelector:@selector(notifAnywhereGames) withObject:nil afterDelay:1];

  return anywhereGames;
}
- (NSArray *) anywhereGames { return anywhereGames; }

- (NSArray *) pingPopularGames:(NSString *)i
{
  if(!popularStamp || [popularStamp timeIntervalSinceNow] < -10 ||
      ![interval isEqualToString:i])
  {
    popularStamp = [[NSDate alloc] init];
    interval = i;
    [_SERVICES_ fetchPopularGamesInterval:interval];
  }
  else [self performSelector:@selector(notifPopularGames) withObject:nil afterDelay:1];

  return popularGames;
}
- (NSArray *) popularGames { return popularGames; }

- (NSArray *) pingRecentGames
{
  if(!recentStamp || [recentStamp timeIntervalSinceNow] < -10)
  {
    recentStamp = [[NSDate alloc] init];
    [_SERVICES_ fetchRecentGames];
  }
  else [self performSelector:@selector(notifRecentGames) withObject:nil afterDelay:1];

  return recentGames;
}
- (NSArray *) recentGames { return recentGames; }

- (NSArray *) pingSearchGames:(NSString *)s
{
  if(!searchStamp || [searchStamp timeIntervalSinceNow] < -10 ||
      ![search isEqualToString:s])
  {
    searchStamp = [[NSDate alloc] init];
    search = s;
    [_SERVICES_ fetchSearchGames:s];
  }
  else [self performSelector:@selector(notifSearchGames) withObject:nil afterDelay:1];

  return searchGames;
}
- (NSArray *) searchGames { return searchGames; }

- (NSArray *) pingMineGames
{
  if(!mineStamp || [mineStamp timeIntervalSinceNow] < -10)
  {
    mineStamp = [[NSDate alloc] init];
    [_SERVICES_ fetchMineGames];
  }
  else [self performSelector:@selector(notifMineGames) withObject:nil afterDelay:1];

  return mineGames;
}
- (NSArray *) mineGames { return mineGames; }

- (NSArray *) pingDownloadedGames
{
  if(!downloadedStamp || [downloadedStamp timeIntervalSinceNow] < -10)
  {
    downloadedStamp = [[NSDate alloc] init];
    //gen downloaded games
    
    NSMutableArray *d_games = [[NSMutableArray alloc] init];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSString *rootString = [_MODEL_ applicationDocumentsDirectory];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootString error:NULL];
    for(long i = 0; i < directoryContent.count; i++)
    {
      NSString *gameFolderString = [rootString stringByAppendingPathComponent:directoryContent[i]];
      NSString *gameDataString = [gameFolderString stringByAppendingPathComponent:@"game.json"];
      if([[NSFileManager defaultManager] fileExistsAtPath:gameDataString])
      {
        NSString *content = [NSString stringWithContentsOfFile:gameDataString encoding:NSUTF8StringEncoding error:nil];
        Game *g = [[Game alloc] initWithDictionary:[jsonParser objectWithString:content]];
        if(![g.network_level isEqualToString:@"REMOTE"])
          [d_games addObject:g];
      }
    }
    //emulate 'services' for consistency's sake
    if(d_games.count > 0) _ARIS_NOTIF_SEND_(@"SERVICES_DOWNLOADED_GAMES_RECEIVED", nil, @{@"games":d_games});
  }
  else [self performSelector:@selector(notifDownloadedGames) withObject:nil afterDelay:1];

  return downloadedGames;
}
- (NSArray *) downloadedGames { return downloadedGames; }

- (void) requestPlayerPlayedGame:(long)game_id
{
  Game *g = [_MODEL_GAMES_ gameForId:game_id];
  //when offline mode implemented, just check log here
  if(
    [_DELEGATE_.reachability currentReachabilityStatus] == NotReachable && //offline
    g.downloadedVersion //downloaded
    )
  {
    NSError *error;
    NSString *folder = [[_MODEL_ applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",game_id]];
    NSString *file = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_player.json",@"logs"]];
    NSString *contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    if(!contents || [contents isEqualToString:@""] || [contents isEqualToString:@"{\"logs\":[]}"])
    {
      _ARIS_NOTIF_SEND_(@"MODEL_PLAYER_PLAYED_GAME_AVAILABLE",nil,(@{@"game_id":[NSNumber numberWithLong:game_id],@"has_played":[NSNumber numberWithBool:FALSE]}));
    }
    else
    {
      _ARIS_NOTIF_SEND_(@"MODEL_PLAYER_PLAYED_GAME_AVAILABLE",nil,(@{@"game_id":[NSNumber numberWithLong:game_id],@"has_played":[NSNumber numberWithBool:TRUE]}));
    }
  }
  else
    [_SERVICES_ fetchPlayerPlayedGame:game_id];
}

- (void) playerPlayedGameReceived:(NSNotification *)notif
{
  //just turn event around and re-send it
  _ARIS_NOTIF_SEND_(@"MODEL_PLAYER_PLAYED_GAME_AVAILABLE",nil,notif.userInfo);
}

- (NSString *) serializedName
{
  return @"games";
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

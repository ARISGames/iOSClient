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

@interface GamesModel()
{
  NSMutableDictionary *games;
  NSArray *nearbyGames;     NSDate *nearbyStamp; CLLocation *location;
  NSArray *anywhereGames;   NSDate *anywhereStamp;
  NSArray *popularGames;    NSDate *popularStamp; NSString *interval; long popularPage; BOOL popularInProgress; BOOL popularDone;
  NSArray *recentGames;     NSDate *recentStamp; long recentPage; BOOL recentInProgress; BOOL recentDone;
  NSArray *searchGames;     NSDate *searchStamp; NSString *search; long searchPage; BOOL searchInProgress; BOOL searchDone;
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
  popularStamp = nil; interval = nil; popularPage = 0; popularInProgress = NO; popularDone = NO;
  recentStamp = nil; recentPage = 0; recentInProgress = NO; recentDone = NO;
  searchStamp = nil; search = nil; searchPage = 0; searchInProgress = NO; searchDone = NO;
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
- (void) updatePopularGames:(NSArray *)gs {
  if (popularPage == 0) {
    popularGames = [self updateGames:gs];
  } else {
    popularGames = [popularGames arrayByAddingObjectsFromArray:[self updateGames:gs]];
  }
  popularInProgress = NO;
  popularDone = [gs count] == 0;
  popularPage++;
  [self notifPopularGames];
}
- (void) notifPopularGames { _ARIS_NOTIF_SEND_(@"MODEL_POPULAR_GAMES_AVAILABLE",nil,nil); }

- (void) recentGamesReceived:(NSNotification *)n { [self updateRecentGames:n.userInfo[@"games"]]; }
- (void) updateRecentGames:(NSArray *)gs {
  if (recentPage == 0) {
    recentGames = [self updateGames:gs];
  } else {
    recentGames = [recentGames arrayByAddingObjectsFromArray:[self updateGames:gs]];
  }
  recentInProgress = NO;
  recentDone = [gs count] == 0;
  recentPage++;
  [self notifRecentGames];
}
- (void) notifRecentGames { _ARIS_NOTIF_SEND_(@"MODEL_RECENT_GAMES_AVAILABLE",nil,nil); }

- (void) searchGamesReceived:(NSNotification *)n { [self updateSearchGames:n.userInfo[@"games"]]; }
- (void) updateSearchGames:(NSArray *)gs {
  if (searchPage == 0) {
    searchGames = [self updateGames:gs];
  } else {
    searchGames = [searchGames arrayByAddingObjectsFromArray:[self updateGames:gs]];
  }
  searchInProgress = NO;
  searchDone = [gs count] == 0;
  searchPage++;
  [self notifSearchGames];
}
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
  /*
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];;
  SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
  
  Game *g = [_MODEL_GAMES_ gameForId:game_id];
  
  //reset any stores (manually because infrastructure to access server might not exist)
  NSError *error;
  NSString *file;
  NSString *folder = [[_MODEL_ applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",g.game_id]];
  _ARIS_LOG_(@"%@",folder);
  [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error]; //if folder doesn't exist...
  NSString *contents;
  NSString *newcontents;
  NSMutableDictionary *json;
  NSData *data;
  
  //used for copying/manipulating json
  NSArray *old_arr;
  NSDictionary *old_dict;
  NSMutableArray *arr;
  NSMutableDictionary *dict;
  NSString *key;

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
  
  json = [jsonParser objectWithString:contents];
  old_arr = json[@"instances"];
  arr = [[NSMutableArray alloc] init];
  
  json = [[NSMutableDictionary alloc] init];
  [json setObject:arr forKey:@"instances"];
  for(long i = 0; i < old_arr.count; i++)
  {
    old_dict = old_arr[i];
    dict = [[NSMutableDictionary alloc] init];
    [arr addObject:dict];
    
    key = @"instance_id";
    [dict setObject:old_dict[key] forKey:key];
    key = @"factory_id";
    [dict setObject:old_dict[key] forKey:key];
    key = @"object_type";
    [dict setObject:old_dict[key] forKey:key];
    key = @"created";
    [dict setObject:old_dict[key] forKey:key];
    key = @"owner_type";
    [dict setObject:old_dict[key] forKey:key];
    key = @"object_id";
    [dict setObject:old_dict[key] forKey:key];
    key = @"infinite_qty";
    [dict setObject:old_dict[key] forKey:key];
    key = @"owner_id";
    [dict setObject:old_dict[key] forKey:key];
    key = @"qty"; //EXPLICITLY SET TO 0!
    [dict setObject:@"0" forKey:key];
  }
  newcontents = [jsonWriter stringWithObject:json];
  data = [newcontents dataUsingEncoding:NSUTF8StringEncoding];
  [data writeToFile:file atomically:YES];
  [[NSURL fileURLWithPath:file] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
   */
  
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
    popularPage = 0;
    popularDone = NO;
    popularInProgress = YES;
    [_SERVICES_ fetchPopularGamesInterval:interval page:0];
  }
  else [self performSelector:@selector(notifPopularGames) withObject:nil afterDelay:1];

  return popularGames;
}
- (void) continuePopularGames
{
  if (popularInProgress || popularDone) return;
  popularStamp = [[NSDate alloc] init];
  [_SERVICES_ fetchPopularGamesInterval:interval page:popularPage];
  popularInProgress = YES;
  return;
}
- (NSArray *) popularGames { return popularGames; }

- (NSArray *) pingRecentGames
{
  if(!recentStamp || [recentStamp timeIntervalSinceNow] < -10)
  {
    recentStamp = [[NSDate alloc] init];
    recentPage = 0;
    recentDone = NO;
    recentInProgress = YES;
    [_SERVICES_ fetchRecentGamesPage:0];
  }
  else [self performSelector:@selector(notifRecentGames) withObject:nil afterDelay:1];

  return recentGames;
}
- (void) continueRecentGames
{
  if (recentInProgress || recentDone) return;
  recentStamp = [[NSDate alloc] init];
  [_SERVICES_ fetchRecentGamesPage:recentPage];
  recentInProgress = YES;
  return;
}
- (NSArray *) recentGames { return recentGames; }

- (NSArray *) pingSearchGames:(NSString *)s
{
  if(!searchStamp || [searchStamp timeIntervalSinceNow] < -10 ||
      ![search isEqualToString:s])
  {
    searchStamp = [[NSDate alloc] init];
    search = s;
    searchPage = 0;
    searchDone = NO;
    searchInProgress = YES;
    [_SERVICES_ fetchSearchGames:s page:0];
  }
  else [self performSelector:@selector(notifSearchGames) withObject:nil afterDelay:1];

  return searchGames;
}
- (void) continueSearchGames
{
  if (searchInProgress || searchDone) return;
  searchStamp = [[NSDate alloc] init];
  [_SERVICES_ fetchSearchGames:search page:searchPage];
  searchInProgress = YES;
  return;
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
    NSString *rootString = [_MODEL_ applicationDocumentsDirectory];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootString error:NULL];
    for(long i = 0; i < directoryContent.count; i++)
    {
      NSString *gameFolderString = [rootString stringByAppendingPathComponent:directoryContent[i]];
      NSString *gameDataString = [gameFolderString stringByAppendingPathComponent:@"game.json"];
      if([[NSFileManager defaultManager] fileExistsAtPath:gameDataString])
      {
        NSData *content = [NSData dataWithContentsOfFile:gameDataString];
        NSError *error = nil;
        Game *g = [[Game alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:&error]];
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

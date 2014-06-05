//
//  AppServices.m
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "AppServices.h"
#import "ARISConnection.h"
#import "ARISMediaLoader.h"
#import "ARISServiceResult.h"
#import "ARISServiceGraveyard.h"
#import "AppModel.h"
#import "NSDictionary+ValidParsers.h"

@interface AppServices()
{
  ARISConnection *connection;
  ARISMediaLoader *mediaLoader; 
}

@end

@implementation AppServices

+ (id) sharedAppServices
{
  static dispatch_once_t pred = 0;
  __strong static id _sharedObject = nil;
  dispatch_once(&pred, ^{
      _sharedObject = [[self alloc] init]; // or some other init method
      });
  return _sharedObject;
}

- (id) init
{
  if(self = [super init])
  {
    connection = [[ARISConnection alloc] initWithServer:_MODEL_.serverURL graveyard:_MODEL_.servicesGraveyard];
    mediaLoader = [[ARISMediaLoader alloc] init]; 
  _ARIS_NOTIF_LISTEN_(@"WifiConnected",self,@selector(retryFailedRequests),nil);
  }
  return self;
}

- (void) retryFailedRequests
{
  [_MODEL_.servicesGraveyard reviveRequestsWithConnection:connection];
}

- (void) createUserWithName:(NSString *)user_name displayName:(NSString *)display_name groupName:(NSString *)group_name email:(NSString *)email password:(NSString *)password
{
  NSDictionary *args = 
    @{
      @"user_name"    :user_name,
      @"display_name" :display_name, 
      @"group_name"   :group_name,  
      @"email"        :email, 
      @"password"     :password
    };
  [connection performAsynchronousRequestWithService:@"users" method:@"createUser" arguments:args handler:self successSelector:@selector(parseLoginResponse:) failSelector:nil retryOnFail:NO userInfo:nil]; 
}

- (void) logInUserWithName:(NSString *)user_name password:(NSString *)password;
{
  NSDictionary *args = 
    @{
      @"user_name"  :user_name,
      @"password"   :password,
      @"permission" :@"read_write" 
    };
  [connection performAsynchronousRequestWithService:@"users" method:@"logIn" arguments:args handler:self successSelector:@selector(parseLoginResponse:) failSelector:nil retryOnFail:NO userInfo:nil];  
}

- (void) parseLoginResponse:(ARISServiceResult *)result
{
  User *user = [[User alloc] initWithDictionary:(NSDictionary *)result.resultData];
  _ARIS_NOTIF_SEND_(@"SERVICES_LOGIN_RECEIVED",nil,@{@"user":user});
}

- (NSArray *) parseGames:(NSArray *)gamesDicts
{
    NSMutableArray *games= [[NSMutableArray alloc] init];
    
    for(int i = 0; i < gamesDicts.count; i++)
        [games addObject:[[Game alloc] initWithDictionary:gamesDicts[i]]];
    
    return games;
}

- (void) fetchGame:(int)game_id
{
       NSDictionary *args = 
        @{
          @"game_id":[NSNumber numberWithInt:game_id]
        };
  [connection performAsynchronousRequestWithService:@"games" method:@"getFullGame" arguments:args handler:self successSelector:@selector(parseGame:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseGame:(ARISServiceResult *)result
{	   
    _ARIS_NOTIF_SEND_(@"SERVICES_GAME_RECEIVED", nil, @{@"game":[[Game alloc] initWithDictionary:(NSDictionary *)result.resultData]});
}

- (void) fetchNearbyGames
{
    NSDictionary *args = 
        @{
            @"user_id":[NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"showGamesInDevel":[NSString stringWithFormat:@"%d",_MODEL_.showGamesInDevelopment]
        };
  [connection performAsynchronousRequestWithService:@"bogus" method:@"doBogusThing" arguments:args handler:self successSelector:@selector(parseNearbyGames:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseNearbyGames:(ARISServiceResult *)result
{	   
    _ARIS_NOTIF_SEND_(@"SERVICES_NEARBY_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchAnywhereGames
{
    NSDictionary *args = 
        @{
            @"user_id":[NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"showGamesInDevel":[NSString stringWithFormat:@"%d",_MODEL_.showGamesInDevelopment]
        };
  [connection performAsynchronousRequestWithService:@"bogus" method:@"doBogusThing" arguments:args handler:self successSelector:@selector(parseAnywhereGames:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseAnywhereGames:(ARISServiceResult *)result
{	   
    _ARIS_NOTIF_SEND_(@"SERVICES_ANYWHERE_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchRecentGames
{
    NSDictionary *args = 
        @{
            @"user_id":[NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"showGamesInDevel":[NSString stringWithFormat:@"%d",_MODEL_.showGamesInDevelopment]
        };
  [connection performAsynchronousRequestWithService:@"bogus" method:@"doBogusThing" arguments:args handler:self successSelector:@selector(parseRecentGames:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseRecentGames:(ARISServiceResult *)result
{	   
    _ARIS_NOTIF_SEND_(@"SERVICES_RECENT_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchPopularGames
{
    NSDictionary *args = 
        @{
            @"user_id":[NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"showGamesInDevel":[NSString stringWithFormat:@"%d",_MODEL_.showGamesInDevelopment]
        };
  [connection performAsynchronousRequestWithService:@"bogus" method:@"doBogusThing" arguments:args handler:self successSelector:@selector(parsePopularGames:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parsePopularGames:(ARISServiceResult *)result
{	   
    _ARIS_NOTIF_SEND_(@"SERVICES_POPULAR_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchSearchGames:(NSString *)search
{
    NSDictionary *args = 
        @{
            @"user_id":[NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"showGamesInDevel":[NSString stringWithFormat:@"%d",_MODEL_.showGamesInDevelopment]
        };
  [connection performAsynchronousRequestWithService:@"bogus" method:@"doBogusThing" arguments:args handler:self successSelector:@selector(parseSearchGames:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseSearchGames:(ARISServiceResult *)result
{	   
    _ARIS_NOTIF_SEND_(@"SERVICES_SEARCH_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchPlaques
{
  NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"plaques" method:@"getPlaquesForGame" arguments:args handler:self successSelector:@selector(parsePlaques:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parsePlaques:(ARISServiceResult *)result
{	   
    NSArray *plaqueDicts = (NSArray *)result.resultData;
    NSMutableArray *plaques = [[NSMutableArray alloc] init];
    for(int i = 0; i < plaqueDicts.count; i++)
        plaques[i] = [[Plaque alloc] initWithDictionary:plaqueDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAQUES_RECEIVED", nil, @{@"plaques":plaques});
}

- (void) fetchItems
{
  NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"items" method:@"getItemsForGame" arguments:args handler:self successSelector:@selector(parseItems:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseItems:(ARISServiceResult *)result
{	   
    NSArray *itemDicts = (NSArray *)result.resultData;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(int i = 0; i < itemDicts.count; i++)
        items[i] = [[Item alloc] initWithDictionary:itemDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_ITEMS_RECEIVED", nil, @{@"items":items});
}

- (void) fetchDialogs
{
  NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogsForGame" arguments:args handler:self successSelector:@selector(parseDialogs:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseDialogs:(ARISServiceResult *)result
{	   
    NSArray *dialogDicts = (NSArray *)result.resultData;
    NSMutableArray *dialogs = [[NSMutableArray alloc] init];
    for(int i = 0; i < dialogDicts.count; i++)
        dialogs[i] = [[Dialog alloc] initWithDictionary:dialogDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOGS_RECEIVED", nil, @{@"dialogs":dialogs});
}

- (void) fetchWebPages
{
  NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"web_pages" method:@"getWebPagesForGame" arguments:args handler:self successSelector:@selector(parseWebPages:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseWebPages:(ARISServiceResult *)result
{	   
    NSArray *webPageDicts = (NSArray *)result.resultData;
    NSMutableArray *webPages = [[NSMutableArray alloc] init];
    for(int i = 0; i < webPageDicts.count; i++)
        webPages[i] = [[WebPage alloc] initWithDictionary:webPageDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_WEB_PAGES_RECEIVED", nil, @{@"webPages":webPages});
}

- (void) fetchQuests
{
  NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"quests" method:@"getQuestsForGame" arguments:args handler:self successSelector:@selector(parseQuests:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseQuests:(ARISServiceResult *)result
{	   
    NSArray *questDicts = (NSArray *)result.resultData;
    NSMutableArray *quests = [[NSMutableArray alloc] init];
    for(int i = 0; i < questDicts.count; i++)
        quests[i] = [[Quest alloc] initWithDictionary:questDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_QUESTS_RECEIVED", nil, @{@"quests":quests});
}

- (void) fetchInstances
{
    NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],
      @"owner_id":[NSNumber numberWithInt:0] //could leave this out and get same result, but would rather be explicit
      }; 
    [connection performAsynchronousRequestWithService:@"instances" method:@"getInstancesForGame" arguments:args handler:self successSelector:@selector(parseInstances:) failSelector:nil retryOnFail:NO userInfo:nil]; 
}
- (void) parseInstances:(ARISServiceResult *)result
{	   
    NSArray *instanceDicts = (NSArray *)result.resultData;
    NSMutableArray *instances = [[NSMutableArray alloc] init];
    for(int i = 0; i < instanceDicts.count; i++)
        instances[i] = [[Instance alloc] initWithDictionary:instanceDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_INSTANCES_RECEIVED", nil, @{@"instances":instances});
}

- (void) fetchTriggers
{
    NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],
      }; 
    [connection performAsynchronousRequestWithService:@"triggers" method:@"getTriggersForGame" arguments:args handler:self successSelector:@selector(parseTriggers:) failSelector:nil retryOnFail:NO userInfo:nil]; 
}
- (void) parseTriggers:(ARISServiceResult *)result
{	   
    NSArray *triggerDicts = (NSArray *)result.resultData;
    NSMutableArray *triggers = [[NSMutableArray alloc] init];
    for(int i = 0; i < triggerDicts.count; i++)
        triggers[i] = [[Trigger alloc] initWithDictionary:triggerDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_TRIGGERS_RECEIVED", nil, @{@"triggers":triggers});
}

- (void) fetchTabs
{
    NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],
      }; 
    [connection performAsynchronousRequestWithService:@"tabs" method:@"getTabsForGame" arguments:args handler:self successSelector:@selector(parseTabs:) failSelector:nil retryOnFail:NO userInfo:nil]; 
}
- (void) parseTabs:(ARISServiceResult *)result
{	   
    NSArray *tabDicts = (NSArray *)result.resultData;
    NSMutableArray *tabs = [[NSMutableArray alloc] init];
    for(int i = 0; i < tabDicts.count; i++)
        tabs[i] = [[Tab alloc] initWithDictionary:tabDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_TABS_RECEIVED", nil, @{@"tabs":tabs});
}



- (void) fetchInstancesForPlayer
{
     NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],
      @"owner_id":[NSNumber numberWithInt:_MODEL_PLAYER_.user_id]
      }; 
    [connection performAsynchronousRequestWithService:@"client" method:@"getInstancesForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerInstances:) failSelector:nil retryOnFail:NO userInfo:nil]; 
}
- (void) parsePlayerInstances:(ARISServiceResult *)result
{	   
    NSArray *instanceDicts = (NSArray *)result.resultData;
    NSMutableArray *instances = [[NSMutableArray alloc] init];
    for(int i = 0; i < instanceDicts.count; i++)
        instances[i] = [[Instance alloc] initWithDictionary:instanceDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_INSTANCES_RECEIVED", nil, @{@"instances":instances});
}

- (void) fetchTriggersForPlayer
{
     NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],
      }; 
    [connection performAsynchronousRequestWithService:@"client" method:@"getTriggersForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerTriggers:) failSelector:nil retryOnFail:NO userInfo:nil]; 
}
- (void) parsePlayerTriggers:(ARISServiceResult *)result
{	   
    NSArray *triggerDicts = (NSArray *)result.resultData;
    NSMutableArray *triggers = [[NSMutableArray alloc] init];
    for(int i = 0; i < triggerDicts.count; i++)
        triggers[i] = [[Trigger alloc] initWithDictionary:triggerDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_TRIGGERS_RECEIVED", nil, @{@"triggers":triggers});
}

- (void) fetchQuestsForPlayer
{
     NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],
      }; 
    [connection performAsynchronousRequestWithService:@"client" method:@"getQuestsForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerQuests:) failSelector:nil retryOnFail:NO userInfo:nil]; 
}
- (void) parsePlayerQuests:(ARISServiceResult *)result
{	   
    NSDictionary *quests =
    @{
      @"active"   : [[NSMutableArray alloc] init],
      @"complete" : [[NSMutableArray alloc] init]
    };
    
    NSArray *activeQuestDicts   = ((NSDictionary *)result.resultData)[@"active"]; 
    for(int i = 0; i < activeQuestDicts.count; i++)
        quests[@"active"][i] = [[Quest alloc] initWithDictionary:activeQuestDicts[i]];
    
    NSArray *completeQuestDicts = ((NSDictionary *)result.resultData)[@"complete"]; 
    for(int i = 0; i < completeQuestDicts.count; i++)
        quests[@"complete"][i] = [[Quest alloc] initWithDictionary:completeQuestDicts[i]]; 
    
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_QUESTS_RECEIVED", nil, quests);
}

- (void) fetchTabsForPlayer
{
     NSDictionary *args = 
    @{
      @"game_id":[NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],
      }; 
    [connection performAsynchronousRequestWithService:@"client" method:@"getTabsForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerTabs:) failSelector:nil retryOnFail:NO userInfo:nil]; 
}
- (void) parsePlayerTabs:(ARISServiceResult *)result
{	   
    NSArray *tabDicts = (NSArray *)result.resultData;
    NSMutableArray *tabs = [[NSMutableArray alloc] init];
    for(int i = 0; i < tabDicts.count; i++)
        tabs[i] = [[Trigger alloc] initWithDictionary:tabDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_TABS_RECEIVED", nil, @{@"tabs":tabs}); 
}
























- (void) updatePlayer:(int)user_id withName:(NSString *)name
{
  if(user_id != 0)
  {
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
      [NSString stringWithFormat:@"%d",user_id], @"auser_id",
      name,                                       @"bname",
      nil]; 
    [connection performAsynchronousRequestWithService:@"players" method:@"updatePlayerName" arguments:args handler:self successSelector:@selector(updatedPlayer:) failSelector:nil retryOnFail:NO userInfo:nil];
  }
  else
    NSLog(@"Tried updating non-existent player! (user_id = 0)");
}

- (void) resetAndEmailNewPassword:(NSString *)email
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    email,@"aemail",
    nil]; 
  [connection performAsynchronousRequestWithService:@"players" method:@"resetAndEmailNewPassword" arguments:args handler:self successSelector:@selector(parseResetAndEmailNewPassword:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) setShowPlayerOnMap
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d", _MODEL_PLAYER_.user_id], @"auser_id",
    [NSString stringWithFormat:@"%d", _MODEL_.showPlayerOnMap], @"bshowPlayerOnMap",
    nil]; 
  [connection performAsynchronousRequestWithService:@"players" method:@"setShowPlayerOnMap" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerLocationViewed:(int)locationId
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],   @"buser_id",
    [NSString stringWithFormat:@"%d",locationId],                                  @"clocationId",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"locationViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerPlaqueViewed:(int)plaque_id fromLocation:(int)locationId
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],   @"buser_id",
    [NSString stringWithFormat:@"%d",plaque_id],                                      @"cplaque_id",
    [NSString stringWithFormat:@"%d",locationId],                                  @"dlocationId",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"plaqueViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerWebPageViewed:(int)web_page_id fromLocation:(int)locationId
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],   @"buser_id",
    [NSString stringWithFormat:@"%d",web_page_id],                                   @"cweb_page_id",
    [NSString stringWithFormat:@"%d",locationId],                                  @"dlocationId",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"webPageViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerItemViewed:(int)item_id fromLocation:(int)locationId
{	
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],      @"buser_id",
    [NSString stringWithFormat:@"%d",item_id],                                       @"citem_id",
    [NSString stringWithFormat:@"%d",locationId],                                    @"dlocationId",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"itemViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerDialogViewed:(int)dialog_id fromLocation:(int)locationId
{	
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],   @"buser_id",
    [NSString stringWithFormat:@"%d",dialog_id],                                       @"cdialog_id",
    [NSString stringWithFormat:@"%d",locationId],                                  @"dlocationId",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"dialogViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerGameSelected
{	
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],   @"auser_id",
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"bgame_id",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"updatePlayerLastGame" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerMapViewed
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"buser_id",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"mapViewed" arguments:args handler:self successSelector:@selector(fetchPlayerLocationList) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerQuestsViewed
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"buser_id",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"questsViewed" arguments:args handler:self successSelector:@selector(fetchPlayerQuestList) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerInventoryViewed
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"buser_id",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"inventoryViewed" arguments:args handler:self successSelector:@selector(fetchPlayerInventory) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) parseResetAndEmailNewPassword:(ARISServiceResult *)jsonResult
{
    /*
  if(jsonResult == nil)
    [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ForgotPasswordTitleKey", nil) message:NSLocalizedString(@"ForgotPasswordMessageKey", nil)];
  else
    [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ForgotEmailSentTitleKey", @"") message:NSLocalizedString(@"ForgotMessageKey", @"")];
     */
}

- (void) startOverGame:(int)game_id
{
  [_MODEL_GAME_ clearModels];

  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d", game_id],                                   @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id], @"buser_id",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"startOverGameForPlayer" arguments:args handler:self successSelector:@selector(notifyOfGameReset) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) notifyOfGameReset
{
  _ARIS_NOTIF_SEND_(@"GameReset",nil,nil); 
}

- (void) updateServerPickupItem:(int)item_id fromLocation:(int)locationId qty:(int)qty
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"buser_id",
    [NSString stringWithFormat:@"%d",item_id],                                       @"citem_id",
    [NSString stringWithFormat:@"%d",locationId],                                   @"dlocationId",
    [NSString stringWithFormat:@"%d",qty],                                          @"eqty",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"pickupItemFromLocation" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerDropItemHere:(int)item_id qty:(int)qty
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],                   @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],                      @"buser_id",
    [NSString stringWithFormat:@"%d",item_id],                                                         @"citem_id",
    [NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],  @"dlatitude",
    [NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude], @"elongitude",
    [NSString stringWithFormat:@"%d",qty],                                                            @"fqty",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"dropItem" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) dropNote:(int)noteId atCoordinate:(CLLocationCoordinate2D)coordinate
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],   @"buser_id",
    [NSString stringWithFormat:@"%d",noteId],                                      @"cnoteId",
    [NSString stringWithFormat:@"%f",coordinate.latitude],                         @"dlatitude",
    [NSString stringWithFormat:@"%f",coordinate.longitude],                        @"elongitude",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"dropNote" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerDestroyItem:(int)item_id qty:(int)qty
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"buser_id",
    [NSString stringWithFormat:@"%d",item_id],                                       @"citem_id",
    [NSString stringWithFormat:@"%d",qty],                                          @"dqty",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"destroyItem" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerInventoryItem:(int)item_id qty:(int)qty
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",item_id],                                       @"btemId",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"cuser_id",
    [NSString stringWithFormat:@"%d",qty],                                          @"dqty",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"setItemCountForPlayer" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerAddInventoryItem:(int)item_id addQty:(int)qty
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",item_id],                                       @"bitem_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"cuser_id",
    [NSString stringWithFormat:@"%d",qty],                                          @"dqty",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"giveItemToPlayer" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) updateServerRemoveInventoryItem:(int)item_id removeQty:(int)qty
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",item_id],                                       @"bitem_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"cuser_id",
    [NSString stringWithFormat:@"%d",qty],                                          @"dqty",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"takeItemFromPlayer" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) deleteNoteWithNoteId:(int)noteId
{
  if(noteId != 0)
  {
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
      [NSString stringWithFormat:@"%d",noteId], @"anoteId",
      nil];
    [connection performAsynchronousRequestWithService:@"notebook" method:@"deleteNote" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
  }
}

- (void) uploadNote:(Note *)n
{
    /*
  NSDictionary *location = [[NSDictionary alloc] initWithObjectsAndKeys: 
    [NSNumber numberWithFloat:n.location.latlon.coordinate.latitude],  @"latitude",
    [NSNumber numberWithFloat:n.location.latlon.coordinate.longitude], @"longitude", 
    nil];
  NSMutableArray *media = [[NSMutableArray alloc] initWithCapacity:n.contents];
  for(int i = 0; i < n.contents.count; i++)
  {
    NSDictionary *m = [[NSDictionary alloc] initWithObjectsAndKeys:
      [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"path",
      [((Media *)[n.contents objectAtIndex:i]).localURL absoluteString],@"filename", 
      [((Media *)[n.contents objectAtIndex:i]).data base64Encoding],@"data", 
      nil];
    [media addObject:m];
  }

  NSMutableArray *tags = [[NSMutableArray alloc] initWithCapacity:n.tags];
  for(int i = 0; i < n.tags.count; i++)
    [tags addObject:((NoteTag *)[n.tags objectAtIndex:i]).text];

  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSNumber numberWithInt:_MODEL_GAME_.game_id], @"game_id",
    [NSNumber numberWithInt:n.noteId],                                     @"noteId",
    [NSNumber numberWithInt:_MODEL_PLAYER_.user_id],    @"user_id",
    n.name,                                                                @"title",
    n.desc,                                                                @"description",
    [NSNumber numberWithBool:n.publicToMap],                               @"publicToMap",
    [NSNumber numberWithBool:n.publicToList],                              @"publicToBook",
    location,                                                              @"location",
    media,                                                                 @"media",
    tags,                                                                  @"tags",
    nil]; 
  [connection performAsynchronousRequestWithService:@"notebook" method:@"addNoteFromJSON" arguments:args handler:self successSelector:@selector(parseNoteFromJSON:) failSelector:nil retryOnFail:YES userInfo:nil]; 
     */
}

- (void) addComment:(NSString *)c fromPlayer:(User *)p toNote:(Note *)n
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",n.noteId],   @"anoteId",   
    [NSString stringWithFormat:@"%d",p.user_id], @"buser_id",  
    c,                                            @"ctext",
    nil]; 
  [connection performAsynchronousRequestWithService:@"notebook" method:@"addCommentToNote" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];  
}

- (void) uploadPlayerPic:(Media *)m
{
  NSDictionary *mdict = [[NSDictionary alloc] initWithObjectsAndKeys:
    [m.localURL absoluteString],@"filename", 
    [m.data base64Encoding],@"data", 
    nil];

  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSNumber numberWithInt:_MODEL_PLAYER_.user_id],    @"user_id",  
    mdict,                                                                 @"media",    
    nil]; 
  [connection performAsynchronousRequestWithService:@"players" method:@"uploadPlayerMediaFromJSON" arguments:args handler:self successSelector:@selector(playerPicUploadDidFinish:) failSelector:nil retryOnFail:NO userInfo:nil];    
}

- (void) uploadContentToNoteWithFileURL:(NSURL *)fileURL name:(NSString *)name noteId:(int) noteId type: (NSString *)type
{
  NSNumber *nId = [[NSNumber alloc] initWithInt:noteId]; 
  NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:4];
  [userInfo setValue:name forKey:@"title"];
  [userInfo setValue:nId forKey:@"noteId"];
  [userInfo setValue:type forKey: @"type"];
  [userInfo setValue:fileURL forKey:@"url"];

  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    @"object", @"key", 
    nil]; 
  [connection performAsynchronousRequestWithService:@"?" method:@"?" arguments:args handler:self successSelector:@selector(noteContentUploadDidFinish:) failSelector:@selector(uploadNoteContentDidFail:) retryOnFail:NO userInfo:userInfo]; 
}


- (void) playerPicUploadDidFinish:(ARISServiceResult*)result
{        
  NSDictionary *m = (NSDictionary *)result.resultData;
  _MODEL_PLAYER_.media_id = [m validIntForKey:@"media_id"];
}

- (void) updatedPlayer:(ARISServiceResult *)result
{
  //immediately load new image into cache
  if(_MODEL_PLAYER_.media_id != 0)
    [self loadMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id] delegateHandle:nil]; 
}

- (void) parseNewPlayerMediaResponseFromJSON:(ARISServiceResult *)jsonResult
{	   
  if(jsonResult.resultData && [((NSDictionary *)jsonResult.resultData) validIntForKey:@"media_id"])
  {
    _MODEL_PLAYER_.media_id = [((NSDictionary*)jsonResult.resultData) validIntForKey:@"media_id"];
    //immediately load new image into cache 
    if(_MODEL_PLAYER_.media_id != 0)
      [self loadMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id] delegateHandle:nil];  
    //[_MODEL_ saveUserDefaults];
  }
}

- (void) updateServerWithPlayerLocation
{
  if(!_MODEL_PLAYER_)
  {
    NSLog(@"Skipping Request: player not logged in");
    return;
  }

  //Update the server with the new Player Location
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],                     @"auser_id",
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],                  @"bgame_id",
    [NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude], @"clatitude",
    [NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],@"dlongitude",
    nil];
  [connection performAsynchronousRequestWithService:@"players" method:@"updatePlayerLocation" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}

#pragma mark ASync Fetch selectors

- (void)fetchGameOverlayList
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d", _MODEL_GAME_.game_id], @"agame_id", nil];
  [connection performAsynchronousRequestWithService:@"overlays" method:@"getOverlaysForGame" arguments:args handler:self successSelector:@selector(parseOverlayListFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) parseOverlayListFromJSON:(ARISServiceResult *)jsonResult
{
  NSMutableDictionary *newOverlayList = [[NSMutableDictionary alloc] init];
  NSArray *overlayListArray = (NSArray *)jsonResult.resultData;
  NSEnumerator *overlayEnumerator = [overlayListArray objectEnumerator];
  NSDictionary *overlayDictionary;
  //loop through and create the array of overlay objects
  while (overlayDictionary = [overlayEnumerator nextObject]) {
    int overlayId = [overlayDictionary validIntForKey:@"overlay_id"];
    double topLeftLat = [overlayDictionary validDoubleForKey:@"top_left_latitude"];
    double topLeftLong = [overlayDictionary validDoubleForKey:@"top_left_longitude"];
    double topRightLat = [overlayDictionary validDoubleForKey:@"top_right_latitude"];
    double topRightLong = [overlayDictionary validDoubleForKey:@"top_right_longitude"];
    double bottomLeftLat = [overlayDictionary validDoubleForKey:@"bottom_left_latitude"];
    double bottomRightLong = [overlayDictionary validDoubleForKey:@"bottom_left_longitude"];
    int media_id = [overlayDictionary validIntForKey:@"media_id"];
    CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(topLeftLat, topLeftLong);
    CLLocationCoordinate2D topRight = CLLocationCoordinate2DMake(topRightLat, topRightLong);
    CLLocationCoordinate2D bottomLeft = CLLocationCoordinate2DMake(bottomLeftLat, bottomRightLong);
    Media *media = [_MODEL_MEDIA_ mediaForId:media_id];
    ARISMediaView *mediaView = [[ARISMediaView alloc] init];
    [mediaView setMedia:media];
    CustomMapOverlay *mapOverlay = [[CustomMapOverlay alloc] initWithUpperLeftCoordinate:topLeft upperRightCoordinate:topRight bottomLeftCoordinate:bottomLeft overlayMedia:mediaView];
    [newOverlayList setObject:mapOverlay forKey:[NSNumber numberWithInt:overlayId]];
  }
  NSMutableDictionary *overlayDictionaryToSend = [[NSMutableDictionary alloc] init];
  [overlayDictionaryToSend setObject:newOverlayList forKey:@"overlays"];

  _ARIS_NOTIF_SEND_(@"OverlaysReceived",self,overlayDictionaryToSend);
  _ARIS_NOTIF_SEND_(@"GamePieceReceived",nil,nil);
}

- (void) fetchAllPlayerLists
{
  [self fetchPlayerLocationList];
  [self fetchPlayerQuestList];
  [self fetchPlayerInventory];
  [self fetchPlayerOverlayList];
}

- (void) fetchTabBarItems
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    nil];

  [connection performAsynchronousRequestWithService:@"games" method:@"getTabBarItemsForGame" arguments:args handler:self successSelector:@selector(parseGameTabListFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) fetchQRCode:(NSString*)code
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"agame_id",
    [NSString stringWithFormat:@"%@",code],                                        @"bcode",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],   @"cuser_id",
    nil];
  [connection performAsynchronousRequestWithService:@"qrcodes" method:@"getQRCodeNearbyObjectForPlayer" arguments:args handler:self successSelector:@selector(parseQRCodeObjectFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) fetchDialogConversations:(int)dialog_id afterViewingPlaque:(int)plaque_id
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",dialog_id],                                        @"bdialog_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"cuser_id",
    [NSString stringWithFormat:@"%d",plaque_id],                                       @"dplaque_id",
    nil];
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getdialogConversationsForPlayerAfterViewingPlaque" arguments:args handler:self successSelector:@selector(parseConversationOptionsFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) fetchNoteListPage:(int)page
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"buser_id",
    [NSString stringWithFormat:@"%d",page],                                         @"cpage",
    [NSString stringWithFormat:@"%d", 20],                                          @"dqty",
    nil];

  [connection performAsynchronousRequestWithService:@"notebook" method:@"getStubNotesVisibleToPlayer" arguments:args handler:self successSelector:@selector(parseNoteListFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) fetchNoteTagLists
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"agame_id",
    nil];
  [connection performAsynchronousRequestWithService:@"notebook" method:@"getGameTags" arguments:args handler:self successSelector:@selector(parseNoteTagsListFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) parseNoteTagsListFromJSON:(ARISServiceResult *)jsonResult
{    
    /*
  NSArray *noteTagDictList = (NSArray *)jsonResult.resultData;
  NSMutableArray *tempNoteTagList = [[NSMutableArray alloc] initWithCapacity:noteTagDictList.count];
  for(int i = 0; i < noteTagDictList.count; i++)
    [tempNoteTagList addObject:[[NoteTag alloc] initWithDictionary:[noteTagDictList objectAtIndex:i]]];

  _ARIS_NOTIF_SEND_(@"LatestNoteTagListReceived",nil,[[NSDictionary alloc] initWithObjectsAndKeys:tempNoteTagList, @"noteTags", nil]); 
     */
}

- (void) fetchNoteWithId:(int)noteId
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",noteId],@"anoteId",
    nil];
  [connection performAsynchronousRequestWithService:@"notebook" method:@"getNote" arguments:args handler:self successSelector:@selector(parseNoteFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil]; 
}


- (void) fetchMediaMeta:(Media *)m
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    ((_MODEL_GAME_.game_id != 0) ? [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id] : @"player"), @"apath",
    [NSString stringWithFormat:@"%d",m.media_id], @"bmedia_id",
    nil];

  [connection performAsynchronousRequestWithService:@"media" method:@"getMediaObject" arguments:args handler:self successSelector:@selector(parseSingleMediaFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

//Delegate handle must be of type id<ARISMediaLoaderDelegate>
- (void) loadMedia:(Media *)m delegateHandle:(ARISDelegateHandle *)dh
{
  [mediaLoader loadMedia:m delegateHandle:dh];
}

- (void) fetchGameMediaList
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    nil];
  [connection performAsynchronousRequestWithService:@"media" method:@"getMedia" arguments:args handler:self successSelector:@selector(parseGameMediaListFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) fetchPlayerLocationList
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d", _MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],     @"buser_id",
    nil];
  [connection performAsynchronousRequestWithService:@"locations" method:@"getLocationsForPlayer" arguments:args handler:self successSelector:@selector(parseLocationListFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}


- (void) fetchPlayerOverlayList
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", _MODEL_GAME_.game_id], @"agame_id",
               [NSString stringWithFormat:@"%d", _MODEL_PLAYER_.user_id], @"buser_id", nil];
  [connection performAsynchronousRequestWithService:@"overlays" method:@"getOverlaysForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerOverlayListFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) parsePlayerOverlayListFromJSON:(ARISServiceResult *)jsonResult
{
  NSArray *overlayIdArray = (NSArray *)jsonResult.resultData;
  NSMutableArray *ids = [[NSMutableArray alloc] init];
  NSEnumerator *overlayEnumerator = [overlayIdArray objectEnumerator];
  NSDictionary *overlayDictionary;
  while (overlayDictionary = [overlayEnumerator nextObject])
  {
    int overlayId = [overlayDictionary validIntForKey:@"overlay_id"];
    NSInteger intToAdd = overlayId;
    [ids addObject:[NSNumber numberWithInt:intToAdd]];
  }

  NSMutableDictionary *overlayDictionaryToSend = [[NSMutableDictionary alloc] init];
  [overlayDictionaryToSend setObject:ids forKey:@"overlayIds"];
  _ARIS_NOTIF_SEND_(@"OverlayIdsReceived",self,overlayDictionaryToSend);
  _ARIS_NOTIF_SEND_(@"PlayerPieceReceived",nil,nil);
}


- (void) fetchPlayerInventory
{    
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id],@"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],   @"buser_id",
    nil];

  [connection performAsynchronousRequestWithService:@"items" method:@"getItemsForPlayer" arguments:args handler:self successSelector:@selector(parseInventoryFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) fetchPlayerQuestList
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d",_MODEL_GAME_.game_id], @"agame_id",
    [NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],    @"buser_id",
    nil];
  [connection performAsynchronousRequestWithService:@"quests" method:@"getQuestsForPlayer" arguments:args handler:self successSelector:@selector(parseQuestListFromJSON:) failSelector:nil retryOnFail:NO userInfo:nil];
}

/*
- (Tab *) parseTabFromDictionary:(NSDictionary *)tabDictionary
{
  Tab *tab = [[Tab alloc] init];
  tab.tabIndex   = [tabDictionary validIntForKey:@"tab_index"];
  tab.tabName    = [tabDictionary validObjectForKey:@"tab"];
  tab.tabDetail1 = [tabDictionary validObjectForKey:@"tab_detail_1"] ? [tabDictionary validIntForKey:@"tab_detail_1"] : 0;
  return tab;
}
 */

- (void) parseNoteListFromJSON:(ARISServiceResult *)jsonResult
{
  NSArray *noteDictList = (NSArray *)jsonResult.resultData;
  NSMutableArray *tempNoteList = [[NSMutableArray alloc] initWithCapacity:noteDictList.count];
  for(int i = 0; i < noteDictList.count; i++)
    [tempNoteList addObject:[[Note alloc] initWithDictionary:[noteDictList objectAtIndex:i]]];

    _ARIS_NOTIF_SEND_(@"LatestNoteListReceived",nil,@{@"notes":tempNoteList}); 
}

- (void) parseNoteFromJSON:(ARISServiceResult *)jsonResult
{
  Note *note = [[Note alloc] initWithDictionary:(NSDictionary *)jsonResult.resultData];
  note.stubbed = NO;

    _ARIS_NOTIF_SEND_(@"NoteDataReceived",nil,@{@"note":note}); 
}

- (void) parseConversationOptionsFromJSON:(ARISServiceResult *)jsonResult
{
  NSArray *conversationOptionsArray = (NSArray *)jsonResult.resultData;
  NSMutableArray *conversationOptions = [[NSMutableArray alloc] initWithCapacity:3];
  NSEnumerator *conversationOptionsEnumerator = [conversationOptionsArray objectEnumerator];
  NSDictionary *conversationDictionary;

  while((conversationDictionary = [conversationOptionsEnumerator nextObject]))
  {
      /*
    int plaque_id = [conversationDictionary validIntForKey:@"plaque_id"];
    NSString *text = [conversationDictionary validObjectForKey:@"text"];
    BOOL hasViewed = [conversationDictionary validBoolForKey:@"has_viewed"];
    DialogScriptOption *option = [[DialogScriptOption alloc] initWithOptionText:text scriptText:@"" plaque_id:plaque_id hasViewed:hasViewed];
    [conversationOptions addObject:option];
       */
  }

  _ARIS_NOTIF_SEND_(@"ConversationOptionsReady",conversationOptions,nil);
}

- (void) saveGameComment:(NSString*)comment titled:(NSString *)t game:(int)game_id starRating:(int)rating
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
    [NSString stringWithFormat:@"%d", _MODEL_PLAYER_.user_id], @"auser_id",
    [NSString stringWithFormat:@"%d", game_id],                                    @"bgame_id",
    [NSString stringWithFormat:@"%d", rating],                                    @"crating",
    comment,                                                                      @"dcomment",
    t,                                                                      @"etitle", 
    nil];
  [connection performAsynchronousRequestWithService: @"games" method:@"saveComment" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}

- (void) parseSingleMediaFromJSON:(ARISServiceResult *)jsonResult
{
  //Just convert the data into an array and pretend it is a full game list, so same thing as 'parseGameMediaListFromJSON'
  NSArray * data = [[NSArray alloc] initWithObjects:jsonResult.resultData, nil];
  jsonResult.resultData = data;
  [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1]; //Deal with CoreData on separate thread //Phil thinks this is fishy/stupid... 12/13
}

- (void) parseGameMediaListFromJSON:(ARISServiceResult *)jsonResult
{
  [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1]; //Deal with CoreData on separate thread //Phil thinks this is fishy/stupid... 12/13
}

- (void) startCachingMedia:(ARISServiceResult *)jsonResult
{
  [_MODEL_MEDIA_ syncMediaDataToCache:(NSArray *)jsonResult.resultData];

  _ARIS_NOTIF_SEND_(@"ReceivedMediaList",nil,nil);
  _ARIS_NOTIF_SEND_(@"GamePieceReceived",nil,nil);
}

- (void) parseGameItemListFromJSON:(ARISServiceResult *)jsonResult
{
  NSArray *JSONArray = (NSArray *)jsonResult.resultData;
  NSMutableArray *itemsArray = [[NSMutableArray alloc] init];

  for(int i = 0; i < JSONArray.count; i++)
    [itemsArray addObject:[[Item alloc] initWithDictionary:[JSONArray objectAtIndex:i]]];

  _ARIS_NOTIF_SEND_(@"GameItemsReceived",nil,@{@"items":itemsArray});
  _ARIS_NOTIF_SEND_(@"GamePieceReceived",nil,nil);
}

- (void) parseGamePlaqueListFromJSON:(ARISServiceResult *)jsonResult
{
  NSArray *plaqueListArray = (NSArray *)jsonResult.resultData;
  NSMutableDictionary *tempPlaqueList = [[NSMutableDictionary alloc] init];
  NSEnumerator *enumerator = [plaqueListArray objectEnumerator];
  NSDictionary *dict;
  while ((dict = [enumerator nextObject]))
  {
    Plaque *tmpPlaque = [[Plaque alloc] initWithDictionary:dict];
    [tempPlaqueList setObject:tmpPlaque forKey:[NSNumber numberWithInt:tmpPlaque.plaque_id]];
  }

  _ARIS_NOTIF_SEND_(@"GamePieceReceived",nil,nil);
}

- (void) parseGameTabListFromJSON:(ARISServiceResult *)jsonResult
{
    /*
  NSArray *tabListArray = (NSArray *)jsonResult.resultData;
  NSMutableArray *tempTabList = [[NSMutableArray alloc] initWithCapacity:10];
  for(int i = 0; i < tabListArray.count; i++)
    [tempTabList addObject:[self parseTabFromDictionary:[tabListArray objectAtIndex:i]]];

  //PHIL HATES THIS
  _ARIS_NOTIF_SEND_(@"ReceivedTabList",nil,[[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:tempTabList,nil] forKeys:[[NSArray alloc] initWithObjects:@"tabs",nil]]);
  //PHIL DONE HATING

  _ARIS_NOTIF_SEND_(@"GamePieceReceived",nil,nil);
     */
}

- (void) parseGameDialogListFromJSON:(ARISServiceResult *)jsonResult
{
  NSArray *dialogListArray = (NSArray *)jsonResult.resultData;

  NSMutableDictionary *tempDialogList = [[NSMutableDictionary alloc] init];
  NSEnumerator *enumerator = [((NSArray *)dialogListArray) objectEnumerator];
  NSDictionary *dict;
  while ((dict = [enumerator nextObject]))
  {
    Dialog *tmpDialog = [[Dialog alloc] initWithDictionary:dict];
    [tempDialogList setObject:tmpDialog forKey:[NSNumber numberWithInt:tmpDialog.dialog_id]];
  }

  _ARIS_NOTIF_SEND_(@"GamePieceReceived",nil,nil);
}

- (void) parseGameWebPageListFromJSON:(ARISServiceResult *)jsonResult
{
  NSArray *webPageListArray = (NSArray *)jsonResult.resultData;

  NSMutableDictionary *tempWebPageList = [[NSMutableDictionary alloc] init];
  NSEnumerator *enumerator = [((NSArray *)webPageListArray) objectEnumerator];
  NSDictionary *dict;
  while ((dict = [enumerator nextObject]))
  {
    WebPage *tmpWebPage = [[WebPage alloc] initWithDictionary:dict];
    [tempWebPageList setObject:tmpWebPage forKey:[NSNumber numberWithInt:tmpWebPage.web_page_id]];
  }

  _ARIS_NOTIF_SEND_(@"GamePieceReceived",nil,nil);
}

- (void) parseInventoryFromJSON:(ARISServiceResult *)jsonResult
{
  NSArray *JSONArray = (NSArray *)jsonResult.resultData;
  NSMutableArray *inventoryArray = [[NSMutableArray alloc] init];

  for(int i = 0; i < JSONArray.count; i++)
    [inventoryArray addObject:[[Instance alloc] initWithDictionary:[JSONArray objectAtIndex:i]]];

  _ARIS_NOTIF_SEND_(@"PlayerInventoryReceived",nil,@{@"":inventoryArray});
  _ARIS_NOTIF_SEND_(@"PlayerPieceReceived",nil,nil);
}

- (void) parseQuestListFromJSON:(ARISServiceResult *)jsonResult
{
  NSDictionary *questListsDictionary = (NSDictionary *)jsonResult.resultData;

  //Active Quests
  NSArray *activeQuestDicts = [questListsDictionary validObjectForKey:@"active"];
  NSEnumerator *activeQuestDictsEnumerator = [activeQuestDicts objectEnumerator];
  NSDictionary *activeQuestDict;
  NSMutableArray *activeQuestObjects = [[NSMutableArray alloc] init];
  while ((activeQuestDict = [activeQuestDictsEnumerator nextObject]))
  {
      /*
    Quest *quest = [[Quest alloc] init];
    quest.questId                  = [activeQuestDict validIntForKey:@"quest_id"];
    quest.name                     = [activeQuestDict validStringForKey:@"name"]; 
    quest.media_id                  = [activeQuestDict validIntForKey:@"active_media_id"];
    quest.icon_media_id              = [activeQuestDict validIntForKey:@"active_icon_media_id"];
    quest.desc             = [activeQuestDict validStringForKey:@"description"];
    quest.fullScreenNotification   = [activeQuestDict validBoolForKey:@"full_screen_notify"];
    quest.goFunction               = [activeQuestDict validStringForKey:@"go_function"];
    quest.sortNum                  = [activeQuestDict validIntForKey:@"sort_index"]; 

    [activeQuestObjects addObject:quest];
       */
  }

  //Completed Quests
  NSArray *completedQuestDicts = [questListsDictionary validObjectForKey:@"completed"];
  NSEnumerator *completedQuestDictsEnumerator = [completedQuestDicts objectEnumerator];
  NSDictionary *completedQuestDict;
  NSMutableArray *completedQuestObjects = [[NSMutableArray alloc] init];
  while ((completedQuestDict = [completedQuestDictsEnumerator nextObject]))
  {
      /*
    Quest *quest = [[Quest alloc] init];
    quest.questId                  = [completedQuestDict validIntForKey:@"quest_id"];
    quest.name                     = [completedQuestDict validStringForKey:@"name"]; 
    quest.media_id                  = [completedQuestDict validIntForKey:@"complete_media_id"];
    quest.icon_media_id              = [completedQuestDict validIntForKey:@"complete_icon_media_id"];
    quest.desc             = [completedQuestDict validStringForKey:@"text_when_complete"];
    quest.fullScreenNotification   = [completedQuestDict validBoolForKey:@"complete_full_screen_notify"]; 
    quest.goFunction               = [completedQuestDict validStringForKey:@"complete_go_function"];
    quest.sortNum                  = [completedQuestDict validIntForKey:@"sort_index"]; 

    [completedQuestObjects addObject:quest];
       */
  }

  //Package the two object arrays in a Dictionary
  NSMutableDictionary *questLists = [[NSMutableDictionary alloc] init];
  [questLists setObject:activeQuestObjects forKey:@"active"];
  [questLists setObject:completedQuestObjects forKey:@"completed"];

  _ARIS_NOTIF_SEND_(@"LatestPlayerQuestListsReceived",self,questLists);
  _ARIS_NOTIF_SEND_(@"PlayerPieceReceived",nil,nil);
}

@end

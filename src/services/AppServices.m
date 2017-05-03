//
//  AppServices.m
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "AppServices.h"
#import "ARISConnection.h"
#import "ARISServiceResult.h"
#import "ARISServiceGraveyard.h"
#import "AppModel.h"
#import "NSDictionary+ValidParsers.h"

@interface AppServices()
{
  ARISConnection *connection;
}

@end

@implementation AppServices

@synthesize mediaLoader;

+ (AppServices *) sharedAppServices
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
    _ARIS_NOTIF_LISTEN_(@"NETWORK_CONNECTED",self,@selector(retryFailedRequests),nil);
  }
  return self;
}
- (void) setServer:(NSString *)s { [connection setServer:s]; }

- (void) retryFailedRequests
{
  _ARIS_LOG_(@"Retrying Failed Requests...");
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
  [connection performAsynchronousRequestWithService:@"users" method:@"createUser" arguments:args handler:self successSelector:@selector(parseLoginResponse:) failSelector:nil retryOnFail:NO humanDesc:@"Creating User..." userInfo:nil];
}

- (void) generateUserFromGroup:(NSString *)group_name
{
  NSDictionary *args =
    @{
      @"group_name" :group_name
    };
  [connection performAsynchronousRequestWithService:@"users" method:@"autoGenerateUser" arguments:args handler:self successSelector:@selector(parseLoginResponse:) failSelector:nil retryOnFail:NO humanDesc:@"Creating User..." userInfo:nil];
}

- (void) logInUserWithName:(NSString *)user_name password:(NSString *)password;
{
  NSDictionary *args =
    @{
      @"user_name"  :user_name,
      @"password"   :password,
      @"permission" :@"read_write"
    };
  [connection performAsynchronousRequestWithService:@"users" method:@"logIn" arguments:args handler:self successSelector:@selector(parseLoginResponse:) failSelector:nil retryOnFail:NO humanDesc:@"Loggin In..." userInfo:nil];
}

- (void) logInUserWithID:(long)user_id authToken:(NSString *)auth_token;
{
  NSDictionary *args =
    @{
      @"auth": @{@"user_id":[NSNumber numberWithLong:user_id],@"key":auth_token}
    };
  [connection performAsynchronousRequestWithService:@"users" method:@"logIn" arguments:args handler:self successSelector:@selector(parseLoginResponse:) failSelector:nil retryOnFail:NO humanDesc:@"Loggin In..." userInfo:nil];
}

- (void) parseLoginResponse:(ARISServiceResult *)result
{
  if(!result.resultData) { _ARIS_NOTIF_SEND_(@"SERVICES_LOGIN_FAILED",nil,nil); return; }
  User *user = [[User alloc] initWithDictionary:(NSDictionary *)result.resultData];
  _ARIS_NOTIF_SEND_(@"SERVICES_LOGIN_RECEIVED",nil,@{@"user":user});
}

- (void) resetPasswordForEmail:(NSString *)email
{
  NSDictionary *args =
    @{
      @"email":email
    };
  [connection performAsynchronousRequestWithService:@"users" method:@"requestForgotPasswordEmail" arguments:args handler:self successSelector:@selector(parseResetPassword:) failSelector:nil retryOnFail:NO humanDesc:@"Sending Reset Email..." userInfo:nil];
}

- (void) parseResetPassword:(ARISServiceResult *)result
{
    //do nothing
}

- (void) changePasswordFrom:(NSString *)oldp to:(NSString *)newp
{
    //requires username/pass rather than auth token
  NSDictionary *args =
    @{
      @"user_name":_MODEL_PLAYER_.user_name,
      @"old_password":oldp,
      @"new_password":newp
    };
  [connection performAsynchronousRequestWithService:@"users" method:@"changePassword" arguments:args handler:self successSelector:@selector(parseResetPassword:) failSelector:nil retryOnFail:NO humanDesc:@"Changing Password..." userInfo:nil];
}

- (void) parseChangePassword:(ARISServiceResult *)result
{
  if(!result.resultData) { _ARIS_NOTIF_SEND_(@"SERVICES_UPDATE_USER_FAILED",nil,nil); return; }
  User *user = [[User alloc] initWithDictionary:(NSDictionary *)result.resultData];
  _ARIS_NOTIF_SEND_(@"SERVICES_UPDATE_USER_RECEIVED",nil,@{@"user":user});
}

- (void) updatePlayerName:(NSString *)display_name
{
  NSDictionary *args =
    @{
      @"user_id":[NSNumber numberWithLong:_MODEL_PLAYER_.user_id],
      @"display_name":display_name
    };
  [connection performAsynchronousRequestWithService:@"users" method:@"updateUser" arguments:args handler:self successSelector:@selector(parseResetPassword:) failSelector:nil retryOnFail:NO humanDesc:@"Updating Player..." userInfo:nil];
}

- (void) parseUpdatePlayerName:(ARISServiceResult *)result
{
  if(!result.resultData) { _ARIS_NOTIF_SEND_(@"SERVICES_UPDATE_USER_FAILED",nil,nil); return; }
  User *user = [[User alloc] initWithDictionary:(NSDictionary *)result.resultData];
  _ARIS_NOTIF_SEND_(@"SERVICES_UPDATE_USER_RECEIVED",nil,@{@"user":user});
}

- (void) updatePlayerMedia:(Media *)media
{
    NSDictionary *args =
    @{
      @"user_id":[NSNumber numberWithLong:_MODEL_PLAYER_.user_id],
      @"media":
        @{
          @"file_name":[media.localURL absoluteString],
          @"data":[media.data base64EncodedStringWithOptions:0]
        }
     };
    NSLog(@"MT: Beginning upload of player media.");
    [connection performAsynchronousRequestWithService:@"users" method:@"updateUser" arguments:args handler:self successSelector:@selector(parseUpdatePlayerMedia:) failSelector:@selector(updatePlayerMediaFailed) retryOnFail:YES humanDesc:@"Updating Player..." userInfo:nil];
}
- (void) parseUpdatePlayerMedia:(ARISServiceResult *)result
{
  NSLog(@"MT: Parsing result of player media upload.");
  if(!result.resultData) { _ARIS_NOTIF_SEND_(@"SERVICES_UPDATE_USER_FAILED",nil,nil); return; }
  User *user = [[User alloc] initWithDictionary:(NSDictionary *)result.resultData];
  _ARIS_NOTIF_SEND_(@"SERVICES_UPDATE_USER_RECEIVED",nil,@{@"user":user});
}
- (void) updatePlayerMediaFailed
{
  NSLog(@"MT: Failed to upload player media.");
}


- (NSArray *) parseGames:(NSArray *)gamesDicts
{
    NSMutableArray *games= [[NSMutableArray alloc] init];

    for(long i = 0; i < gamesDicts.count; i++)
        [games addObject:[[Game alloc] initWithDictionary:gamesDicts[i]]];

    return games;
}

- (void) fetchGame:(long)game_id
{
       NSDictionary *args =
        @{
          @"game_id":[NSNumber numberWithLong:game_id]
        };
  [connection performAsynchronousRequestWithService:@"games" method:@"getFullGame" arguments:args handler:self successSelector:@selector(parseGame:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Game..." userInfo:nil];
}
- (void) parseGame:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_GAME_RECEIVED", nil, @{@"game":[[Game alloc] initWithDictionary:(NSDictionary *)result.resultData]});
}

- (void) fetchNearbyGames
{
    NSDictionary *args =
        @{
            @"user_id":[NSString stringWithFormat:@"%ld",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"page":[NSNumber numberWithLong:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getNearbyGamesForPlayer" arguments:args handler:self successSelector:@selector(parseNearbyGames:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Nearby Games..." userInfo:nil];
}
- (void) parseNearbyGames:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_NEARBY_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchAnywhereGames
{
    NSDictionary *args =
        @{
            @"user_id":[NSString stringWithFormat:@"%ld",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"page":[NSNumber numberWithLong:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getAnywhereGamesForPlayer" arguments:args handler:self successSelector:@selector(parseAnywhereGames:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Anywhere Games..." userInfo:nil];
}
- (void) parseAnywhereGames:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_ANYWHERE_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchRecentGames
{
    NSDictionary *args =
        @{
            @"user_id":[NSString stringWithFormat:@"%ld",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"page":[NSNumber numberWithLong:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getRecentGamesForPlayer" arguments:args handler:self successSelector:@selector(parseRecentGames:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Recent Games..." userInfo:nil];
}
- (void) parseRecentGames:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_RECENT_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchPopularGamesInterval:(NSString *)i
{
    NSDictionary *args =
        @{
            @"user_id":[NSString stringWithFormat:@"%ld",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"interval":i,//@"MONTH",
            @"page":[NSNumber numberWithLong:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getPopularGamesForPlayer" arguments:args handler:self successSelector:@selector(parsePopularGames:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Popular Games..." userInfo:nil];
}
- (void) parsePopularGames:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_POPULAR_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchSearchGames:(NSString *)search page:(long)page
{
    NSDictionary *args =
        @{
            @"user_id":[NSString stringWithFormat:@"%ld",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"text":search,
            @"page":[NSNumber numberWithLong:page]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getSearchGamesForPlayer" arguments:args handler:self successSelector:@selector(parseSearchGames:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Search for Games..." userInfo:nil];
}
- (void) parseSearchGames:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_SEARCH_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchMineGames
{
    NSDictionary *args =
        @{
            @"user_id":[NSString stringWithFormat:@"%ld",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"page":[NSNumber numberWithLong:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getPlayerGamesForPlayer" arguments:args handler:self successSelector:@selector(parseMineGames:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching My Games..." userInfo:nil];
}
- (void) parseMineGames:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_MINE_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchPlayerPlayedGame:(long)game_id
{
    NSDictionary *args =
        @{
            @"game_id":[NSString stringWithFormat:@"%ld",game_id],
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getPlayerPlayedGame" arguments:args handler:self successSelector:@selector(parsePlayerPlayedGame:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Game Progress..." userInfo:nil];
}
- (void) parsePlayerPlayedGame:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_PLAYED_GAME_RECEIVED", nil, (NSDictionary *)result.resultData);
}

- (void) gameFetchFailed        { _ARIS_NOTIF_SEND_(@"SERVICES_GAME_FETCH_FAILED",        nil, nil); }
- (void) maintenanceFetchFailed { _ARIS_NOTIF_SEND_(@"SERVICES_MAINTENANCE_FETCH_FAILED", nil, nil); }
- (void) playerFetchFailed      { _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_FETCH_FAILED",      nil, nil); }
- (void) mediaFetchFailed       { _ARIS_NOTIF_SEND_(@"SERVICES_MEDIA_FETCH_FAILED",       nil, nil); }

- (void) fetchUsers
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"users" method:@"getUsersForGame" arguments:args handler:self successSelector:@selector(parseUsers:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Users..." userInfo:nil];
}
- (void) parseUsers:(ARISServiceResult *)result
{
    NSArray *userDicts = (NSArray *)result.resultData;
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for(long i = 0; i < userDicts.count; i++)
        users[i] = [[User alloc] initWithDictionary:userDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_USERS_RECEIVED", nil, @{@"users":users});
}

- (void) fetchScenes
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"scenes" method:@"getScenesForGame" arguments:args handler:self successSelector:@selector(parseScenes:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Scenes..." userInfo:nil];
}
- (void) parseScenes:(ARISServiceResult *)result
{
    NSArray *sceneDicts = (NSArray *)result.resultData;
    NSMutableArray *scenes = [[NSMutableArray alloc] init];
    for(long i = 0; i < sceneDicts.count; i++)
        scenes[i] = [[Scene alloc] initWithDictionary:sceneDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_SCENES_RECEIVED", nil, @{@"scenes":scenes});
}

- (void) fetchARTargets
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"ar_targets" method:@"getARTargetsForGame" arguments:args handler:self successSelector:@selector(parseARTargets:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching ARTargets..." userInfo:nil];
}
- (void) parseARTargets:(ARISServiceResult *)result
{
    NSArray *arTargetDicts = (NSArray *)result.resultData;
    NSMutableArray *ar_targets = [[NSMutableArray alloc] init];
    for(long i = 0; i < arTargetDicts.count; i++)
        ar_targets[i] = [[ARTarget alloc] initWithDictionary:arTargetDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_AR_TARGETS_RECEIVED", nil, @{@"ar_targets":ar_targets});
}

//creates player scene for game if not already created
- (void) touchSceneForPlayer
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"client" method:@"touchSceneForPlayer" arguments:args handler:self successSelector:@selector(parseSceneTouch:) failSelector:@selector(maintenanceFetchFailed) retryOnFail:NO humanDesc:@"Preparing Game..." userInfo:nil]; //technically a game fetch
}
- (void) parseSceneTouch:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_SCENE_TOUCHED", nil, nil);
}

- (void) fetchGroups
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
    };
  [connection performAsynchronousRequestWithService:@"groups" method:@"getGroupsForGame" arguments:args handler:self successSelector:@selector(parseGroups:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Groups..." userInfo:nil];
}
- (void) parseGroups:(ARISServiceResult *)result
{
    NSArray *groupDicts = (NSArray *)result.resultData;
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    for(long i = 0; i < groupDicts.count; i++)
        groups[i] = [[Group alloc] initWithDictionary:groupDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_GROUPS_RECEIVED", nil, @{@"groups":groups});
}

//creates player group for game if not already created
- (void) touchGroupForPlayer
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"client" method:@"touchGroupForPlayer" arguments:args handler:self successSelector:@selector(parseGroupTouch:) failSelector:@selector(maintenanceFetchFailed) retryOnFail:NO humanDesc:@"Preparing Game..." userInfo:nil]; //technically a game fetch
}
- (void) parseGroupTouch:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_GROUP_TOUCHED", nil, nil);
}

- (void) fetchMedias
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"media" method:@"getMediaForGame" arguments:args handler:self successSelector:@selector(parseMedias:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Media..." userInfo:nil];
}
- (void) parseMedias:(ARISServiceResult *)result //note that this intentionally only sends the dictionaries, not fully populated Media objects
{
    NSArray *mediaDicts = (NSArray *)result.resultData;
    _ARIS_NOTIF_SEND_(@"SERVICES_MEDIAS_RECEIVED", nil, @{@"medias":mediaDicts});
}

- (void) fetchPlaques
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"plaques" method:@"getPlaquesForGame" arguments:args handler:self successSelector:@selector(parsePlaques:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Plaques..." userInfo:nil];
}
- (void) parsePlaques:(ARISServiceResult *)result
{
    NSArray *plaqueDicts = (NSArray *)result.resultData;
    NSMutableArray *plaques = [[NSMutableArray alloc] init];
    for(long i = 0; i < plaqueDicts.count; i++)
        plaques[i] = [[Plaque alloc] initWithDictionary:plaqueDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAQUES_RECEIVED", nil, @{@"plaques":plaques});
}

- (void) fetchItems
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"items" method:@"getItemsForGame" arguments:args handler:self successSelector:@selector(parseItems:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Items..." userInfo:nil];
}
- (void) parseItems:(ARISServiceResult *)result
{
    NSArray *itemDicts = (NSArray *)result.resultData;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(long i = 0; i < itemDicts.count; i++)
        items[i] = [[Item alloc] initWithDictionary:itemDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_ITEMS_RECEIVED", nil, @{@"items":items});
}

//creates player owned item instances (qty 0) for all items not already owned
//makes any item qty transfers 100000x easier
- (void) touchItemsForPlayer
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"client" method:@"touchItemsForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerItemTouch:) failSelector:@selector(maintenanceFetchFailed) retryOnFail:NO humanDesc:@"Preparing Items... " userInfo:nil]; //technically a game fetch
}
- (void) parsePlayerItemTouch:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_INSTANCES_TOUCHED", nil, nil);
}

//creates game owned item instances (qty 0) for all items not already owned
//makes any item qty transfers 100000x easier
- (void) touchItemsForGame
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"client" method:@"touchItemsForGame" arguments:args handler:self successSelector:@selector(parseGameItemTouch:) failSelector:@selector(maintenanceFetchFailed) retryOnFail:NO humanDesc:@"Preparing Items... " userInfo:nil]; //technically a game fetch
}
- (void) parseGameItemTouch:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_GAME_INSTANCES_TOUCHED", nil, nil);
}

//creates game owned item instances (qty 0) for all items not already owned
//makes any item qty transfers 100000x easier
- (void) touchItemsForGroups
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
  [connection performAsynchronousRequestWithService:@"client" method:@"touchItemsForGroups" arguments:args handler:self successSelector:@selector(parseGroupItemTouch:) failSelector:@selector(maintenanceFetchFailed) retryOnFail:NO humanDesc:@"Preparing Items... " userInfo:nil]; //technically a game fetch
}
- (void) parseGroupItemTouch:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_GROUP_INSTANCES_TOUCHED", nil, nil);
}

- (void) fetchDialogs
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogsForGame" arguments:args handler:self successSelector:@selector(parseDialogs:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Dialogs..." userInfo:nil];
}
- (void) parseDialogs:(ARISServiceResult *)result
{
    NSArray *dialogDicts = (NSArray *)result.resultData;
    NSMutableArray *dialogs = [[NSMutableArray alloc] init];
    for(long i = 0; i < dialogDicts.count; i++)
        dialogs[i] = [[Dialog alloc] initWithDictionary:dialogDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOGS_RECEIVED", nil, @{@"dialogs":dialogs});
}

- (void) fetchDialogCharacters
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogCharactersForGame" arguments:args handler:self successSelector:@selector(parseDialogCharacters:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Characters..." userInfo:nil];
}
- (void) parseDialogCharacters:(ARISServiceResult *)result
{
    NSArray *dialogCharacterDicts = (NSArray *)result.resultData;
    NSMutableArray *dialogCharacters = [[NSMutableArray alloc] init];
    for(long i = 0; i < dialogCharacterDicts.count; i++)
        dialogCharacters[i] = [[DialogCharacter alloc] initWithDictionary:dialogCharacterDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_CHARACTERS_RECEIVED", nil, @{@"dialogCharacters":dialogCharacters});
}

- (void) fetchDialogScripts
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
    };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogScriptsForGame" arguments:args handler:self successSelector:@selector(parseDialogScripts:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Scripts..." userInfo:nil];
}
- (void) parseDialogScripts:(ARISServiceResult *)result
{
    NSArray *dialogScriptDicts = (NSArray *)result.resultData;
    NSMutableArray *dialogScripts = [[NSMutableArray alloc] init];
    for(long i = 0; i < dialogScriptDicts.count; i++)
        dialogScripts[i] = [[DialogScript alloc] initWithDictionary:dialogScriptDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_SCRIPTS_RECEIVED", nil, @{@"dialogScripts":dialogScripts});
}

- (void) fetchDialogOptions
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
    };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogOptionsForGame" arguments:args handler:self successSelector:@selector(parseDialogOptions:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Options..." userInfo:nil];
}
- (void) parseDialogOptions:(ARISServiceResult *)result
{
    NSArray *dialogOptionDicts = (NSArray *)result.resultData;
    NSMutableArray *dialogOptions = [[NSMutableArray alloc] init];
    for(long i = 0; i < dialogOptionDicts.count; i++)
        dialogOptions[i] = [[DialogOption alloc] initWithDictionary:dialogOptionDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_OPTIONS_RECEIVED", nil, @{@"dialogOptions":dialogOptions});
}

- (void) fetchWebPages
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"web_pages" method:@"getWebPagesForGame" arguments:args handler:self successSelector:@selector(parseWebPages:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Web Pages..." userInfo:nil];
}
- (void) parseWebPages:(ARISServiceResult *)result
{
    NSArray *webPageDicts = (NSArray *)result.resultData;
    NSMutableArray *webPages = [[NSMutableArray alloc] init];
    for(long i = 0; i < webPageDicts.count; i++)
        webPages[i] = [[WebPage alloc] initWithDictionary:webPageDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_WEB_PAGES_RECEIVED", nil, @{@"webPages":webPages});
}

- (void) fetchNotes
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"notes" method:@"getNotesForGame" arguments:args handler:self successSelector:@selector(parseNotes:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Notes..." userInfo:nil];
}
- (void) parseNotes:(ARISServiceResult *)result
{
    NSArray *noteDicts = (NSArray *)result.resultData;
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    for(long i = 0; i < noteDicts.count; i++)
        notes[i] = [[Note alloc] initWithDictionary:noteDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_NOTES_RECEIVED", nil, @{@"notes":notes});
}

- (void) fetchNoteComments
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"note_comments" method:@"getNoteCommentsForGame" arguments:args handler:self successSelector:@selector(parseNoteComments:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Comments..." userInfo:nil];
}
- (void) parseNoteComments:(ARISServiceResult *)result
{
    NSArray *noteCommentDicts = (NSArray *)result.resultData;
    NSMutableArray *noteComments = [[NSMutableArray alloc] init];
    for(long i = 0; i < noteCommentDicts.count; i++)
        noteComments[i] = [[NoteComment alloc] initWithDictionary:noteCommentDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_NOTE_COMMENTS_RECEIVED", nil, @{@"note_comments":noteComments});
}


- (void) fetchTags
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"tags" method:@"getTagsForGame" arguments:args handler:self successSelector:@selector(parseTags:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Tags..." userInfo:nil];
}
- (void) parseTags:(ARISServiceResult *)result
{
    NSArray *tagDicts = (NSArray *)result.resultData;
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    for(long i = 0; i < tagDicts.count; i++)
        tags[i] = [[Tag alloc] initWithDictionary:tagDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_TAGS_RECEIVED", nil, @{@"tags":tags});
}


- (void) fetchObjectTags
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"tags" method:@"getObjectTagsForGame" arguments:args handler:self successSelector:@selector(parseObjectTags:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Tags..." userInfo:nil];
}
- (void) parseObjectTags:(ARISServiceResult *)result
{
    NSArray *objectTagDicts = (NSArray *)result.resultData;
    NSMutableArray *objectTags = [[NSMutableArray alloc] init];
    for(long i = 0; i < objectTagDicts.count; i++)
        objectTags[i] = [[ObjectTag alloc] initWithDictionary:objectTagDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_OBJECT_TAGS_RECEIVED", nil, @{@"object_tags":objectTags});
}

- (void) fetchEvents
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"events" method:@"getEventsForGame" arguments:args handler:self successSelector:@selector(parseEvents:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Events..." userInfo:nil];
}
- (void) parseEvents:(ARISServiceResult *)result
{
    NSArray *eventDicts = (NSArray *)result.resultData;
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for(long i = 0; i < eventDicts.count; i++)
        events[i] = [[Event alloc] initWithDictionary:eventDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_EVENTS_RECEIVED", nil, @{@"events":events});
}

- (void) fetchQuests
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"quests" method:@"getQuestsForGame" arguments:args handler:self successSelector:@selector(parseQuests:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Quests..." userInfo:nil];
}
- (void) parseQuests:(ARISServiceResult *)result
{
    NSArray *questDicts = (NSArray *)result.resultData;
    NSMutableArray *quests = [[NSMutableArray alloc] init];
    for(long i = 0; i < questDicts.count; i++)
        quests[i] = [[Quest alloc] initWithDictionary:questDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_QUESTS_RECEIVED", nil, @{@"quests":quests});
}

- (void) fetchInstances
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"owner_id":[NSNumber numberWithLong:0] //could leave this out and get same result, but would rather be explicit
      };
    [connection performAsynchronousRequestWithService:@"instances" method:@"getInstancesForGame" arguments:args handler:self successSelector:@selector(parseInstances:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Instances..." userInfo:nil];
}
- (void) parseInstances:(ARISServiceResult *)result
{
    NSArray *instanceDicts = (NSArray *)result.resultData;
    NSMutableArray *instances = [[NSMutableArray alloc] init];
    for(long i = 0; i < instanceDicts.count; i++)
        instances[i] = [[Instance alloc] initWithDictionary:instanceDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_INSTANCES_RECEIVED", nil, @{@"instances":instances});
}

- (void) fetchTriggers
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"triggers" method:@"getTriggersForGame" arguments:args handler:self successSelector:@selector(parseTriggers:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Triggers..." userInfo:nil];
}
- (void) parseTriggers:(ARISServiceResult *)result
{
    NSArray *triggerDicts = (NSArray *)result.resultData;
    NSMutableArray *triggers = [[NSMutableArray alloc] init];
    for(long i = 0; i < triggerDicts.count; i++)
        triggers[i] = [[Trigger alloc] initWithDictionary:triggerDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_TRIGGERS_RECEIVED", nil, @{@"triggers":triggers});
}

- (void) fetchFactories
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"factories" method:@"getFactoriesForGame" arguments:args handler:self successSelector:@selector(parseFactories:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Factories..." userInfo:nil];
}
- (void) parseFactories:(ARISServiceResult *)result
{
    NSArray *factoryDicts = (NSArray *)result.resultData;
    NSMutableArray *factories = [[NSMutableArray alloc] init];
    for(long i = 0; i < factoryDicts.count; i++)
        factories[i] = [[Factory alloc] initWithDictionary:factoryDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_FACTORIES_RECEIVED", nil, @{@"factories":factories});
}

- (void) fetchOverlays
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"overlays" method:@"getOverlaysForGame" arguments:args handler:self successSelector:@selector(parseOverlays:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Overlays..." userInfo:nil];
}
- (void) parseOverlays:(ARISServiceResult *)result
{
    NSArray *overlayDicts = (NSArray *)result.resultData;
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
    for(long i = 0; i < overlayDicts.count; i++)
        overlays[i] = [[Overlay alloc] initWithDictionary:overlayDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_OVERLAYS_RECEIVED", nil, @{@"overlays":overlays});
}

- (void) fetchTabs
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"tabs" method:@"getTabsForGame" arguments:args handler:self successSelector:@selector(parseTabs:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Tabs..." userInfo:nil];
}
- (void) parseTabs:(ARISServiceResult *)result
{
    NSArray *tabDicts = (NSArray *)result.resultData;
    NSMutableArray *tabs = [[NSMutableArray alloc] init];
    for(long i = 0; i < tabDicts.count; i++)
        tabs[i] = [[Tab alloc] initWithDictionary:tabDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_TABS_RECEIVED", nil, @{@"tabs":tabs});
}

- (void) fetchRequirementRoots
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"requirements" method:@"getRequirementRootPackagesForGame" arguments:args handler:self successSelector:@selector(parseRequirementRootPackages:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Requirement Roots..." userInfo:nil];
}
- (void) parseRequirementRootPackages:(ARISServiceResult *)result
{
    NSArray *rrpDicts = (NSArray *)result.resultData;
    NSMutableArray *rrps = [[NSMutableArray alloc] init];
    for(long i = 0; i < rrpDicts.count; i++)
        rrps[i] = [[RequirementRootPackage alloc] initWithDictionary:rrpDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_REQUIREMENT_ROOT_PACKAGES_RECEIVED", nil, @{@"requirement_root_packages":rrps});
}

- (void) fetchRequirementAnds
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"requirements" method:@"getRequirementAndPackagesForGame" arguments:args handler:self successSelector:@selector(parseRequirementAndPackages:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Requirement Ands..." userInfo:nil];
}
- (void) parseRequirementAndPackages:(ARISServiceResult *)result
{
    NSArray *rapDicts = (NSArray *)result.resultData;
    NSMutableArray *raps = [[NSMutableArray alloc] init];
    for(long i = 0; i < rapDicts.count; i++)
        raps[i] = [[RequirementAndPackage alloc] initWithDictionary:rapDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_REQUIREMENT_AND_PACKAGES_RECEIVED", nil, @{@"requirement_and_packages":raps});
}

- (void) fetchRequirementAtoms
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"requirements" method:@"getRequirementAtomsForGame" arguments:args handler:self successSelector:@selector(parseRequirementAtoms:) failSelector:@selector(gameFetchFailed) retryOnFail:NO humanDesc:@"Fetching Requirement Atoms..." userInfo:nil];
}
- (void) parseRequirementAtoms:(ARISServiceResult *)result
{
    NSArray *aDicts = (NSArray *)result.resultData;
    NSMutableArray *as = [[NSMutableArray alloc] init];
    for(long i = 0; i < aDicts.count; i++)
        as[i] = [[RequirementAtom alloc] initWithDictionary:aDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_REQUIREMENT_ATOMS_RECEIVED", nil, @{@"requirement_atoms":as});
}


- (void) fetchLogsForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getLogsForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerLogs:) failSelector:@selector(playerFetchFailed) retryOnFail:NO humanDesc:@"Fetching Current Logs..." userInfo:nil];
}
- (void) parsePlayerLogs:(ARISServiceResult *)result
{
    NSArray *logDicts = (NSArray *)result.resultData;
    NSMutableArray *logs = [[NSMutableArray alloc] init];
    for(long i = 0; i < logDicts.count; i++)
        logs[i] = [[Log alloc] initWithDictionary:logDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_LOGS_RECEIVED", nil, @{@"logs":logs});
}

- (void) fetchSceneForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getSceneForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerScene:) failSelector:@selector(playerFetchFailed) retryOnFail:NO humanDesc:@"Fetching Current Scene..." userInfo:nil];
}
- (void) parsePlayerScene:(ARISServiceResult *)result
{
    Scene *s;
    if(result.resultData && ![result.resultData isEqual:[NSNull null]])
        s = [[Scene alloc] initWithDictionary:(NSDictionary *)result.resultData];
    else
        s = [[Scene alloc] init];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_SCENE_RECEIVED", nil, @{@"scene":s});
}

- (void) fetchGroupForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getGroupForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerGroup:) failSelector:@selector(playerFetchFailed) retryOnFail:NO humanDesc:@"Fetching Current Group..." userInfo:nil];
}
- (void) parsePlayerGroup:(ARISServiceResult *)result
{
    Group *s;
    if(result.resultData && ![result.resultData isEqual:[NSNull null]])
        s = [[Group alloc] initWithDictionary:(NSDictionary *)result.resultData];
    else
        s = [[Group alloc] init];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_GROUP_RECEIVED", nil, @{@"group":s});
}

- (void) fetchInstancesForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"owner_id":[NSNumber numberWithLong:_MODEL_PLAYER_.user_id]
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getInstancesForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerInstances:) failSelector:@selector(playerFetchFailed) retryOnFail:NO humanDesc:@"Fetching Current Instances..." userInfo:nil];
}
- (void) parsePlayerInstances:(ARISServiceResult *)result
{
    NSArray *instanceDicts = (NSArray *)result.resultData;
    NSMutableArray *instances = [[NSMutableArray alloc] init];
    for(long i = 0; i < instanceDicts.count; i++)
        instances[i] = [[Instance alloc] initWithDictionary:instanceDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_INSTANCES_RECEIVED", nil, @{@"instances":instances});
}

- (void) fetchTriggersForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"tick_factories":[NSNumber numberWithLong:1]
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getTriggersForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerTriggers:) failSelector:@selector(playerFetchFailed) retryOnFail:NO humanDesc:@"Fetching Current Triggers..." userInfo:nil];
}
- (void) parsePlayerTriggers:(ARISServiceResult *)result
{
    NSArray *triggerDicts = (NSArray *)result.resultData;
    NSMutableArray *triggers = [[NSMutableArray alloc] init];
    for(long i = 0; i < triggerDicts.count; i++)
        triggers[i] = [[Trigger alloc] initWithDictionary:triggerDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_TRIGGERS_RECEIVED", nil, @{@"triggers":triggers});
}

- (void) fetchOverlaysForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getOverlaysForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerOverlays:) failSelector:@selector(playerFetchFailed) retryOnFail:NO humanDesc:@"Fetching Current Overlays..." userInfo:nil];
}
- (void) parsePlayerOverlays:(ARISServiceResult *)result
{
    NSArray *overlayDicts = (NSArray *)result.resultData;
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
    for(long i = 0; i < overlayDicts.count; i++)
        overlays[i] = [[Overlay alloc] initWithDictionary:overlayDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_OVERLAYS_RECEIVED", nil, @{@"overlays":overlays});
}

- (void) fetchQuestsForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getQuestsForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerQuests:) failSelector:@selector(playerFetchFailed) retryOnFail:NO humanDesc:@"Fetching Current Quests..." userInfo:nil];
}
- (void) parsePlayerQuests:(ARISServiceResult *)result
{
    NSDictionary *quests =
    @{
      @"active"   : [[NSMutableArray alloc] init],
      @"complete" : [[NSMutableArray alloc] init]
    };

    NSArray *activeQuestDicts   = ((NSDictionary *)result.resultData)[@"active"];
    for(long i = 0; i < activeQuestDicts.count; i++)
        quests[@"active"][i] = [[Quest alloc] initWithDictionary:activeQuestDicts[i]];

    NSArray *completeQuestDicts = ((NSDictionary *)result.resultData)[@"complete"];
    for(long i = 0; i < completeQuestDicts.count; i++)
        quests[@"complete"][i] = [[Quest alloc] initWithDictionary:completeQuestDicts[i]];

    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_QUESTS_RECEIVED", nil, quests);
}

- (void) fetchTabsForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getTabsForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerTabs:) failSelector:@selector(playerFetchFailed) retryOnFail:NO humanDesc:@"Fetching Current Tabs..." userInfo:nil];
}
- (void) parsePlayerTabs:(ARISServiceResult *)result
{
    NSArray *tabDicts = (NSArray *)result.resultData;
    NSMutableArray *tabs = [[NSMutableArray alloc] init];
    for(long i = 0; i < tabDicts.count; i++)
        tabs[i] = [[Tab alloc] initWithDictionary:tabDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_TABS_RECEIVED", nil, @{@"tabs":tabs});
}

- (void) fetchOptionsForPlayerForDialog:(long)dialog_id script:(long)dialog_script_id //doesn't need to be called during game load
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"dialog_id":[NSNumber numberWithLong:dialog_id],
      @"dialog_script_id":[NSNumber numberWithLong:dialog_script_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getOptionsForPlayerForDialogScript" arguments:args handler:self successSelector:@selector(parsePlayerOptionsForScript:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Current Options..." userInfo:@{@"dialog_script_id":[NSNumber numberWithLong:dialog_script_id],@"dialog_id":[NSNumber numberWithLong:dialog_id]}];
}
- (void) parsePlayerOptionsForScript:(ARISServiceResult *)result
{
    NSArray *playerOptionsDicts = (NSArray *)result.resultData;
    NSMutableArray *options = [[NSMutableArray alloc] init];
    for(long i = 0; i < playerOptionsDicts.count; i++)
        options[i] = [[DialogOption alloc] initWithDictionary:playerOptionsDicts[i]];
    NSDictionary *uInfo = @{@"options":options,
                            @"dialog_id":result.userInfo[@"dialog_id"],
                            @"dialog_script_id":result.userInfo[@"dialog_script_id"]};
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_SCRIPT_OPTIONS_RECEIVED", nil, uInfo);
}

- (void) setQtyForInstanceId:(long)instance_id qty:(long)qty
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"instance_id":[NSNumber numberWithLong:instance_id],
      @"qty":[NSNumber numberWithLong:qty],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"setQtyForInstance" arguments:args handler:self successSelector:@selector(parseSetQtyForInstance:) failSelector:nil retryOnFail:NO humanDesc:@"Updating Inventory..." userInfo:nil];
}
- (void) parseSetQtyForInstance:(ARISServiceResult *)result
{
    //nothing need be done
}

- (void) setPlayerSceneId:(long)scene_id
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"scene_id":[NSNumber numberWithLong:scene_id]
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"setPlayerScene" arguments:args handler:self successSelector:@selector(parseSetPlayerScene:) failSelector:nil retryOnFail:NO humanDesc:@"Updating Scene..." userInfo:nil];
}
- (void) parseSetPlayerScene:(ARISServiceResult *)result
{
    //nothing need be done
}

- (void) setPlayerGroupId:(long)group_id
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"group_id":[NSNumber numberWithLong:group_id]
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"setPlayerGroup" arguments:args handler:self successSelector:@selector(parseSetPlayerGroup:) failSelector:nil retryOnFail:NO humanDesc:@"Updating Group..." userInfo:nil];
}
- (void) parseSetPlayerGroup:(ARISServiceResult *)result
{
    //nothing need be done
}

- (void) dropItem:(long)item_id qty:(long)qty
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"item_id":[NSNumber numberWithLong:item_id],
      @"qty":[NSNumber numberWithLong:qty],
      @"latitude":[NSNumber numberWithDouble:_MODEL_PLAYER_.location.coordinate.latitude],
      @"longitude":[NSNumber numberWithDouble:_MODEL_PLAYER_.location.coordinate.longitude]
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"dropItem" arguments:args handler:self successSelector:@selector(parseDropItem:) failSelector:nil retryOnFail:NO humanDesc:@"Updating Map..." userInfo:nil];
}
- (void) parseDropItem:(ARISServiceResult *)result
{
    //nothin
}

- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr
{
    NSMutableDictionary *args =
    [@{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"user_id":[NSNumber numberWithLong:_MODEL_PLAYER_.user_id],
      @"name":n.name,
      @"description":n.desc,
     } mutableCopy];
    if(m)
    {
      args[@"media"] =
        @{
           @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
           @"file_name":[m.localURL absoluteString],
          @"data":[m.data base64EncodedStringWithOptions:0]
        };
      CLLocation *loc = tr ? tr.location : nil;
      [_MODEL_LOGS_ playerUploadedMedia:0 Location:loc];
      NSString *mediaType = [m type];
      if      ([mediaType isEqualToString:@"IMAGE"]) [_MODEL_LOGS_ playerUploadedMediaImage:0 Location:loc];
      else if ([mediaType isEqualToString:@"AUDIO"]) [_MODEL_LOGS_ playerUploadedMediaAudio:0 Location:loc];
      else if ([mediaType isEqualToString:@"VIDEO"]) [_MODEL_LOGS_ playerUploadedMediaVideo:0 Location:loc];
    }
    if(t)
    {
        args[@"tag_id"] = [NSNumber numberWithLong:t.tag_id];
    }
    if(tr)
    {
      args[@"trigger"] =
        @{
           @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
           @"latitude":[NSNumber numberWithDouble:tr.location.coordinate.latitude],
           @"longitude":[NSNumber numberWithDouble:tr.location.coordinate.longitude]
        };
    }
    [connection performAsynchronousRequestWithService:@"notes" method:@"createNote" arguments:args handler:self successSelector:@selector(parseCreateNote:) failSelector:nil retryOnFail:YES humanDesc:@"Creating Note..." userInfo:nil];
}
- (void) parseCreateNote:(ARISServiceResult *)result
{
    NSDictionary *noteDict= (NSDictionary *)result.resultData;
    Note *note = [[Note alloc] initWithDictionary:noteDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_NOTE_RECEIVED", nil, @{@"note":note});

    // triggerGameUpdateForLogEvent
    [_MODEL_GAME_ requestPlayerData];
}

- (void) updateNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr
{
    NSMutableDictionary *args =
    [@{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"note_id":[NSNumber numberWithLong:n.note_id],
      @"user_id":[NSNumber numberWithLong:n.user_id],
      @"name":n.name,
      @"description":n.desc,
     } mutableCopy];
    if(m)
    {
      args[@"media"] =
        @{
           @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
           @"file_name":[m.localURL absoluteString],
           @"data":[m.data base64EncodedStringWithOptions:0]
        };
    }
    if(t)
    {
        args[@"tag_id"] = [NSNumber numberWithLong:t.tag_id];
    }
    else
    {
        args[@"tag_id"] = [NSNumber numberWithLong:0];
    }
    if(tr)
    {
      args[@"trigger"] =
        @{
           @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
           @"latitude":[NSNumber numberWithDouble:tr.location.coordinate.latitude],
           @"longitude":[NSNumber numberWithDouble:tr.location.coordinate.longitude]
        };
    }
    [connection performAsynchronousRequestWithService:@"notes" method:@"updateNote" arguments:args handler:self successSelector:@selector(parseUpdateNote:) failSelector:nil retryOnFail:NO humanDesc:@"Updating Note..." userInfo:nil];
}
- (void) parseUpdateNote:(ARISServiceResult *)result
{
    NSDictionary *noteDict= (NSDictionary *)result.resultData;
    Note *note = [[Note alloc] initWithDictionary:noteDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_NOTE_RECEIVED", nil, @{@"note":note});
}

- (void) deleteNoteId:(long)note_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"note_id":[NSNumber numberWithLong:note_id],
     };
    [connection performAsynchronousRequestWithService:@"notes" method:@"deleteNote" arguments:args handler:self successSelector:@selector(parseDeleteNote:) failSelector:nil retryOnFail:NO humanDesc:@"Deleting Note..." userInfo:nil];
}
- (void) parseDeleteNote:(ARISServiceResult *)result
{
    //nothing
}


- (void) createNoteComment:(NoteComment *)n
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"user_id":[NSNumber numberWithLong:_MODEL_PLAYER_.user_id],
      @"note_id":[NSNumber numberWithLong:n.note_id],
      @"name":n.name,
      @"description":n.desc,
      };
    [connection performAsynchronousRequestWithService:@"note_comments" method:@"createNoteComment" arguments:args handler:self successSelector:@selector(parseCreateNoteComment:) failSelector:nil retryOnFail:NO humanDesc:@"Creating Comment..." userInfo:nil];
}
- (void) parseCreateNoteComment:(ARISServiceResult *)result
{
    NSDictionary *noteCommentDict= (NSDictionary *)result.resultData;
    NoteComment *noteComment = [[NoteComment alloc] initWithDictionary:noteCommentDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_NOTE_COMMENT_RECEIVED", nil, @{@"note_comment":noteComment});
}

- (void) updateNoteComment:(NoteComment *)n
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"note_comment_id":[NSNumber numberWithLong:n.note_comment_id],
      @"user_id":[NSNumber numberWithLong:n.user_id],
      @"note_id":[NSNumber numberWithLong:n.note_id],
      @"name":n.name,
      @"description":n.desc,
     };
    [connection performAsynchronousRequestWithService:@"note_comments" method:@"updateNoteComment" arguments:args handler:self successSelector:@selector(parseUpdateNoteComment:) failSelector:nil retryOnFail:NO humanDesc:@"Updating Comment..." userInfo:nil];
}
- (void) parseUpdateNoteComment:(ARISServiceResult *)result
{
    NSDictionary *noteCommentDict= (NSDictionary *)result.resultData;
    NoteComment *noteComment = [[NoteComment alloc] initWithDictionary:noteCommentDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_NOTE_COMMENT_RECEIVED", nil, @{@"note_comment":noteComment});
}

- (void) deleteNoteCommentId:(long)note_comment_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"note_comment_id":[NSNumber numberWithLong:note_comment_id],
     };
    [connection performAsynchronousRequestWithService:@"note_comments" method:@"deleteNoteComment" arguments:args handler:self successSelector:@selector(parseDeleteNoteComment:) failSelector:nil retryOnFail:NO humanDesc:@"Deleting Comment..." userInfo:nil];
}
- (void) parseDeleteNoteComment:(ARISServiceResult *)result
{
    //nothing
}


- (void) triggerGameUpdateForLogEvent:(ARISServiceResult *)result
{
  [_MODEL_GAME_ requestPlayerData];
}

- (void) logPlayerEnteredGame
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerBeganGame" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Game Entry..." userInfo:nil];
}
- (void) logPlayerResetGame:(long)game_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:game_id],
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerResetGame" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Game Reset..." userInfo:nil];
}
- (void) logPlayerMoved
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"latitude":[NSNumber numberWithDouble:_MODEL_PLAYER_.location.coordinate.latitude],
      @"longitude":[NSNumber numberWithDouble:_MODEL_PLAYER_.location.coordinate.longitude]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerMoved" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Movement..." userInfo:nil];
}
- (void) logPlayerViewedTabId:(long)tab_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"tab_id":[NSNumber numberWithLong:tab_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedTab" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Tab View..." userInfo:nil];
}
- (void) logPlayerViewedPlaqueId:(long)plaque_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"content_type":@"PLAQUE",
      @"content_id":[NSNumber numberWithLong:plaque_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:@selector(triggerGameUpdateForLogEvent:) failSelector:nil retryOnFail:NO humanDesc:@"Logging Plaque View..." userInfo:nil];
}
- (void) logPlayerViewedItemId:(long)item_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"content_type":@"ITEM",
      @"content_id":[NSNumber numberWithLong:item_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:@selector(triggerGameUpdateForLogEvent:) failSelector:nil retryOnFail:NO humanDesc:@"Logging Item View..." userInfo:nil];
}
- (void) logPlayerViewedDialogId:(long)dialog_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"content_type":@"DIALOG",
      @"content_id":[NSNumber numberWithLong:dialog_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:@selector(triggerGameUpdateForLogEvent:) failSelector:nil retryOnFail:NO humanDesc:@"Logging Dialog View..." userInfo:nil];
}
- (void) logPlayerViewedDialogScriptId:(long)dialog_script_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"content_type":@"DIALOG_SCRIPT",
      @"content_id":[NSNumber numberWithLong:dialog_script_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:@selector(triggerGameUpdateForLogEvent:) failSelector:nil retryOnFail:NO humanDesc:@"Logging Script View..." userInfo:nil];
}
- (void) logPlayerViewedWebPageId:(long)web_page_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"content_type":@"WEB_PAGE",
      @"content_id":[NSNumber numberWithLong:web_page_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:@selector(triggerGameUpdateForLogEvent:) failSelector:nil retryOnFail:NO humanDesc:@"Logging Web Page View..." userInfo:nil];
}
- (void) logPlayerViewedNoteId:(long)note_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"content_type":@"NOTE",
      @"content_id":[NSNumber numberWithLong:note_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:@selector(triggerGameUpdateForLogEvent:) failSelector:nil retryOnFail:NO humanDesc:@"Logging Note View..." userInfo:nil];
}
- (void) logPlayerViewedSceneId:(long)scene_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"content_type":@"SCENE",
      @"content_id":[NSNumber numberWithLong:scene_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Scene Entry..." userInfo:nil];
}
- (void) logPlayerViewedInstanceId:(long)instance_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"instance_id":[NSNumber numberWithLong:instance_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedInstance" arguments:args handler:self successSelector:@selector(triggerGameUpdateForLogEvent:) failSelector:nil retryOnFail:NO humanDesc:@"Logging Instance View..." userInfo:nil];
}
- (void) logPlayerTriggeredTriggerId:(long)trigger_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"trigger_id":[NSNumber numberWithLong:trigger_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerTriggeredTrigger" arguments:args handler:self successSelector:@selector(triggerGameUpdateForLogEvent:) failSelector:nil retryOnFail:NO humanDesc:@"Logging Trigger..." userInfo:nil];
}
- (void) logPlayerReceivedItemId:(long)item_id qty:(long)qty
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"item_id":[NSNumber numberWithLong:item_id],
      @"qty":[NSNumber numberWithLong:qty]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerReceivedItem" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Inventory Update..." userInfo:nil];
}
- (void) logPlayerLostItemId:(long)item_id qty:(long)qty
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"item_id":[NSNumber numberWithLong:item_id],
      @"qty":[NSNumber numberWithLong:qty]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerLostItem" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Inventory Update..." userInfo:nil];
}
- (void) logGameReceivedItemId:(long)item_id qty:(long)qty
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"item_id":[NSNumber numberWithLong:item_id],
      @"qty":[NSNumber numberWithLong:qty]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logGameReceivedItem" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Global Value Update..." userInfo:nil];
}
- (void) logGameLostItemId:(long)item_id qty:(long)qty
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"item_id":[NSNumber numberWithLong:item_id],
      @"qty":[NSNumber numberWithLong:qty]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logGameLostItem" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Global Value Update..." userInfo:nil];
}
- (void) logGroupReceivedItemId:(long)item_id qty:(long)qty
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"group_id":[NSNumber numberWithLong:0],
      @"item_id":[NSNumber numberWithLong:item_id],
      @"qty":[NSNumber numberWithLong:qty]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logGroupReceivedItem" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Global Value Update..." userInfo:nil];
}
- (void) logGroupLostItemId:(long)item_id qty:(long)qty
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"group_id":[NSNumber numberWithLong:0],
      @"item_id":[NSNumber numberWithLong:item_id],
      @"qty":[NSNumber numberWithLong:qty]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logGroupLostItem" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Global Value Update..." userInfo:nil];
}
- (void) logPlayerSetSceneId:(long)scene_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"scene_id":[NSNumber numberWithLong:scene_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerSetScene" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Scene Change..." userInfo:nil];
}
- (void) logPlayerJoinedGroupId:(long)group_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"group_id":[NSNumber numberWithLong:group_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerJoinedGroup" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Group Change..." userInfo:nil];
}
- (void) logPlayerRanEventPackageId:(long)event_package_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"event_package_id":[NSNumber numberWithLong:event_package_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerRanEventPackage" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Event Run..." userInfo:nil];
}
- (void) logPlayerCompletedQuestId:(long)quest_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithLong:_MODEL_GAME_.game_id],
      @"quest_id":[NSNumber numberWithLong:quest_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerCompletedQuest" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO humanDesc:@"Logging Quest Complete..." userInfo:nil];
}


- (void) fetchUserById:(long)user_id;
{
  NSDictionary *args =
    @{
      @"user_id":[NSNumber numberWithLong:user_id]
      };
  [connection performAsynchronousRequestWithService:@"users" method:@"getUser" arguments:args handler:self successSelector:@selector(parseUser:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching User..." userInfo:nil];
}
- (void) parseUser:(ARISServiceResult *)result
{
    NSDictionary *userDict= (NSDictionary *)result.resultData;
    User *user = [[User alloc] initWithDictionary:userDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_USER_RECEIVED", nil, @{@"user":user});
}

- (void) fetchSceneById:(long)scene_id;
{
  NSDictionary *args =
    @{
      @"scene_id":[NSNumber numberWithLong:scene_id]
      };
  [connection performAsynchronousRequestWithService:@"scenes" method:@"getScene" arguments:args handler:self successSelector:@selector(parseScene:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Scene..." userInfo:nil];
}
- (void) parseScene:(ARISServiceResult *)result
{
    NSDictionary *sceneDict= (NSDictionary *)result.resultData;
    Scene *scene = [[Scene alloc] initWithDictionary:sceneDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_SCENE_RECEIVED", nil, @{@"scene":scene});
}

- (void) fetchARTargetById:(long)ar_target_id;
{
  NSDictionary *args =
    @{
      @"ar_target_id":[NSNumber numberWithLong:ar_target_id]
      };
  [connection performAsynchronousRequestWithService:@"ar_targets" method:@"getARTarget" arguments:args handler:self successSelector:@selector(parseARTarget:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching ARTarget..." userInfo:nil];
}
- (void) parseARTarget:(ARISServiceResult *)result
{
    NSDictionary *arTargetDict= (NSDictionary *)result.resultData;
    ARTarget *ar_target = [[ARTarget alloc] initWithDictionary:arTargetDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_AR_TARGET_RECEIVED", nil, @{@"ar_target":ar_target});
}

- (void) fetchGroupById:(long)group_id;
{
  NSDictionary *args =
    @{
      @"group_id":[NSNumber numberWithLong:group_id]
      };
  [connection performAsynchronousRequestWithService:@"groups" method:@"getGroup" arguments:args handler:self successSelector:@selector(parseGroup:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Group..." userInfo:nil];
}

- (void) parseGroup:(ARISServiceResult *)result
{
    NSDictionary *groupDict= (NSDictionary *)result.resultData;
    Group *group = [[Group alloc] initWithDictionary:groupDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_GROUP_RECEIVED", nil, @{@"group":group});
}

- (void) fetchMediaById:(long)media_id;
{
  NSDictionary *args =
    @{
      @"media_id":[NSNumber numberWithLong:media_id]
      };
  [connection performAsynchronousRequestWithService:@"media" method:@"getMedia" arguments:args handler:self successSelector:@selector(parseMedia:) failSelector:@selector(mediaFetchFailed) retryOnFail:NO humanDesc:@"Fetching Media..." userInfo:nil];
}
- (void) parseMedia:(ARISServiceResult *)result //note that this intentionally only sends the dictionaries, not fully populated Media objects
{
    NSDictionary *mediaDict = (NSDictionary *)result.resultData;
    _ARIS_NOTIF_SEND_(@"SERVICES_MEDIA_RECEIVED", nil, @{@"media":mediaDict}); // fakes an entire list and does same as fetching all media
}

- (void) fetchPlaqueById:(long)plaque_id;
{
  NSDictionary *args =
    @{
      @"plaque_id":[NSNumber numberWithLong:plaque_id]
      };
  [connection performAsynchronousRequestWithService:@"plaques" method:@"getPlaque" arguments:args handler:self successSelector:@selector(parsePlaque:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Plaque..." userInfo:nil];
}
- (void) parsePlaque:(ARISServiceResult *)result
{
    NSDictionary *plaqueDict= (NSDictionary *)result.resultData;
    Plaque *plaque = [[Plaque alloc] initWithDictionary:plaqueDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAQUE_RECEIVED", nil, @{@"plaque":plaque});
}

- (void) fetchItemById:(long)item_id;
{
  NSDictionary *args =
    @{
      @"item_id":[NSNumber numberWithLong:item_id]
      };
  [connection performAsynchronousRequestWithService:@"items" method:@"getItem" arguments:args handler:self successSelector:@selector(parseItem:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Item..." userInfo:nil];
}
- (void) parseItem:(ARISServiceResult *)result
{
    NSDictionary *itemDict= (NSDictionary *)result.resultData;
    Item *item = [[Item alloc] initWithDictionary:itemDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_ITEM_RECEIVED", nil, @{@"item":item});
}

- (void) fetchDialogById:(long)dialog_id;
{
  NSDictionary *args =
    @{
      @"dialog_id":[NSNumber numberWithLong:dialog_id]
      };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialog" arguments:args handler:self successSelector:@selector(parseDialog:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Dialog..." userInfo:nil];
}
- (void) parseDialog:(ARISServiceResult *)result
{
    NSDictionary *dialogDict= (NSDictionary *)result.resultData;
    Dialog *dialog = [[Dialog alloc] initWithDictionary:dialogDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_RECEIVED", nil, @{@"dialog":dialog});
}

- (void) fetchDialogCharacterById:(long)character_id;
{
  NSDictionary *args =
    @{
      @"dialog_character_id":[NSNumber numberWithLong:character_id]
      };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogCharacter" arguments:args handler:self successSelector:@selector(parseDialogCharacter:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Character..." userInfo:nil];
}
- (void) parseDialogCharacter:(ARISServiceResult *)result
{
    NSDictionary *dialogCharacterDict= (NSDictionary *)result.resultData;
    DialogCharacter *dialogCharacter = [[DialogCharacter alloc] initWithDictionary:dialogCharacterDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_RECEIVED", nil, @{@"dialog_character":dialogCharacter});
}

- (void) fetchDialogScriptById:(long)script_id;
{
  NSDictionary *args =
    @{
      @"dialog_script_id":[NSNumber numberWithLong:script_id]
      };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogScript" arguments:args handler:self successSelector:@selector(parseDialogScript:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Script..." userInfo:nil];
}
- (void) parseDialogScript:(ARISServiceResult *)result
{
    NSDictionary *dialogScriptDict= (NSDictionary *)result.resultData;
    DialogScript *dialogScript = [[DialogScript alloc] initWithDictionary:dialogScriptDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_RECEIVED", nil, @{@"dialog_script":dialogScript});
}

- (void) fetchDialogOptionById:(long)option_id;
{
  NSDictionary *args =
    @{
      @"dialog_option_id":[NSNumber numberWithLong:option_id]
      };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogOption" arguments:args handler:self successSelector:@selector(parseDialogOption:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Option..." userInfo:nil];
}
- (void) parseDialogOption:(ARISServiceResult *)result
{
    NSDictionary *dialogOptionDict= (NSDictionary *)result.resultData;
    DialogOption *dialogOption = [[DialogOption alloc] initWithDictionary:dialogOptionDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_RECEIVED", nil, @{@"dialog_option":dialogOption});
}

- (void) fetchWebPageById:(long)web_page_id;
{
  NSDictionary *args =
    @{
      @"web_page_id":[NSNumber numberWithLong:web_page_id]
      };
  [connection performAsynchronousRequestWithService:@"web_pages" method:@"getWebPage" arguments:args handler:self successSelector:@selector(parseWebPage:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Web Page..." userInfo:nil];
}
- (void) parseWebPage:(ARISServiceResult *)result
{
    NSDictionary *webPageDict= (NSDictionary *)result.resultData;
    WebPage *webPage = [[WebPage alloc] initWithDictionary:webPageDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_WEB_PAGE_RECEIVED", nil, @{@"web_page":webPage});
}

- (void) fetchNoteById:(long)note_id;
{
  NSDictionary *args =
    @{
      @"note_id":[NSNumber numberWithLong:note_id]
      };
  [connection performAsynchronousRequestWithService:@"notes" method:@"getNote" arguments:args handler:self successSelector:@selector(parseNote:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Note..." userInfo:nil];
}
- (void) parseNote:(ARISServiceResult *)result
{
    // Since note is one of the few items a client gets individually, prevent trying to retrieve a deleted note.
    if(result.resultData != [NSNull null])
    {
      NSDictionary *noteDict= (NSDictionary *)result.resultData;
      Note *note = [[Note alloc] initWithDictionary:noteDict];
      _ARIS_NOTIF_SEND_(@"SERVICES_NOTE_RECEIVED", nil, @{@"note":note});
    }
}

- (void) fetchTagById:(long)tag_id;
{
  NSDictionary *args =
    @{
      @"tag_id":[NSNumber numberWithLong:tag_id]
      };
  [connection performAsynchronousRequestWithService:@"tags" method:@"getTag" arguments:args handler:self successSelector:@selector(parseTag:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Tag..." userInfo:nil];
}
- (void) parseTag:(ARISServiceResult *)result
{
    NSDictionary *tagDict= (NSDictionary *)result.resultData;
    Tag *tag = [[Tag alloc] initWithDictionary:tagDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_TAG_RECEIVED", nil, @{@"tag":tag});
}

- (void) fetchEventById:(long)event_id;
{
  NSDictionary *args =
    @{
      @"event_id":[NSNumber numberWithLong:event_id]
      };
  [connection performAsynchronousRequestWithService:@"events" method:@"getEvent" arguments:args handler:self successSelector:@selector(parseEvent:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Event..." userInfo:nil];
}
- (void) parseEvent:(ARISServiceResult *)result
{
    NSDictionary *eventDict= (NSDictionary *)result.resultData;
    Event *event = [[Event alloc] initWithDictionary:eventDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_EVENT_RECEIVED", nil, @{@"event":event});
}

- (void) fetchQuestById:(long)quest_id;
{
  NSDictionary *args =
    @{
      @"quest_id":[NSNumber numberWithLong:quest_id]
      };
  [connection performAsynchronousRequestWithService:@"quests" method:@"getQuest" arguments:args handler:self successSelector:@selector(parseQuest:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Quest..." userInfo:nil];
}
- (void) parseQuest:(ARISServiceResult *)result
{
    NSDictionary *questDict= (NSDictionary *)result.resultData;
    Quest *quest = [[Quest alloc] initWithDictionary:questDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_QUEST_RECEIVED", nil, @{@"quest":quest});
}

- (void) fetchInstanceById:(long)instance_id;
{
  NSDictionary *args =
    @{
      @"instance_id":[NSNumber numberWithLong:instance_id]
      };
  [connection performAsynchronousRequestWithService:@"instances" method:@"getInstance" arguments:args handler:self successSelector:@selector(parseInstance:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Instance..." userInfo:nil];
}
- (void) parseInstance:(ARISServiceResult *)result
{
    NSDictionary *instanceDict= (NSDictionary *)result.resultData;
  if(!result.resultData || [result.resultData isEqual:[NSNull null]]) return;
    Instance *instance = [[Instance alloc] initWithDictionary:instanceDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_INSTANCE_RECEIVED", nil, @{@"instance":instance});
}

- (void) fetchTriggerById:(long)trigger_id;
{
  NSDictionary *args =
    @{
      @"trigger_id":[NSNumber numberWithLong:trigger_id]
      };
  [connection performAsynchronousRequestWithService:@"triggers" method:@"getTrigger" arguments:args handler:self successSelector:@selector(parseTrigger:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Trigger..." userInfo:nil];
}
- (void) parseTrigger:(ARISServiceResult *)result
{
    NSDictionary *triggerDict= (NSDictionary *)result.resultData;
    if(!result.resultData || [result.resultData isEqual:[NSNull null]]) return;
    Trigger *trigger = [[Trigger alloc] initWithDictionary:triggerDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_TRIGGER_RECEIVED", nil, @{@"trigger":trigger});
}

- (void) fetchFactoryById:(long)factory_id;
{
  NSDictionary *args =
    @{
      @"factory_id":[NSNumber numberWithLong:factory_id]
      };
  [connection performAsynchronousRequestWithService:@"factories" method:@"getFactory" arguments:args handler:self successSelector:@selector(parseFactory:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Factory..." userInfo:nil];
}
- (void) parseFactory:(ARISServiceResult *)result
{
    NSDictionary *factoryDict= (NSDictionary *)result.resultData;
    Factory *factory = [[Factory alloc] initWithDictionary:factoryDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_FACTORY_RECEIVED", nil, @{@"factory":factory});
}

- (void) fetchOverlayById:(long)overlay_id;
{
  NSDictionary *args =
    @{
      @"overlay_id":[NSNumber numberWithLong:overlay_id]
      };
  [connection performAsynchronousRequestWithService:@"overlays" method:@"getOverlay" arguments:args handler:self successSelector:@selector(parseOverlay:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Overlay..." userInfo:nil];
}
- (void) parseOverlay:(ARISServiceResult *)result
{
    NSDictionary *overlayDict= (NSDictionary *)result.resultData;
    Overlay *overlay = [[Overlay alloc] initWithDictionary:overlayDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_OVERLAY_RECEIVED", nil, @{@"overlay":overlay});
}

- (void) fetchTabById:(long)tab_id;
{
  NSDictionary *args =
    @{
      @"tab_id":[NSNumber numberWithLong:tab_id]
      };
  [connection performAsynchronousRequestWithService:@"tabs" method:@"getTab" arguments:args handler:self successSelector:@selector(parseTab:) failSelector:nil retryOnFail:NO humanDesc:@"Fetching Tab..." userInfo:nil];
}
- (void) parseTab:(ARISServiceResult *)result
{
    NSDictionary *tabDict= (NSDictionary *)result.resultData;
    Tab *tab = [[Tab alloc] initWithDictionary:tabDict];
    _ARIS_NOTIF_SEND_(@"SERVICES_TAB_RECEIVED", nil, @{@"tab":tab});
}

- (void) reportJSONError
{
    NSString *json_error_url = _ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(@"json_error.txt");
    if (![[NSFileManager defaultManager] fileExistsAtPath:json_error_url]) {
        return;
    }
    NSError *err;
    NSString *json_error = [NSString stringWithContentsOfFile:json_error_url encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        json_error = @"There was a JSON error log file, but I couldn't read it.";
        NSLog(@"%@", json_error);
    }
    NSDictionary *args =
        @{
          @"message":json_error
        };
    [connection performAsynchronousRequestWithService:@"log" method:@"errorLog" arguments:args handler:self successSelector:@selector(clearJSONError) failSelector:nil retryOnFail:NO humanDesc:@"Uploading JSON error log..." userInfo:nil];
}

- (void) clearJSONError
{
    NSString *json_error_url = _ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(@"json_error.txt");
    [[NSFileManager defaultManager] removeItemAtPath:json_error_url error:nil];
}

@end

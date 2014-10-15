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
- (void) setServer:(NSString *)s { [connection setServer:s]; }

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
  if(!result.resultData) { _ARIS_NOTIF_SEND_(@"SERVICES_LOGIN_FAILED",nil,nil); return; }
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
            @"page":[NSNumber numberWithInt:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getNearbyGamesForPlayer" arguments:args handler:self successSelector:@selector(parseNearbyGames:) failSelector:nil retryOnFail:NO userInfo:nil];
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
            @"page":[NSNumber numberWithInt:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getAnywhereGamesForPlayer" arguments:args handler:self successSelector:@selector(parseAnywhereGames:) failSelector:nil retryOnFail:NO userInfo:nil];
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
            @"page":[NSNumber numberWithInt:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getRecentGamesForPlayer" arguments:args handler:self successSelector:@selector(parseRecentGames:) failSelector:nil retryOnFail:NO userInfo:nil];
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
            @"interval":@"MONTH",
            @"page":[NSNumber numberWithInt:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getPopularGamesForPlayer" arguments:args handler:self successSelector:@selector(parsePopularGames:) failSelector:nil retryOnFail:NO userInfo:nil];
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
            @"text":search,
            @"page":[NSNumber numberWithInt:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getSearchGamesForPlayer" arguments:args handler:self successSelector:@selector(parseSearchGames:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseSearchGames:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_SEARCH_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchMineGames
{
    NSDictionary *args =
        @{
            @"user_id":[NSString stringWithFormat:@"%d",_MODEL_PLAYER_.user_id],
            @"latitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.latitude],
            @"longitude":[NSString stringWithFormat:@"%f",_MODEL_PLAYER_.location.coordinate.longitude],
            @"page":[NSNumber numberWithInt:0]
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getPlayerGamesForPlayer" arguments:args handler:self successSelector:@selector(parseMineGames:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseMineGames:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_MINE_GAMES_RECEIVED", nil, @{@"games":[self parseGames:(NSArray *)result.resultData]});
}

- (void) fetchPlayerPlayedGame:(int)game_id
{
    NSDictionary *args =
        @{
            @"game_id":[NSString stringWithFormat:@"%d",game_id],
        };
  [connection performAsynchronousRequestWithService:@"client" method:@"getPlayerPlayedGame" arguments:args handler:self successSelector:@selector(parsePlayerPlayedGame:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parsePlayerPlayedGame:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_PLAYED_GAME_RECEIVED", nil, (NSDictionary *)result.resultData);
}

- (void) gameFetchFailed   { _ARIS_NOTIF_SEND_(@"SERVICES_GAME_FETCH_FAILED", nil, nil); }
- (void) playerFetchFailed { _ARIS_NOTIF_SEND_(@"SERVICES_GAME_FETCH_FAILED", nil, nil); }

- (void) fetchScenes
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"scenes" method:@"getScenesForGame" arguments:args handler:self successSelector:@selector(parseScenes:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseScenes:(ARISServiceResult *)result
{
    NSArray *sceneDicts = (NSArray *)result.resultData;
    NSMutableArray *scenes = [[NSMutableArray alloc] init];
    for(int i = 0; i < sceneDicts.count; i++)
        scenes[i] = [[Scene alloc] initWithDictionary:sceneDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_SCENES_RECEIVED", nil, @{@"scenes":scenes});
}

//creates player scene for game if not already created
- (void) touchSceneForPlayer
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"client" method:@"touchSceneForPlayer" arguments:args handler:self successSelector:@selector(parseSceneTouch:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil]; //technically a game fetch
}
- (void) parseSceneTouch:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_SCENE_TOUCHED", nil, nil);
}

- (void) fetchMedia
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"media" method:@"getMediaForGame" arguments:args handler:self successSelector:@selector(parseMedia:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseMedia:(ARISServiceResult *)result //note that this intentionally only sends the dictionaries, not fully populated Media objects
{
    NSArray *mediaDicts = (NSArray *)result.resultData;
    _ARIS_NOTIF_SEND_(@"SERVICES_MEDIA_RECEIVED", nil, @{@"media":mediaDicts});
}
- (void) fetchMediaId:(int)media_id
{
    NSDictionary *args =
    @{
      @"media_id":[NSNumber numberWithInt:media_id],
    };
    [connection performAsynchronousRequestWithService:@"media" method:@"getMedia" arguments:args handler:self successSelector:@selector(parseSingleMedia:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseSingleMedia:(ARISServiceResult *)result //note that this intentionally only sends the dictionaries, not fully populated Media objects
{
    NSDictionary *mediaDict = (NSDictionary *)result.resultData;
    _ARIS_NOTIF_SEND_(@"SERVICES_MEDIA_RECEIVED", nil, @{@"media":@[mediaDict]}); // fakes an entire list and does same as fetching all media
}

- (void) fetchPlaques
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"plaques" method:@"getPlaquesForGame" arguments:args handler:self successSelector:@selector(parsePlaques:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
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
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"items" method:@"getItemsForGame" arguments:args handler:self successSelector:@selector(parseItems:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseItems:(ARISServiceResult *)result
{
    NSArray *itemDicts = (NSArray *)result.resultData;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(int i = 0; i < itemDicts.count; i++)
        items[i] = [[Item alloc] initWithDictionary:itemDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_ITEMS_RECEIVED", nil, @{@"items":items});
}

//creates player owned item instances (qty 0) for all items not already owned
//makes any item qty transfers 100000x easier
- (void) touchItemsForPlayer
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"client" method:@"touchItemsForPlayer" arguments:args handler:self successSelector:@selector(parseItemTouch:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil]; //technically a game fetch
}
- (void) parseItemTouch:(ARISServiceResult *)result
{
    _ARIS_NOTIF_SEND_(@"SERVICES_ITEMS_TOUCHED", nil, nil);
}

- (void) fetchDialogs
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogsForGame" arguments:args handler:self successSelector:@selector(parseDialogs:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseDialogs:(ARISServiceResult *)result
{
    NSArray *dialogDicts = (NSArray *)result.resultData;
    NSMutableArray *dialogs = [[NSMutableArray alloc] init];
    for(int i = 0; i < dialogDicts.count; i++)
        dialogs[i] = [[Dialog alloc] initWithDictionary:dialogDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOGS_RECEIVED", nil, @{@"dialogs":dialogs});
}

- (void) fetchDialogCharacters
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogCharactersForGame" arguments:args handler:self successSelector:@selector(parseDialogCharacters:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseDialogCharacters:(ARISServiceResult *)result
{
    NSArray *dialogCharacterDicts = (NSArray *)result.resultData;
    NSMutableArray *dialogCharacters = [[NSMutableArray alloc] init];
    for(int i = 0; i < dialogCharacterDicts.count; i++)
        dialogCharacters[i] = [[DialogCharacter alloc] initWithDictionary:dialogCharacterDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_CHARACTERS_RECEIVED", nil, @{@"dialogCharacters":dialogCharacters});
}

- (void) fetchDialogScripts
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
    };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogScriptsForGame" arguments:args handler:self successSelector:@selector(parseDialogScripts:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseDialogScripts:(ARISServiceResult *)result
{
    NSArray *dialogScriptDicts = (NSArray *)result.resultData;
    NSMutableArray *dialogScripts = [[NSMutableArray alloc] init];
    for(int i = 0; i < dialogScriptDicts.count; i++)
        dialogScripts[i] = [[DialogScript alloc] initWithDictionary:dialogScriptDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_SCRIPTS_RECEIVED", nil, @{@"dialogScripts":dialogScripts});
}

- (void) fetchDialogOptions
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
    };
  [connection performAsynchronousRequestWithService:@"dialogs" method:@"getDialogOptionsForGame" arguments:args handler:self successSelector:@selector(parseDialogOptions:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseDialogOptions:(ARISServiceResult *)result
{
    NSArray *dialogOptionDicts = (NSArray *)result.resultData;
    NSMutableArray *dialogOptions = [[NSMutableArray alloc] init];
    for(int i = 0; i < dialogOptionDicts.count; i++)
        dialogOptions[i] = [[DialogOption alloc] initWithDictionary:dialogOptionDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_DIALOG_OPTIONS_RECEIVED", nil, @{@"dialogOptions":dialogOptions});
}

- (void) fetchWebPages
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"web_pages" method:@"getWebPagesForGame" arguments:args handler:self successSelector:@selector(parseWebPages:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseWebPages:(ARISServiceResult *)result
{
    NSArray *webPageDicts = (NSArray *)result.resultData;
    NSMutableArray *webPages = [[NSMutableArray alloc] init];
    for(int i = 0; i < webPageDicts.count; i++)
        webPages[i] = [[WebPage alloc] initWithDictionary:webPageDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_WEB_PAGES_RECEIVED", nil, @{@"webPages":webPages});
}

- (void) fetchNotes
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"notes" method:@"getNotesForGame" arguments:args handler:self successSelector:@selector(parseNotes:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseNotes:(ARISServiceResult *)result
{
    NSArray *noteDicts = (NSArray *)result.resultData;
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    for(int i = 0; i < noteDicts.count; i++)
        notes[i] = [[Note alloc] initWithDictionary:noteDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_NOTES_RECEIVED", nil, @{@"notes":notes});
}

- (void) fetchTags
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"tags" method:@"getTagsForGame" arguments:args handler:self successSelector:@selector(parseTags:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseTags:(ARISServiceResult *)result
{
    NSArray *tagDicts = (NSArray *)result.resultData;
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    for(int i = 0; i < tagDicts.count; i++)
        tags[i] = [[Tag alloc] initWithDictionary:tagDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_TAGS_RECEIVED", nil, @{@"tags":tags});
}


- (void) fetchObjectTags
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"tags" method:@"getObjectTagsForGame" arguments:args handler:self successSelector:@selector(parseObjectTags:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseObjectTags:(ARISServiceResult *)result
{
    NSArray *objectTagDicts = (NSArray *)result.resultData;
    NSMutableArray *objectTags = [[NSMutableArray alloc] init];
    for(int i = 0; i < objectTagDicts.count; i++)
        objectTags[i] = [[ObjectTag alloc] initWithDictionary:objectTagDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_OBJECT_TAGS_RECEIVED", nil, @{@"object_tags":objectTags});
}

- (void) fetchEvents
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"events" method:@"getEventsForGame" arguments:args handler:self successSelector:@selector(parseEvents:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseEvents:(ARISServiceResult *)result
{
    NSArray *eventDicts = (NSArray *)result.resultData;
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for(int i = 0; i < eventDicts.count; i++)
        events[i] = [[Event alloc] initWithDictionary:eventDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_EVENTS_RECEIVED", nil, @{@"events":events});
}

- (void) fetchQuests
{
  NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id]
      };
  [connection performAsynchronousRequestWithService:@"quests" method:@"getQuestsForGame" arguments:args handler:self successSelector:@selector(parseQuests:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
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
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"owner_id":[NSNumber numberWithInt:0] //could leave this out and get same result, but would rather be explicit
      };
    [connection performAsynchronousRequestWithService:@"instances" method:@"getInstancesForGame" arguments:args handler:self successSelector:@selector(parseInstances:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
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
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"triggers" method:@"getTriggersForGame" arguments:args handler:self successSelector:@selector(parseTriggers:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseTriggers:(ARISServiceResult *)result
{
    NSArray *triggerDicts = (NSArray *)result.resultData;
    NSMutableArray *triggers = [[NSMutableArray alloc] init];
    for(int i = 0; i < triggerDicts.count; i++)
        triggers[i] = [[Trigger alloc] initWithDictionary:triggerDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_TRIGGERS_RECEIVED", nil, @{@"triggers":triggers});
}

- (void) fetchOverlays
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"overlays" method:@"getOverlaysForGame" arguments:args handler:self successSelector:@selector(parseOverlays:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseOverlays:(ARISServiceResult *)result
{
    NSArray *overlayDicts = (NSArray *)result.resultData;
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
    for(int i = 0; i < overlayDicts.count; i++)
        overlays[i] = [[Overlay alloc] initWithDictionary:overlayDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_OVERLAYS_RECEIVED", nil, @{@"overlays":overlays});
}

- (void) fetchTabs
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"tabs" method:@"getTabsForGame" arguments:args handler:self successSelector:@selector(parseTabs:) failSelector:@selector(gameFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parseTabs:(ARISServiceResult *)result
{
    NSArray *tabDicts = (NSArray *)result.resultData;
    NSMutableArray *tabs = [[NSMutableArray alloc] init];
    for(int i = 0; i < tabDicts.count; i++)
        tabs[i] = [[Tab alloc] initWithDictionary:tabDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_TABS_RECEIVED", nil, @{@"tabs":tabs});
}

- (void) fetchSceneForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getSceneForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerScene:) failSelector:@selector(playerFetchFailed) retryOnFail:NO userInfo:nil];
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

- (void) fetchLogsForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getLogsForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerLogs:) failSelector:@selector(playerFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parsePlayerLogs:(ARISServiceResult *)result
{
    NSArray *logDicts = (NSArray *)result.resultData;
    NSMutableArray *logs = [[NSMutableArray alloc] init];
    for(int i = 0; i < logDicts.count; i++)
        logs[i] = [[Log alloc] initWithDictionary:logDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_LOGS_RECEIVED", nil, @{@"logs":logs});
}

- (void) fetchInstancesForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"owner_id":[NSNumber numberWithInt:_MODEL_PLAYER_.user_id]
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getInstancesForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerInstances:) failSelector:@selector(playerFetchFailed) retryOnFail:NO userInfo:nil];
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
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getTriggersForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerTriggers:) failSelector:@selector(playerFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parsePlayerTriggers:(ARISServiceResult *)result
{
    NSArray *triggerDicts = (NSArray *)result.resultData;
    NSMutableArray *triggers = [[NSMutableArray alloc] init];
    for(int i = 0; i < triggerDicts.count; i++)
        triggers[i] = [[Trigger alloc] initWithDictionary:triggerDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_TRIGGERS_RECEIVED", nil, @{@"triggers":triggers});
}

- (void) fetchOverlaysForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getOverlaysForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerOverlays:) failSelector:@selector(playerFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parsePlayerOverlays:(ARISServiceResult *)result
{
    NSArray *overlayDicts = (NSArray *)result.resultData;
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
    for(int i = 0; i < overlayDicts.count; i++)
        overlays[i] = [[Overlay alloc] initWithDictionary:overlayDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_OVERLAYS_RECEIVED", nil, @{@"overlays":overlays});
}

- (void) fetchQuestsForPlayer
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getQuestsForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerQuests:) failSelector:@selector(playerFetchFailed) retryOnFail:NO userInfo:nil];
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
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getTabsForPlayer" arguments:args handler:self successSelector:@selector(parsePlayerTabs:) failSelector:@selector(playerFetchFailed) retryOnFail:NO userInfo:nil];
}
- (void) parsePlayerTabs:(ARISServiceResult *)result
{
    NSArray *tabDicts = (NSArray *)result.resultData;
    NSMutableArray *tabs = [[NSMutableArray alloc] init];
    for(int i = 0; i < tabDicts.count; i++)
        tabs[i] = [[Tab alloc] initWithDictionary:tabDicts[i]];
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_TABS_RECEIVED", nil, @{@"tabs":tabs});
}

- (void) fetchOptionsForPlayerForDialog:(int)dialog_id script:(int)dialog_script_id //doesn't need to be called during game load
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"dialog_id":[NSNumber numberWithInt:dialog_id], 
      @"dialog_script_id":[NSNumber numberWithInt:dialog_script_id],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"getOptionsForPlayerForDialogScript" arguments:args handler:self successSelector:@selector(parsePlayerOptionsForScript:) failSelector:nil retryOnFail:NO userInfo:@{@"dialog_script_id":[NSNumber numberWithInt:dialog_script_id],@"dialog_id":[NSNumber numberWithInt:dialog_id]}];
}
- (void) parsePlayerOptionsForScript:(ARISServiceResult *)result
{
    NSArray *playerOptionsDicts = (NSArray *)result.resultData;
    NSMutableArray *options = [[NSMutableArray alloc] init];
    for(int i = 0; i < playerOptionsDicts.count; i++)
        options[i] = [[DialogOption alloc] initWithDictionary:playerOptionsDicts[i]];
    NSDictionary *uInfo = @{@"options":options,
                            @"dialog_id":result.userInfo[@"dialog_id"],
                            @"dialog_script_id":result.userInfo[@"dialog_script_id"]};
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_SCRIPT_OPTIONS_RECEIVED", nil, uInfo);
}


- (void) setQtyForInstanceId:(int)instance_id qty:(int)qty
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"instance_id":[NSNumber numberWithInt:instance_id], 
      @"qty":[NSNumber numberWithInt:qty],
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"setQtyForInstance" arguments:args handler:self successSelector:@selector(parseSetQtyForInstance:) failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) parseSetQtyForInstance:(ARISServiceResult *)result
{
    //nothing need be done
}

- (void) setPlayerSceneId:(int)scene_id
{
     NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"scene_id":[NSNumber numberWithInt:scene_id]
      };
    [connection performAsynchronousRequestWithService:@"client" method:@"setPlayerScene" arguments:args handler:self successSelector:@selector(parseSetPlayerScene:) failSelector:nil retryOnFail:NO userInfo:nil];   
}
- (void) parseSetPlayerScene:(ARISServiceResult *)result
{
    //nothing need be done
}

- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"user_id":[NSNumber numberWithInt:_MODEL_PLAYER_.user_id],
      @"name":n.name,
      @"description":n.description,
      @"media":
        @{
           @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
           @"file_name":[m.localURL absoluteString],
           @"data":[m.data base64Encoding]
        }
     };
    [connection performAsynchronousRequestWithService:@"notes" method:@"createNote" arguments:args handler:self successSelector:@selector(parseCreateNote:) failSelector:nil retryOnFail:NO userInfo:nil];   
}
- (void) parseCreateNote:(ARISServiceResult *)result
{
    //nothing
}

- (void) logPlayerEnteredGame
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerBeganGame" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerResetGame:(int)game_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:game_id],
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerResetGame" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerMoved
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"latitude":[NSNumber numberWithDouble:_MODEL_PLAYER_.location.coordinate.latitude],
      @"longitude":[NSNumber numberWithDouble:_MODEL_PLAYER_.location.coordinate.longitude]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerMoved" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerViewedTabId:(int)tab_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"tab_id":[NSNumber numberWithInt:tab_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedTab" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerViewedPlaqueId:(int)plaque_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"content_type":@"PLAQUE",
      @"content_id":[NSNumber numberWithInt:plaque_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerViewedItemId:(int)item_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"content_type":@"ITEM",
      @"content_id":[NSNumber numberWithInt:item_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerViewedDialogId:(int)dialog_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"content_type":@"DIALOG",
      @"content_id":[NSNumber numberWithInt:dialog_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerViewedDialogScriptId:(int)dialog_script_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"content_type":@"DIALOG_SCRIPT",
      @"content_id":[NSNumber numberWithInt:dialog_script_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerViewedWebPageId:(int)web_page_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"content_type":@"WEB_PAGE",
      @"content_id":[NSNumber numberWithInt:web_page_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerViewedNoteId:(int)note_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"content_type":@"NOTE",
      @"content_id":[NSNumber numberWithInt:note_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerViewedSceneId:(int)scene_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"content_type":@"SCENE",
      @"content_id":[NSNumber numberWithInt:scene_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedContent" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerViewedInstanceId:(int)instance_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"instance_id":[NSNumber numberWithInt:instance_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerViewedInstance" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerTriggeredTriggerId:(int)trigger_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"trigger_id":[NSNumber numberWithInt:trigger_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerTriggeredTrigger" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil]; 
}
- (void) logPlayerReceivedItemId:(int)item_id qty:(int)qty
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"item_id":[NSNumber numberWithInt:item_id],
      @"qty":[NSNumber numberWithInt:qty]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerReceivedItem" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerLostItemId:(int)item_id qty:(int)qty
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"item_id":[NSNumber numberWithInt:item_id],
      @"qty":[NSNumber numberWithInt:qty]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerLostItem" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}
- (void) logPlayerSetSceneId:(int)scene_id
{
    NSDictionary *args =
    @{
      @"game_id":[NSNumber numberWithInt:_MODEL_GAME_.game_id],
      @"item_id":[NSNumber numberWithInt:scene_id]
    };
    [connection performAsynchronousRequestWithService:@"client" method:@"logPlayerSetScene" arguments:args handler:self successSelector:nil failSelector:nil retryOnFail:NO userInfo:nil];
}




















- (void) uploadNote:(Note *)n
{
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

@end

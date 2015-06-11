//
//  Game.m
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

// Functions both as "Game" data object and Game Model

#import "Game.h"
#import "User.h"
#import "GameComment.h"
#import "AppModel.h"
#import "NSDictionary+ValidParsers.h"

const long gameDatasToReceive = 28;
const long playerDatasToReceive = 6;

@interface Game()
{
    long receivedGameData;
    BOOL gameDataReceived;

    long receivedPlayerData;
    BOOL playerDataReceived;

    NSTimer *poller;
}
@end
@implementation Game

@synthesize game_id;
@synthesize name;
@synthesize desc;
@synthesize tick_script;
@synthesize tick_delay;
@synthesize published;
@synthesize type;
@synthesize location;
@synthesize player_count;

@synthesize icon_media_id;
@synthesize media_id;

@synthesize intro_scene_id;

@synthesize authors;
@synthesize comments;

@synthesize map_type;
@synthesize map_location;
@synthesize map_zoom_level;
@synthesize map_show_player;
@synthesize map_show_players;
@synthesize map_offsite_mode;

@synthesize notebook_allow_comments;
@synthesize notebook_allow_likes;
@synthesize notebook_allow_player_tags;

@synthesize inventory_weight_cap;
@synthesize network_level;

@synthesize scenesModel;
@synthesize plaquesModel;
@synthesize itemsModel;
@synthesize dialogsModel;
@synthesize webPagesModel;
@synthesize notesModel;
@synthesize tagsModel;
@synthesize eventsModel;
@synthesize requirementsModel;
@synthesize triggersModel;
@synthesize factoriesModel;
@synthesize overlaysModel;
@synthesize instancesModel;
@synthesize playerInstancesModel;
@synthesize gameInstancesModel;
@synthesize tabsModel;
@synthesize logsModel;
@synthesize questsModel;
@synthesize displayQueueModel;

- (id) init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        [self initialize];

        game_id = [dict validIntForKey:@"game_id"];
        name = [dict validStringForKey:@"name"];
        desc = [dict validStringForKey:@"description"];
        tick_script = [dict validStringForKey:@"tick_script"];
        tick_delay = [dict validIntForKey:@"tick_delay"];
        published = [dict validBoolForKey:@"published"];
        type = [dict validStringForKey:@"type"];
        location = [dict validLocationForLatKey:@"latitude" lonKey:@"longitude"];
        player_count = [dict validIntForKey:@"player_count"];

        icon_media_id = [dict validIntForKey:@"icon_media_id"];
        media_id = [dict validIntForKey:@"media_id"];

        intro_scene_id = [dict validIntForKey:@"intro_scene_id"];

        //authors = [dict validObjectForKey:@"authors"];
        //comments = [dict validObjectForKey:@"comments"];

        map_type = [dict validStringForKey:@"map_type"];
        location = [dict validLocationForLatKey:@"map_latitude" lonKey:@"map_longitude"];
        map_zoom_level = [dict validDoubleForKey:@"map_zoom_level"];
        map_show_player = [dict validBoolForKey:@"map_show_player"];
        map_show_players = [dict validBoolForKey:@"map_show_players"];
        map_offsite_mode = [dict validBoolForKey:@"map_offsite_mode"];

        notebook_allow_comments = [dict validBoolForKey:@"notebook_allow_comments"];
        notebook_allow_likes = [dict validBoolForKey:@"notebook_allow_likes"];
        notebook_allow_player_tags = [dict validBoolForKey:@"notebook_allow_player_tags"];

        inventory_weight_cap = [dict validIntForKey:@"inventory_weight_cap"];
        network_level = @"NONE_STRICT";
        /*
        NONE_STRICT = disallow any features that require it (can't create notes, etc...)
        STATIC_GAME = no updates of server info at playtime, but allow writes
        NORMAL = do whatever local calculations possible, but continue polling for updates on everything
        CHATTY = rely on server as authority for often updates
        */

        NSArray *authorDicts;
        for(long i = 0; (authorDicts || (authorDicts = [dict objectForKey:@"authors"])) && i < authorDicts.count; i++)
            [authors addObject:[[User alloc] initWithDictionary:authorDicts[i]]];
    }
    return self;
}

- (void) initialize //call in all init funcs (why apple doesn't provide functionality for this, I have no idea)
{
    receivedGameData = 0;
    gameDataReceived = NO;

    receivedPlayerData = 0;
    playerDataReceived = NO;

    authors  = [NSMutableArray arrayWithCapacity:5];
    comments = [NSMutableArray arrayWithCapacity:5];
  
    network_level = @"NORMAL";

    _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_BEGAN", self, @selector(gameBegan), nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_LEFT", self, @selector(gameLeft), nil);
}

- (void) mergeDataFromGame:(Game *)g
{
    game_id = g.game_id;
    name = g.name;
    desc = g.desc;
    tick_script = g.tick_script;
    tick_delay = g.tick_delay;
    published = g.published;
    type = g.type;
    location = g.location;
    player_count = g.player_count > 0 ? g.player_count : player_count;

    icon_media_id = g.icon_media_id;
    media_id = g.media_id;

    authors  = g.authors;
    comments = g.comments;

    map_type = g.map_type;
    location = g.location;
    map_zoom_level = g.map_zoom_level;
    map_show_player = g.map_show_player;
    map_show_players = g.map_show_players;
    map_offsite_mode = g.map_offsite_mode;

    notebook_allow_comments = g.notebook_allow_comments;
    notebook_allow_likes = g.notebook_allow_likes;
    notebook_allow_player_tags = g.notebook_allow_player_tags;

    inventory_weight_cap = g.inventory_weight_cap;
}

- (void) getReadyToPlay
{
    _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_PIECE_AVAILABLE",self,@selector(gamePieceReceived),nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",self,@selector(gamePlayerPieceReceived),nil);

    receivedGameData = 0;
    gameDataReceived = NO;

    receivedPlayerData = 0;
    playerDataReceived = NO;

    scenesModel          = [[ScenesModel          alloc] init];
    plaquesModel         = [[PlaquesModel         alloc] init];
    itemsModel           = [[ItemsModel           alloc] init];
    dialogsModel         = [[DialogsModel         alloc] init];
    webPagesModel        = [[WebPagesModel        alloc] init];
    notesModel           = [[NotesModel           alloc] init];
    tagsModel            = [[TagsModel            alloc] init];
    eventsModel          = [[EventsModel          alloc] init];
    requirementsModel    = [[RequirementsModel    alloc] init];
    triggersModel        = [[TriggersModel        alloc] init];
    factoriesModel       = [[FactoriesModel       alloc] init];
    overlaysModel        = [[OverlaysModel        alloc] init];
    instancesModel       = [[InstancesModel       alloc] init];
    playerInstancesModel = [[PlayerInstancesModel alloc] init];
    gameInstancesModel   = [[GameInstancesModel   alloc] init];
    tabsModel            = [[TabsModel            alloc] init];
    logsModel            = [[LogsModel            alloc] init];
    questsModel          = [[QuestsModel          alloc] init];
    displayQueueModel    = [[DisplayQueueModel    alloc] init];
}

- (void) endPlay //to remove models while retaining the game stub for lists and such
{
    receivedGameData = 0;
    gameDataReceived = NO;

    receivedPlayerData = 0;
    playerDataReceived = NO;

    scenesModel          = nil;
    plaquesModel         = nil;
    itemsModel           = nil;
    dialogsModel         = nil;
    webPagesModel        = nil;
    notesModel           = nil;
    tagsModel            = nil;
    eventsModel          = nil;
    requirementsModel    = nil;
    triggersModel        = nil;
    factoriesModel       = nil;
    overlaysModel        = nil;
    instancesModel       = nil;
    playerInstancesModel = nil;
    gameInstancesModel   = nil;
    tabsModel            = nil;
    questsModel          = nil;
    logsModel            = nil;
    displayQueueModel    = nil;
}

- (void) requestGameData
{
    receivedGameData = 0;
    [scenesModel requestScenes];
    [scenesModel touchPlayerScene];
    [plaquesModel requestPlaques];
    [itemsModel requestItems];
    [playerInstancesModel touchPlayerInstances];
    [gameInstancesModel touchGameInstances];
    [dialogsModel requestDialogs]; //makes 4 "game data received" notifs (dialogs, characters, scripts, options)
    [webPagesModel requestWebPages];
    [notesModel requestNotes];
    [notesModel requestNoteComments];
    [tagsModel requestTags];
    [eventsModel requestEvents];
    [requirementsModel requestRequirements]; //makes 3 "game data received" notifs (roots, ands, atoms)
    [questsModel requestQuests];
    [triggersModel requestTriggers];
    [factoriesModel requestFactories];
    [overlaysModel requestOverlays];
    [instancesModel requestInstances];
    [tabsModel requestTabs];
    [logsModel requestPlayerLogs];

    //the requests not 'owned' by Game. Also, not 100% necessary
    //(has ability to load on an individual basis)
    [_MODEL_MEDIA_ requestMedia];
    [_MODEL_USERS_ requestUsers];
}

- (void) requestPlayerData
{
    receivedPlayerData = 0;
    [scenesModel requestPlayerScene];
    [instancesModel requestPlayerInstances];
    [triggersModel requestPlayerTriggers];
    [overlaysModel requestPlayerOverlays];
    [questsModel requestPlayerQuests];
    [tabsModel requestPlayerTabs];
}

- (void) gamePieceReceived
{
    receivedGameData++;
    //if(!gameDataReceived && receivedGameData >= gameDatasToReceive)
    if([self allGameDataReceived])
    {
      receivedGameData = gameDatasToReceive; //should already be exactly this...
      gameDataReceived = YES;
      _ARIS_NOTIF_SEND_(@"MODEL_GAME_DATA_LOADED", nil, nil);
    }
    [self percentLoadedChanged];
}

- (void) gamePlayerPieceReceived
{
    receivedPlayerData++;
    if(receivedPlayerData >= playerDatasToReceive)
    {
        playerDataReceived = YES;
        _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_DATA_LOADED", nil, nil);
    }
    [self percentLoadedChanged];
}

- (void) percentLoadedChanged
{
    NSNumber *percentReceived = [NSNumber numberWithFloat:
                                 (float)(receivedGameData+receivedPlayerData)/(float)(gameDatasToReceive+playerDatasToReceive)
                                 ];
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PERCENT_LOADED", nil, @{@"percent":percentReceived});
}

- (void) gameBegan
{
    _ARIS_NOTIF_IGNORE_(@"MODEL_GAME_PIECE_AVAILABLE", self, nil);
    _ARIS_NOTIF_IGNORE_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE", self, nil);
    poller = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(requestPlayerData) userInfo:nil repeats:YES];
}

- (void) gameLeft
{
    [poller invalidate];
}

- (BOOL) allGameDataReceived
{
  if(![scenesModel gameInfoRecvd]) return NO;
  if(![plaquesModel gameInfoRecvd]) return NO;
  if(![itemsModel gameInfoRecvd]) return NO;
  if(![playerInstancesModel gameInfoRecvd]) return NO;
  if(![gameInstancesModel gameInfoRecvd]) return NO;
  if(![dialogsModel gameInfoRecvd]) return NO;
  if(![webPagesModel gameInfoRecvd]) return NO;
  if(![notesModel gameInfoRecvd]) return NO;
  if(![tagsModel gameInfoRecvd]) return NO;
  if(![eventsModel gameInfoRecvd]) return NO;
  if(![requirementsModel gameInfoRecvd]) return NO;
  if(![questsModel gameInfoRecvd]) return NO;
  if(![triggersModel gameInfoRecvd]) return NO;
  if(![factoriesModel gameInfoRecvd]) return NO;
  if(![overlaysModel gameInfoRecvd]) return NO;
  if(![instancesModel gameInfoRecvd]) return NO;
  if(![tabsModel gameInfoRecvd]) return NO;
  if(![logsModel gameInfoRecvd]) return NO;
 
  if(![_MODEL_MEDIA_ gameInfoRecvd]) { NSLog(@"Missing _MODEL_MEDIA_"); return NO; }
  if(![_MODEL_USERS_ gameInfoRecvd]) { NSLog(@"Missing _MODEL_USERS_"); return NO; }
  return YES;
}

- (void) clearModels
{
    receivedGameData = 0;
    gameDataReceived = NO;

    receivedPlayerData = 0;
    playerDataReceived = NO;

    [scenesModel          clearGameData];
    [plaquesModel         clearGameData];
    [itemsModel           clearGameData];
    [dialogsModel         clearGameData];
    [webPagesModel        clearGameData];
    [notesModel           clearGameData];
    [tagsModel            clearGameData];
    [eventsModel          clearGameData];
    [requirementsModel    clearGameData];
    [questsModel          clearGameData];
    [triggersModel        clearGameData];
    [factoriesModel       clearGameData];
    [overlaysModel        clearGameData];
    [instancesModel       clearGameData];
    [playerInstancesModel clearGameData];
    [gameInstancesModel   clearGameData];
    [tabsModel            clearGameData];
  
    [_MODEL_MEDIA_ clearGameData];
    [_MODEL_USERS_ clearGameData];
  
    [scenesModel          clearPlayerData];
    [questsModel          clearPlayerData];
    [triggersModel        clearPlayerData];
    [overlaysModel        clearPlayerData];
    [instancesModel       clearPlayerData];
    [playerInstancesModel clearPlayerData];
    [gameInstancesModel   clearPlayerData];
    [tabsModel            clearPlayerData];
    [logsModel            clearPlayerData];

    [displayQueueModel clear];
}

- (long) rating
{
    if(!comments.count) return 0;
    long rating = 0;
    for(long i = 0; i < comments.count; i++)
        rating += ((GameComment *)[comments objectAtIndex:i]).rating;
    return rating/comments.count;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Game- Id:%ld\tName:%@",game_id,name];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


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

@interface Game()
{
  long n_game_data_to_receive;
  long n_game_data_received;
  long n_player_data_to_receive;
  long n_player_data_received;
  
  NSMutableArray *models;
  
  NSTimer *poller;
}
@end
@implementation Game

@synthesize game_id;
@synthesize name;
@synthesize desc;
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
@synthesize groupsModel;
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
@synthesize groupInstancesModel;
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
    network_level = [dict validStringForKey:@"network_level"];
    if([network_level isEqualToString:@""]) network_level = @"HYBRID";
    /*
     LOCAL = disallow any features that require it (can't create notes, etc...)
     REMOTE_WRITE = no updates of server info at playtime, but allow writes
     HYBRID = do whatever local calculations possible, but continue polling for updates on everything
     REMOTE = rely on server as authority for often updates
     */
    
    NSArray *authorDicts;
    for(long i = 0; (authorDicts || (authorDicts = [dict objectForKey:@"authors"])) && i < authorDicts.count; i++)
      [authors addObject:[[User alloc] initWithDictionary:authorDicts[i]]];
  }
  return self;
}

- (void) initialize //call in all init funcs (why apple doesn't provide functionality for this, I have no idea)
{
  n_game_data_received = 0;
  n_player_data_received = 0;
  
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
  
  n_game_data_received = 0;
  n_player_data_received = 0;
  
  models = [[NSMutableArray alloc] init];
  
  scenesModel          = [[ScenesModel          alloc] init]; [models addObject:scenesModel];
  groupsModel          = [[GroupsModel          alloc] init]; [models addObject:groupsModel];
  plaquesModel         = [[PlaquesModel         alloc] init]; [models addObject:plaquesModel];
  itemsModel           = [[ItemsModel           alloc] init]; [models addObject:itemsModel];
  dialogsModel         = [[DialogsModel         alloc] init]; [models addObject:dialogsModel];
  webPagesModel        = [[WebPagesModel        alloc] init]; [models addObject:webPagesModel];
  notesModel           = [[NotesModel           alloc] init]; [models addObject:notesModel];
  tagsModel            = [[TagsModel            alloc] init]; [models addObject:tagsModel];
  eventsModel          = [[EventsModel          alloc] init]; [models addObject:eventsModel];
  requirementsModel    = [[RequirementsModel    alloc] init]; [models addObject:requirementsModel];
  triggersModel        = [[TriggersModel        alloc] init]; [models addObject:triggersModel];
  factoriesModel       = [[FactoriesModel       alloc] init]; [models addObject:factoriesModel];
  overlaysModel        = [[OverlaysModel        alloc] init]; [models addObject:overlaysModel];
  instancesModel       = [[InstancesModel       alloc] init]; [models addObject:instancesModel];
  playerInstancesModel = [[PlayerInstancesModel alloc] init]; [models addObject:playerInstancesModel];
  gameInstancesModel   = [[GameInstancesModel   alloc] init]; [models addObject:gameInstancesModel];
  groupInstancesModel  = [[GroupInstancesModel  alloc] init]; [models addObject:groupInstancesModel];
  tabsModel            = [[TabsModel            alloc] init]; [models addObject:tabsModel];
  logsModel            = [[LogsModel            alloc] init]; [models addObject:logsModel];
  questsModel          = [[QuestsModel          alloc] init]; [models addObject:questsModel];
  displayQueueModel    = [[DisplayQueueModel    alloc] init]; [models addObject:displayQueueModel];
  //not 'owned' by game, still need to be run
  [models addObject:_MODEL_USERS_];
  [models addObject:_MODEL_MEDIA_];
  
  n_game_data_to_receive = 0;
  n_player_data_to_receive = 0;
  for(long i = 0; i < models.count; i++)
  {
    n_game_data_to_receive   += [(ARISModel *)models[i] nGameDataToReceive];
    n_player_data_to_receive += [(ARISModel *)models[i] nPlayerDataToReceive];
  }
}

- (void) endPlay //to remove models while retaining the game stub for lists and such
{
  n_game_data_to_receive = 0;
  n_game_data_received = 0;
  n_player_data_to_receive = 0;
  n_player_data_received = 0;
  
  models = nil;
  
  scenesModel          = nil;
  groupsModel          = nil;
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
  groupInstancesModel  = nil;
  tabsModel            = nil;
  questsModel          = nil;
  logsModel            = nil;
  displayQueueModel    = nil;
}

- (void) requestGameData
{
  n_game_data_received = 0;
  for(long i = 0; i < models.count; i++)
    [(ARISModel *)models[i] requestGameData];
}

- (void) requestPlayerData
{
  n_player_data_received = 0;
  for(long i = 0; i < models.count; i++)
    [(ARISModel *)models[i] requestPlayerData];
}

- (void) gamePieceReceived
{
  n_game_data_received++;
  if([self allGameDataReceived])
  {
    n_game_data_received = n_game_data_to_receive; //should already be exactly this...
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_DATA_LOADED", nil, nil);
  }
  [self percentLoadedChanged];
}

- (void) gamePlayerPieceReceived
{
  n_player_data_received++;
  if(n_player_data_received >= n_player_data_to_receive)
  {
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_DATA_LOADED", nil, nil);
  }
  [self percentLoadedChanged];
}

- (void) percentLoadedChanged
{
  NSNumber *percentReceived = [NSNumber numberWithFloat:
                               (float)(n_game_data_received+n_player_data_received)/(float)(n_game_data_to_receive+n_player_data_to_receive)
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
  for(long i = 0; i < models.count; i++)
    if(![(ARISModel *)models[i] gameDataReceived]) return NO;
  return YES;
}

- (void) clearModels
{
  n_game_data_received = 0;
  n_player_data_received = 0;
  
  for(long i = 0; i < models.count; i++)
    [(ARISModel *)models[i] clearPlayerData];
  for(long i = 0; i < models.count; i++)
    [(ARISModel *)models[i] clearGameData];
  
  [displayQueueModel clear]; //what...? should conform to clearPlayerData, even though there is no 'requestPlayerData'
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

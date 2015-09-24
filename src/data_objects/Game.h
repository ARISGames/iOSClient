//
//  Game.h
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "ScenesModel.h"
#import "GroupsModel.h"
#import "PlaquesModel.h"
#import "ItemsModel.h"
#import "DialogsModel.h"
#import "WebPagesModel.h"
#import "NotesModel.h"
#import "TagsModel.h"
#import "EventsModel.h"
#import "RequirementsModel.h"
#import "TriggersModel.h"
#import "FactoriesModel.h"
#import "OverlaysModel.h"
#import "InstancesModel.h"
#import "PlayerInstancesModel.h"
#import "GameInstancesModel.h"
#import "GroupInstancesModel.h"
#import "TabsModel.h"
#import "LogsModel.h"
#import "QuestsModel.h"
#import "DisplayQueueModel.h"

@interface Game : NSObject
{
  long game_id;
  NSString *name;
  NSString *desc;
  BOOL published;
  NSString *type;
  CLLocation *location;
  long player_count;

  long icon_media_id;
  long media_id;

  long intro_scene_id;

  NSMutableArray *authors;
  NSMutableArray *comments;

  NSString *map_type;
  NSString *map_focus;
  CLLocation *map_location;
  double map_zoom_level;
  BOOL map_show_player;
  BOOL map_show_players;
  BOOL map_offsite_mode;

  BOOL notebook_allow_comments;
  BOOL notebook_allow_likes;
  BOOL notebook_allow_player_tags;

  long inventory_weight_cap;
  NSString *network_level;
  BOOL preload_media;

  ScenesModel       *scenesModel;
  GroupsModel       *groupsModel;
  PlaquesModel      *plaquesModel;
  ItemsModel        *itemsModel;
  DialogsModel      *dialogsModel;
  WebPagesModel     *webPagesModel;
  NotesModel        *notesModel;
  TagsModel         *tagsModel;
  EventsModel       *eventsModel;
  RequirementsModel *requirementsModel;
  TriggersModel     *triggersModel;
  FactoriesModel    *factoriesModel;
  OverlaysModel     *overlaysModel;
  InstancesModel    *instancesModel;
  PlayerInstancesModel  *playerInstancesModel;
  GameInstancesModel *gameInstancesModel;
  TabsModel         *tabsModel;
  LogsModel         *logsModel;
  QuestsModel       *questsModel;
  DisplayQueueModel *displayQueueModel;
}

@property (nonatomic, assign) long game_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) BOOL published;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) long player_count;
- (long) rating;

@property (nonatomic, assign) long icon_media_id;
@property (nonatomic, assign) long media_id;

@property (nonatomic, assign) long intro_scene_id;

@property (nonatomic, strong) NSMutableArray *authors;
@property (nonatomic, strong) NSMutableArray *comments;

@property (nonatomic, strong) NSString *map_type;
@property (nonatomic, strong) NSString *map_focus;
@property (nonatomic, strong) CLLocation *map_location;
@property (nonatomic, assign) double map_zoom_level;
@property (nonatomic, assign) BOOL map_show_player;
@property (nonatomic, assign) BOOL map_show_players;
@property (nonatomic, assign) BOOL map_offsite_mode;

@property (nonatomic, assign) BOOL notebook_allow_comments;
@property (nonatomic, assign) BOOL notebook_allow_likes;
@property (nonatomic, assign) BOOL notebook_allow_player_tags;

@property (nonatomic, assign) long inventory_weight_cap;
@property (nonatomic, strong) NSString *network_level;
@property (nonatomic, assign) BOOL preload_media;

@property (nonatomic, strong) ScenesModel       *scenesModel;
@property (nonatomic, strong) GroupsModel       *groupsModel;
@property (nonatomic, strong) PlaquesModel      *plaquesModel;
@property (nonatomic, strong) ItemsModel        *itemsModel;
@property (nonatomic, strong) DialogsModel      *dialogsModel;
@property (nonatomic, strong) WebPagesModel     *webPagesModel;
@property (nonatomic, strong) NotesModel        *notesModel;
@property (nonatomic, strong) TagsModel         *tagsModel;
@property (nonatomic, strong) EventsModel       *eventsModel;
@property (nonatomic, strong) RequirementsModel *requirementsModel;
@property (nonatomic, strong) TriggersModel     *triggersModel;
@property (nonatomic, strong) FactoriesModel    *factoriesModel;
@property (nonatomic, strong) OverlaysModel     *overlaysModel;
@property (nonatomic, strong) InstancesModel    *instancesModel;
@property (nonatomic, strong) PlayerInstancesModel *playerInstancesModel;
@property (nonatomic, strong) GameInstancesModel *gameInstancesModel;
@property (nonatomic, strong) GroupInstancesModel *groupInstancesModel;
@property (nonatomic, strong) TabsModel         *tabsModel;
@property (nonatomic, strong) LogsModel         *logsModel;
@property (nonatomic, strong) QuestsModel       *questsModel;
@property (nonatomic, strong) DisplayQueueModel *displayQueueModel;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;
- (void) mergeDataFromGame:(Game *)g;
- (void) getReadyToPlay;
- (void) requestGameData;
- (void) requestPlayerData;
- (void) endPlay;
- (void) clearModels;

@end


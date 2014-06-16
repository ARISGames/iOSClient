//
//  Game.h
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "PlaquesModel.h"
#import "ItemsModel.h"
#import "DialogsModel.h"
#import "WebPagesModel.h"
#import "TriggersModel.h"
#import "InstancesModel.h"
#import "TabsModel.h"
#import "LogsModel.h"
#import "QuestsModel.h"

#import "NotesModel.h"
#import "OverlaysModel.h"

@interface Game : NSObject
{
  int game_id;
  NSString *name;
  NSString *desc; 

  int icon_media_id; 
  int media_id;  

  NSString *map_type;
  CLLocation *location;
  double zoom_level;

  BOOL show_player_location;
  BOOL full_quick_travel;

  BOOL allow_note_comments;
  BOOL allow_note_player_tags;
  BOOL allow_note_likes;

  int inventory_weight_cap;

  BOOL has_been_played; 
  int player_count;  
    
  NSMutableArray *authors;
  NSMutableArray *comments;

  PlaquesModel    *plaquesModel;  
  ItemsModel      *itemsModel;  
  DialogsModel    *dialogsModel;   
  WebPagesModel   *webPagesModel;    
  TriggersModel   *triggersModel;     
  InstancesModel  *instancesModel;      
  TabsModel       *tabsModel;      
  LogsModel       *logsModel;       
  QuestsModel     *questsModel; 
    
  NotesModel      *notesModel;
  OverlaysModel   *overlaysModel;
}

@property (nonatomic, assign) int game_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc; 

@property (nonatomic, assign) int icon_media_id; 
@property (nonatomic, assign) int media_id;  

@property (nonatomic, strong) NSString *map_type;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) double zoom_level;

@property (nonatomic, assign) BOOL show_player_location;
@property (nonatomic, assign) BOOL full_quick_travel;

@property (nonatomic, assign) BOOL allow_note_comments;
@property (nonatomic, assign) BOOL allow_note_player_tags;
@property (nonatomic, assign) BOOL allow_note_likes;

@property (nonatomic, assign) int inventory_weight_cap;

@property (nonatomic, assign) BOOL has_been_played;
@property (nonatomic, assign) int player_count;

@property (nonatomic, strong) NSMutableArray *authors;
@property (nonatomic, strong) NSMutableArray *comments;
- (int) rating;

@property (nonatomic, strong) PlaquesModel   *plaquesModel; 
@property (nonatomic, strong) ItemsModel     *itemsModel; 
@property (nonatomic, strong) DialogsModel   *dialogsModel; 
@property (nonatomic, strong) WebPagesModel  *webPagesModel; 
@property (nonatomic, strong) TriggersModel  *triggersModel; 
@property (nonatomic, strong) InstancesModel *instancesModel; 
@property (nonatomic, strong) TabsModel      *tabsModel; 
@property (nonatomic, strong) LogsModel      *logsModel; 
@property (nonatomic, strong) QuestsModel    *questsModel;
@property (nonatomic, strong) NotesModel     *notesModel;
@property (nonatomic, strong) OverlaysModel  *overlaysModel;

- (id) initWithDictionary:(NSDictionary *)dict;
- (void) mergeDataFromGame:(Game *)g;
- (void) getReadyToPlay;
- (void) requestGameData;
- (void) requestPlayerData;
- (void) endPlay;
- (void) clearModels;

@end

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
#import "NpcsModel.h"
#import "NotesModel.h"
#import "QuestsModel.h"
#import "LocationsModel.h"
#import "Media.h"
#import "OverlaysModel.h"

@interface Game : NSObject
{
  int game_id;
  NSString *name;
  NSString *desc; 

  int icon_media_id; 
  Media *iconMedia;
  int media_id;  
  Media *media; 

  NSString *map_type;
  CLLocation *location;
  double zoom_level;

  BOOL show_player_location;
  BOOL full_quick_travel;

  BOOL allow_note_comments;
  BOOL allow_note_player_tags;
  BOOL allow_note_likes;

  int inventory_weight_cap;

  NSMutableArray *authors;
  NSMutableArray *comments;

  PlaquesModel    *plaquesModel;  
  ItemsModel      *itemsModel;  
  NpcsModel       *npcsModel;   
  NotesModel      *notesModel;
  QuestsModel     *questsModel;
  LocationsModel  *locationsModel;
  OverlaysModel   *overlaysModel;
}

@property (nonatomic, assign) int game_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc; 

@property (nonatomic, assign) int icon_media_id; 
@property (nonatomic, strong) Media *iconMedia;
@property (nonatomic, assign) int media_id;  
@property (nonatomic, strong) Media *media; 

@property (nonatomic, strong) NSString *map_type;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) double zoom_level;

@property (nonatomic, assign) BOOL show_player_location;
@property (nonatomic, assign) BOOL full_quick_travel;

@property (nonatomic, assign) BOOL allow_note_comments;
@property (nonatomic, assign) BOOL allow_note_player_tags;
@property (nonatomic, assign) BOOL allow_note_likes;

@property (nonatomic, assign) int inventory_weight_cap;

@property (nonatomic, strong) NSMutableArray *authors;
@property (nonatomic, strong) NSMutableArray *comments;

@property (nonatomic, strong) PlaquesModel   *plaquesModel; 
@property (nonatomic, strong) ItemsModel     *itemsModel; 
@property (nonatomic, strong) NpcsModel      *npcsModel; 
@property (nonatomic, strong) NotesModel     *notesModel;
@property (nonatomic, strong) QuestsModel    *questsModel;
@property (nonatomic, strong) LocationsModel *locationsModel;
@property (nonatomic, strong) OverlaysModel  *overlaysModel;

- (void) getReadyToPlay;
- (void) clearLocalModels;
- (void) endPlay;

@end

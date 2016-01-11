//
//  ScenesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "ScenesModel.h"
#import "AppModel.h"
#import "AppServices.h"
#import "SBJson.h"

@interface ScenesModel()
{
  NSMutableDictionary *scenes;
}

@end

@implementation ScenesModel

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_SCENES_RECEIVED",self,@selector(scenesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_SCENE_TOUCHED",self,@selector(sceneTouched:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_SCENE_RECEIVED",self,@selector(playerSceneReceived:),nil);
  }
  return self;
}

- (void) requestGameData
{
  [self requestScenes];
}
- (void) clearGameData
{
  scenes = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) requestMaintenanceData
{
  [self touchPlayerScene];
}
- (void) clearMaintenanceData
{
  n_maintenance_data_received = 0;
}
- (long) nMaintenanceDataToReceive
{
  return 1;
}

- (void) requestPlayerData
{
  [self requestPlayerScene];
}
- (void) clearPlayerData
{
  playerScene = nil;
  n_player_data_received = 0;
}
- (long) nPlayerDataToReceive
{
  return 1;
}

- (void) scenesReceived:(NSNotification *)notif
{
  [self updateScenes:notif.userInfo[@"scenes"]];
}

- (void) playerSceneReceived:(NSNotification *)notif
{
  //A bit of hack verification to ensure valid scene. Ideally shouldn't be needed...
  BOOL overridden = NO;
  Scene *s = [self sceneForId:((Scene *)notif.userInfo[@"scene"]).scene_id];
  if(s.scene_id == 0)
  {
    overridden = YES;
    s = [self sceneForId:_MODEL_GAME_.intro_scene_id]; //received scene not valid
  }
  if(s.scene_id == 0 && [scenes allValues].count > 0) //received scene not valid, intro_scene not valid
  {
    overridden = YES;
    s = [scenes allValues][0]; //choose arbitrary scene to ensure valid state
  }

  if(overridden) [self setPlayerScene:s];
  [self updatePlayerScene:s];
}

- (void) sceneTouched:(NSNotification *)notif
{
  n_maintenance_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_SCENE_TOUCHED",nil,nil);
  _ARIS_NOTIF_SEND_(@"MAINTENANCE_PIECE_AVAILABLE",nil,nil);
}

- (void) updateScenes:(NSArray *)newScenes
{
  Scene *newScene;
  NSNumber *newSceneId;
  for(long i = 0; i < newScenes.count; i++)
  {
    newScene = [newScenes objectAtIndex:i];
    newSceneId = [NSNumber numberWithLong:newScene.scene_id];
    if(!scenes[newSceneId]) [scenes setObject:newScene forKey:newSceneId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_SCENES_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) updatePlayerScene:(Scene *)newScene
{
  playerScene = newScene;
  n_player_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_SCENES_PLAYER_SCENE_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (void) requestScenes
{
  [_SERVICES_ fetchScenes];
}

- (void) touchPlayerScene
{
  [_SERVICES_ touchSceneForPlayer];
}

- (void) requestPlayerScene
{
  if([self playerDataReceived] &&
     ![_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
  {
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_SCENE_RECEIVED",nil,@{@"scene":playerScene}); //just return current
  }
  if(![self playerDataReceived] ||
     [_MODEL_GAME_.network_level isEqualToString:@"HYBRID"] ||
     [_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
    [_SERVICES_ fetchSceneForPlayer];
}

- (Scene *) playerScene
{
  return playerScene;
}

- (void) setPlayerScene:(Scene *)s
{
  playerScene = s;
  [_MODEL_LOGS_ playerChangedSceneId:s.scene_id];
  if(![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
    [_SERVICES_ setPlayerSceneId:s.scene_id];
  _ARIS_NOTIF_SEND_(@"MODEL_SCENES_PLAYER_SCENE_AVAILABLE",nil,nil);
}

// null scene (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Scene *) sceneForId:(long)scene_id
{
  if(!scene_id) return [[Scene alloc] init];
  return scenes[[NSNumber numberWithLong:scene_id]];
}

- (NSString *) serializedName
{
  return @"scenes";
}

- (NSString *) serializeGameData
{
  NSArray *scenes_a = [scenes allValues];
  Scene *s_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"scenes\":["];
  for(long i = 0; i < scenes_a.count; i++)
  {
    s_o = scenes_a[i];
    [r appendString:[s_o serialize]];
    if(i != scenes_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_scenes = d_data[@"scenes"];
  for(long i = 0; i < d_scenes.count; i++)
  {
    Scene *s = [[Scene alloc] initWithDictionary:d_scenes[i]];
    [scenes setObject:s forKey:[NSNumber numberWithLong:s.scene_id]];
  }
  n_game_data_received = [self nGameDataToReceive];
}

- (NSString *) serializePlayerData
{
  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"scene\":"];
  [r appendString:[playerScene serialize]];
  [r appendString:@"}"];
  return r;
}

- (void) deserializePlayerData:(NSString *)data
{
  [self clearPlayerData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  Scene *s = [[Scene alloc] initWithDictionary:d_data[@"scene"]];
  playerScene = [_MODEL_SCENES_ sceneForId:s.scene_id];
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end


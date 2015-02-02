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

- (void) clearGameData
{
    scenes = [[NSMutableDictionary alloc] init];
}
- (void) clearPlayerData
{
    playerScene = nil;
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
    _ARIS_NOTIF_SEND_(@"MODEL_SCENE_TOUCHED",nil,nil);   
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);      
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
    _ARIS_NOTIF_SEND_(@"MODEL_SCENES_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) updatePlayerScene:(Scene *)newScene
{
    playerScene = newScene;
    _ARIS_NOTIF_SEND_(@"MODEL_SCENES_PLAYER_SCENE_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);
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
    [_SERVICES_ setPlayerSceneId:s.scene_id];
    _ARIS_NOTIF_SEND_(@"MODEL_SCENES_PLAYER_SCENE_AVAILABLE",nil,nil);
}

// null scene (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Scene *) sceneForId:(long)scene_id
{
  if(!scene_id) return [[Scene alloc] init];
  return scenes[[NSNumber numberWithLong:scene_id]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

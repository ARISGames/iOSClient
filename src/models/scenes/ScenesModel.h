//
//  ScenesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Scene.h"

@interface ScenesModel : NSObject
{
    Scene *playerScene;
}

- (Scene *) sceneForId:(long)scene_id;
- (Scene *) playerScene;
- (void) setPlayerScene:(Scene *)s;
- (void) requestScenes;
- (void) touchPlayerScene;
- (void) requestPlayerScene;
- (void) clearGameData;
- (void) clearPlayerData;

@end

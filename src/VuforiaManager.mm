//
//  VuforiaManager.mm
//  ARIS
//
//  Created by Michael Tolly on 11/23/16.
//
//

#import <Foundation/Foundation.h>
#import "VuforiaManager.h"

#import <Vuforia/Vuforia.h>
#import <Vuforia/Vuforia_iOS.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/CameraDevice.h>
#import <Vuforia/VideoBackgroundConfig.h>
#import <Vuforia/UpdateCallback.h>

namespace {
    // --- Data private to this unit ---
    
    // camera to use for the session
    Vuforia::CameraDevice::CAMERA_DIRECTION mCamera = Vuforia::CameraDevice::CAMERA_DIRECTION_DEFAULT;
    
    // class used to support the Vuforia callback mechanism
    class VuforiaApplication_UpdateCallback : public Vuforia::UpdateCallback {
        virtual void Vuforia_onUpdate(Vuforia::State& state);
    } vuforiaUpdate;
}

@interface VuforiaManager()
{
}
@end

@implementation VuforiaManager

- (id) init
{
    if(self = [super init])
    {
        [self performSelectorInBackground:@selector(initVuforiaInBackground) withObject:nil];
    }
    return self;
}

// Initialise Vuforia
// (Performed on a background thread)
- (void)initVuforiaInBackground
{
    // Background thread must have its own autorelease pool
    @autoreleasepool {
        Vuforia::setInitParameters(Vuforia::GL_20,"AWpb2lv/////AAAAAffPRasT3UpvhUgTj96Ao/9uiSynAzP5mFiKJ7JDBR/eNFBXtoouLGr60JrvrHon58cDlMzkXtUbk4is0nbk2N2BSh4UUTVEK0Mffpbrq5VnjlM8hyT3lG/yV69a3lDfR3imTifpcRnJdUcIDu+FzRBB6sBnWo6g8PkadMK0forJ+3YcEGYXqQQ36qaWONoLUBfBJm+EYtsJhLlZ/Lw58812ifMWKE73LcabB1CJpEZYVSLedsXzopSKb7ip/UenF7cETxQjq3F++wbQaPQ86kBTHVcTS6605u/1dxHkKHco4XndwuSjFb3FwJtVC+fYuu+l5zTVsG9OSwlEnhet/FvhIxmFPANsjWHNUT0uR5wS");
        
        // Vuforia::init() will return positive numbers up to 100 as it progresses
        // towards success.  Negative numbers indicate error conditions
        NSInteger initSuccess = 0;
        do {
            initSuccess = Vuforia::init();
        } while (0 <= initSuccess && 100 > initSuccess);
        
        if (100 == initSuccess) {
            // We can now continue the initialization of Vuforia
            // (on the main thread)
            NSLog(@"Vuforia: loaded successfully");
        }
        else {
            // Failed to initialise Vuforia:
            if (Vuforia::INIT_NO_CAMERA_ACCESS == initSuccess) {
                NSLog(@"Vuforia: no camera access");
            }
            else {
                NSLog(@"Vuforia: error occurred");
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Callback function called by the tracker when each tracking cycle has finished
void VuforiaApplication_UpdateCallback::Vuforia_onUpdate(Vuforia::State& state)
{
    //if (instance != nil) {
    //    [instance Vuforia_onUpdate:&state];
    //}
}

@end

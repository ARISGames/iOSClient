//
//  ARISAppDelegate.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "AppServices.h"

#import "RootViewController.h"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <CoreMotion/CoreMotion.h>

#import "Reachability.h"



@interface ARISAppDelegate : NSObject <AVAudioPlayerDelegate,UIApplicationDelegate, UIAccelerometerDelegate> {
	UIWindow *window;
    AVAudioPlayer *player;
}

@property (nonatomic) UIWindow *window;
@property (nonatomic, strong) AVAudioPlayer *player;

- (void) vibrate;
- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate;
- (void) stopAudio;
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (void) resetCurrentlyFetchingVars;
- (void) startMyMotionDetect;
@end

//
//  ARISAppDelegate.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "Trigger.h"
#import "SampleGLResourceHandler.h"

#define _DELEGATE_ ((ARISAppDelegate *)[[UIApplication sharedApplication] delegate])

@interface ARISAppDelegate : NSObject <UIApplicationDelegate>
{
  UIWindow *window;
  Reachability *reachability;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, weak) id<SampleGLResourceHandler> glResourceHandler;

- (void) vibrate;
- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate;
- (void) stopAudio;
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (void) addBeaconForTrigger:(Trigger *)trigger;
- (void) clearBeacons;
- (CLProximity) proximityToBeaconTrigger:(Trigger *)trigger;

@end

//
//  ARISAppDelegate.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface ARISAppDelegate : NSObject <UIApplicationDelegate>
{
  UIWindow *window;
  Reachability *reachability;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) Reachability *reachability;

- (void) vibrate;
- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate;
- (void) stopAudio;
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url;

@end

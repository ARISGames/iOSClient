//
//  ARISAppDelegate.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import "ARISAppDelegate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "AudioToolbox/AudioToolbox.h"
#import "Reachability.h"
#import "Player.h"
#import "UploadMan.h"
#import "TestFlight.h"
#import <Crashlytics/Crashlytics.h>

#import "UIColor+ARISColors.h"

#import "AppModel.h"
#import "AppServices.h"
#import "RootViewController.h"

@interface ARISAppDelegate() <UIAccelerometerDelegate, AVAudioPlayerDelegate>
{
    NSTimer *locationPoller;
    AVAudioPlayer *player;
    
    int readingCountUpToOneHundredThousand;
    int steps;
}
@end

@implementation ARISAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{    
    application.idleTimerDisabled = YES;
    
    [TestFlight takeOff:@"71a0800e-c39f-43b7-9308-1d4b6a4d9f73"];
    [Crashlytics startWithAPIKey:@"998e417813fdeb68d423930898cf8efc3001db1a"];
    
    //Init keys in UserDefaults in case the user has not visited the ARIS Settings page
	//To set these defaults, edit Settings.bundle->Root.plist
	[[AppModel sharedAppModel] initUserDefaults];
    
    readingCountUpToOneHundredThousand = 0;
    steps = 0;
    
    [self setApplicationUITemplates];
    
    [self.window setRootViewController:[RootViewController sharedRootViewController]];
    [self.window makeKeyAndVisible];
}

- (void) setApplicationUITemplates
{
    self.window.rootViewController.edgesForExtendedLayout = UIRectEdgeAll;
    self.window.rootViewController.extendedLayoutIncludesOpaqueBars = NO;
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0], UITextAttributeFont,
      [UIColor ARISColorNavBarText],                          UITextAttributeTextColor,
      [UIColor clearColor],                                   UITextAttributeTextShadowColor,
      nil]
     ];
    
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"HelveticaNeue-Light" size:0.0], UITextAttributeFont,
      [UIColor ARISColorTabBarText],                         UITextAttributeTextColor,
      nil] 
                                             forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"HelveticaNeue-Light" size:12], UITextAttributeFont,
      [UIColor ARISColorTabBarText],                        UITextAttributeTextColor,
      [UIColor clearColor],                                 UITextAttributeTextShadowColor,
      nil]
                                                   forState:UIControlStateNormal];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"ARIS: Application Became Active");
	[[AppModel sharedAppModel]       loadUserDefaults];
    [[AppServices sharedAppServices] resetCurrentlyFetchingVars];
    
    if([AppModel sharedAppModel].fallbackGameId != 0 && ![AppModel sharedAppModel].currentGame)
        [[AppServices sharedAppServices] fetchOneGameGameList:[AppModel sharedAppModel].fallbackGameId];
    else if([AppModel sharedAppModel].player.playerId > 0)
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PlayerAlreadyLoggedIn" object:nil]];
    
    [[[AppModel sharedAppModel] uploadManager] checkForFailedContent];
    
    [self startPollingLocation];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"NSNotification: LowMemoryWarning");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LowMemoryWarning" object:nil]];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	NSLog(@"ARIS: Resigning Active Application");
	[[AppModel sharedAppModel] saveUserDefaults];
    
    [self stopPollingLocation];
}

-(void) applicationWillTerminate:(UIApplication *)application
{
	NSLog(@"ARIS: Terminating Application");
	[[AppModel sharedAppModel] saveUserDefaults];
    [[AppModel sharedAppModel] saveCOREData];
}

- (void) startPollingLocation
{
    locationPoller = [NSTimer scheduledTimerWithTimeInterval:3.0 target:[[MyCLController sharedMyCLController]locationManager] selector:@selector(startUpdatingLocation) userInfo:nil repeats:NO];
}

- (void) stopPollingLocation
{
    [locationPoller invalidate];
}

- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate
{
	if (shouldVibrate == YES) [NSThread detachNewThreadSelector:@selector(vibrate) toTarget:self withObject:nil];	
	[NSThread detachNewThreadSelector:@selector(playAudio:) toTarget:self withObject:wavFileName];
}

- (void) playAudio:(NSString*)fileName
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    [player play];
}

- (void)stopAudio
{
    if(player) [player stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
}

- (void)vibrate
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  
}

// handle opening ARIS using custom URL of form ARIS://game/397 
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if(!url) return NO;
    
    NSString *strPath = [[url host] lowercaseString];
    if ([strPath isEqualToString:@"games"] || [strPath isEqualToString:@"game"])
    {
        NSString *gameID = [url lastPathComponent];
        [[NSNotificationCenter defaultCenter] addObserver:window.rootViewController selector:@selector(singleGameRequestReady:)  name:@"NewOneGameGameListReady"  object:nil];
        [[AppServices sharedAppServices] fetchOneGameGameList:[gameID intValue]];
    }
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

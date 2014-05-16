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
#import "User.h"
#import "TestFlight.h"
#import <Crashlytics/Crashlytics.h>

#import "ARISTemplate.h"

#import "AppModel.h"
#import "AppServices.h"
#import "RootViewController.h"

@interface ARISAppDelegate() <UIAccelerometerDelegate, AVAudioPlayerDelegate>
{
    Reachability *reachability; 
    NSTimer *locationPoller;
    AVAudioPlayer *player;
}
@end

@implementation ARISAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{    
    application.idleTimerDisabled = YES;
    
    [TestFlight takeOff:@"71a0800e-c39f-43b7-9308-1d4b6a4d9f73"];
    [Crashlytics startWithAPIKey:@"998e417813fdeb68d423930898cf8efc3001db1a"];
    
    [self setApplicationUITemplates];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
    [self.window setRootViewController:[RootViewController sharedRootViewController]];
    [self.window makeKeyAndVisible];
    
    _ARIS_NOTIF_LISTEN_(kReachabilityChangedNotification,self,@selector(reachabilityChanged:),nil);
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];  
}

- (void) setApplicationUITemplates
{
    self.window.rootViewController.edgesForExtendedLayout = UIRectEdgeAll;
    self.window.rootViewController.extendedLayoutIncludesOpaqueBars = NO;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor whiteColor]];

    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [ARISTemplate ARISNavTitleFont],     UITextAttributeFont,
      [ARISTemplate ARISColorNavBarText],  UITextAttributeTextColor,
      [UIColor clearColor],                UITextAttributeTextShadowColor,
      nil]
     ];
    
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [ARISTemplate ARISTabTitleFont],    UITextAttributeFont, 
      [ARISTemplate ARISColorTabBarText], UITextAttributeTextColor,
      nil] 
                                             forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [ARISTemplate ARISButtonFont],      UITextAttributeFont,
      [ARISTemplate ARISColorTabBarText], UITextAttributeTextColor,
      [UIColor clearColor],               UITextAttributeTextShadowColor,
      nil]
                                                   forState:UIControlStateNormal];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"ARIS: Application Became Active");
    [_MODEL_ loadUserDefaults];
    [self startPollingLocation];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
  _ARIS_NOTIF_SEND_(@"LowMemoryWarning",nil,nil);
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	NSLog(@"ARIS: Resigning Active Application");
	[_MODEL_ saveUserDefaults];
    
    [self stopPollingLocation];
}

-(void) applicationWillTerminate:(UIApplication *)application
{
	NSLog(@"ARIS: Terminating Application");
	[_MODEL_ saveUserDefaults];
    [_MODEL_ commitCoreDataContexts];
}

- (void) startPollingLocation
{
    //locationPoller = [NSTimer scheduledTimerWithTimeInterval:3.0 target:[[MyCLController sharedMyCLController]locationManager] selector:@selector(startUpdatingLocation) userInfo:nil repeats:NO];
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
  _ARIS_NOTIF_LISTEN_(@"NewOneGameGameListReady",window.rootViewController,@selector(singleGameRequestReady:),nil);
        [_SERVICES_ fetchOneGameGameList:[gameID intValue]];
    }
    return YES;
}

- (void) reachabilityChanged:(NSNotification *)notice
{
    switch ([reachability currentReachabilityStatus])
    {
        case NotReachable: { }
        case ReachableViaWWAN: { } 
        case ReachableViaWiFi:
        {
  _ARIS_NOTIF_SEND_(@"WifiConnected",self,nil);
            break;            
        }
    }    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

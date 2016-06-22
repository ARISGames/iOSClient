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
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreMotion/CoreMotion.h>
#import "AudioToolbox/AudioToolbox.h"
#import "User.h"
#import <Crashlytics/Crashlytics.h>

#import "ARISDefaults.h"
#import "AppModel.h"
#import "AppServices.h"
#import "RootViewController.h"

@interface ARISAppDelegate() <UIAccelerometerDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate>
{
  CLLocationManager *locationManager;
  NSTimer *locationPoller;
  CLLocation *lastKnownLocation;
  AVAudioPlayer *player;
}
@end

@implementation ARISAppDelegate

@synthesize window;
@synthesize reachability;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
  application.statusBarOrientation = UIInterfaceOrientationPortrait;
  application.idleTimerDisabled = YES;

  [self setApplicationUITemplates];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self.window setRootViewController:[RootViewController sharedRootViewController]];
  [self.window makeKeyAndVisible];

  //init the singletons. I know. defeats the point of singletons. but they prob shouldn't be singletons then.
  _DEFAULTS_;
  _MODEL_;
  [_DEFAULTS_ loadUserDefaults]; //check if changed since last active

  _SERVICES_;

  NSLog(@"Local Docs Dir: %@",[_MODEL_ applicationDocumentsDirectory]);

  //Init after model, as they might be listening for updates
  _ARIS_NOTIF_LISTEN_(kReachabilityChangedNotification,self,@selector(reachabilityChanged:),nil);
  reachability = [Reachability reachabilityForInternetConnection];
  [reachability startNotifier];
  locationManager = [[CLLocationManager alloc] init];
  if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    [locationManager requestWhenInUseAuthorization];
  locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
  locationManager.distanceFilter = 5; //Minimum change of 5 meters for update
  locationManager.delegate = self;

  if(_DEFAULTS_.fallbackUser && _DEFAULTS_.fallbackUser.user_id) [_MODEL_ logInPlayer:_DEFAULTS_.fallbackUser];
  if(_DEFAULTS_.fallbackGameId) _ARIS_LOG_(@"I should start loading %ld, but I won't",_DEFAULTS_.fallbackGameId);
}

- (void) setApplicationUITemplates
{
  self.window.rootViewController.edgesForExtendedLayout = UIRectEdgeAll;
  self.window.rootViewController.extendedLayoutIncludesOpaqueBars = NO;

  [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor whiteColor]];

  [[UINavigationBar appearance] setTitleTextAttributes:
    [NSDictionary dictionaryWithObjectsAndKeys:
    [ARISTemplate ARISNavTitleFont],     NSFontAttributeName,
    [ARISTemplate ARISColorNavBarText],  NSForegroundColorAttributeName,
    //[UIColor clearColor],                NSShadowAttributeName,
    nil]
      ];

  [[UITabBarItem appearance] setTitleTextAttributes:
    [NSDictionary dictionaryWithObjectsAndKeys:
    [ARISTemplate ARISTabTitleFont],    NSFontAttributeName,
    [ARISTemplate ARISColorTabBarText], NSForegroundColorAttributeName,
    nil]
      forState:UIControlStateNormal];

  [[UISegmentedControl appearance] setTitleTextAttributes:
    [NSDictionary dictionaryWithObjectsAndKeys:
    [ARISTemplate ARISButtonFont],      NSFontAttributeName,
    [ARISTemplate ARISColorTabBarText], NSForegroundColorAttributeName,
    //[UIColor clearColor],               NSShadowAttributeName,
    nil]
      forState:UIControlStateNormal];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
  _ARIS_LOG_(@"ARIS: Application Became Active");
  [self startPollingLocation];
  [_DEFAULTS_ loadUserDefaults]; //check if changed since last active

  if(_DEFAULTS_.fallbackUser && _DEFAULTS_.fallbackUser.user_id &&
      !(_MODEL_PLAYER_ && _MODEL_PLAYER_.user_id))
    [_MODEL_ logInPlayer:_DEFAULTS_.fallbackUser];
  if(_DEFAULTS_.fallbackGameId) _ARIS_LOG_(@"I should start loading %ld, but I won't",_DEFAULTS_.fallbackGameId);
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
  _ARIS_NOTIF_SEND_(@"LowMemoryWarning",nil,nil);
}

- (void) applicationWillResignActive:(UIApplication *)application
{
  _ARIS_LOG_(@"ARIS: Resigning Active Application");
  [self stopPollingLocation];
}

-(void) applicationWillTerminate:(UIApplication *)application
{
  _ARIS_LOG_(@"ARIS: Terminating Application");
  [_MODEL_ commitCoreDataContexts];
}

- (void) startPollingLocation
{
  [locationManager startUpdatingLocation];
  locationPoller = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(findCurrentLocation) userInfo:nil repeats:YES];
}

- (void) findCurrentLocation
{
  CLLocation *l;
  if((l = locationManager.location))
    [self locationManager:locationManager didUpdateLocations:@[l]]; //sketchy imitate auto-update
}

- (void) stopPollingLocation
{
  [locationManager stopUpdatingLocation];
  [locationPoller invalidate];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  //last location in locations array (guaranteed count >= 1) is most recent
  if(lastKnownLocation && [lastKnownLocation distanceFromLocation:locations[locations.count-1]] < 0.01f) return;
  lastKnownLocation = locations[locations.count-1];
  _ARIS_NOTIF_SEND_(@"DEVICE_MOVED", nil, @{@"location":lastKnownLocation});
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  // The location "unknown" error simply means the manager is currently unable to get the location.
  // We can ignore this error for the scenario of getting a single location fix, because we already have a
  // timeout that will stop the location manager to save power.
  if ([error code] != kCLErrorLocationUnknown) {
    _ARIS_LOG_(@"ERROR");
    //[self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
  }
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
    _ARIS_NOTIF_LISTEN_(@"NewOneGameGameListReady",window.rootViewController,@selector(singleGameRequestReady:),nil);
  return YES;
}

- (void) reachabilityChanged:(NSNotification *)notice
{
  switch ([reachability currentReachabilityStatus])
  {
    case NotReachable: break;
    case ReachableViaWWAN:
    case ReachableViaWiFi:
        _ARIS_NOTIF_SEND_(@"WIFI_CONNECTED",self,nil); break;
  }
}

- (void)dealloc
{
  [self stopPollingLocation];
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

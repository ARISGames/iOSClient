//
//  ARISAppDelegate.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import "ARISAppDelegate.h"

@interface ARISAppDelegate ()
{
    NSTimer *locationPoller;
    AVAudioPlayer *player;
    
    int readingCountUpToOneHundredThousand;
    int steps;
}

@property (nonatomic, strong) AVAudioPlayer *player;

@end
@implementation ARISAppDelegate

@synthesize window;
@synthesize player;

#pragma mark -
#pragma mark Application State

- (void) applicationDidFinishLaunching:(UIApplication *)application
{    
    application.idleTimerDisabled = YES;
    
    [Crittercism enableWithAppID:@"5101a46d59e1bd498c000002"];
    //Init keys in UserDefaults in case the user has not visited the ARIS Settings page
	//To set these defaults, edit Settings.bundle->Root.plist
	[[AppModel sharedAppModel] initUserDefaults];
    
    readingCountUpToOneHundredThousand = 0;
    steps = 0;
    
    //DARK BLUE-  [UIColor colorWithRed:(0.0/255.0)   green:(101.0/255.0)  blue:(149.0/255.0) alpha:1.0];
    //LIGHT BLUE- [UIColor colorWithRed:(132.0/255.0) green:(153.0/255.0)  blue:(165.0/255.0) alpha:1.0];
    //ORANGE-     [UIColor colorWithRed:(249.0/255.0) green:(99.0/255.0)   blue:(2.0/255.0)   alpha:1.0];
    //RED-        [UIColor colorWithRed:(237.0/255.0) green:(23.0/255.0)   blue:(79.0/255.0)  alpha:1.0];
    //YELLOW-     [UIColor colorWithRed:(216.0/255.0) green:(181.0/255.0)  blue:(17.0/255.0)  alpha:1.0];
    //BLACK-      [UIColor colorWithRed:(?.0/255.0)   green:(?.0/255.0)    blue:(?.0/255.0)   alpha:1.0];
    //LIGHT GRAY- [UIColor colorWithRed:(228.0/255.0) green:(229.0/255.0)  blue:(230.0/255.0) alpha:1.0];
    //WHITE-      [UIColor colorWithRed:(0.0/255.0)   green:(0.0/255.0)    blue:(0.0/255.0)   alpha:1.0];
    //OFFWHITE-   [UIColor colorWithRed:(214.0/255.0) green:(218.0/255.0)  blue:(211.0/255.0) alpha:1.0];
    //[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:(0.0/255.0)   green:(101.0/255.0)  blue:(149.0/255.0) alpha:1.0]];
    //[[UITabBar appearance]        setTintColor:[UIColor colorWithRed:(0.0/255.0)   green:(101.0/255.0)  blue:(149.0/255.0) alpha:1.0]];
    //[[UIToolbar appearance]       setTintColor:[UIColor colorWithRed:(132.0/255.0) green:(153.0/255.0)  blue:(165.0/255.0) alpha:1.0]];
    //[[UISearchBar appearance]     setTintColor:[UIColor colorWithRed:(132.0/255.0) green:(153.0/255.0)  blue:(165.0/255.0) alpha:1.0]];

    if([window respondsToSelector:@selector(setRootViewController:)])
        window.rootViewController = [RootViewController sharedRootViewController];
    else
        [window addSubview:[RootViewController sharedRootViewController].view];
    
    [self.window makeKeyAndVisible];
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

- (void) startMyMotionDetect
{
    if(![AppModel sharedAppModel].motionManager.accelerometerAvailable) return;
    
    [AppModel sharedAppModel].motionManager.accelerometerUpdateInterval = 0.2;
    NSOperationQueue *motionQueue = [[NSOperationQueue alloc] init];
    [[AppModel sharedAppModel].motionManager startAccelerometerUpdatesToQueue: motionQueue withHandler:
        ^(CMAccelerometerData *data, NSError *error) { [self accelerometerData: data errorMessage: error];}
        ];
}

- (void)accelerometerData:(CMAccelerometerData *)data errorMessage:(NSError *)error
{
    float minAccelX = 1.2;
    float minAccelY = 1.2;
    float minAccelZ = 1.2;
    [AppModel sharedAppModel].averageAccelerometerReadingX = ([AppModel sharedAppModel].averageAccelerometerReadingX + data.acceleration.x)/2;
    [AppModel sharedAppModel].averageAccelerometerReadingY = ([AppModel sharedAppModel].averageAccelerometerReadingY + data.acceleration.y)/2;
    [AppModel sharedAppModel].averageAccelerometerReadingZ = ([AppModel sharedAppModel].averageAccelerometerReadingZ + data.acceleration.z)/2;
    if(readingCountUpToOneHundredThousand >= 100000){
        minAccelX = [AppModel sharedAppModel].averageAccelerometerReadingX * 2;
        minAccelY = [AppModel sharedAppModel].averageAccelerometerReadingY * 2;
        minAccelZ = [AppModel sharedAppModel].averageAccelerometerReadingZ * 2;
    }
    else readingCountUpToOneHundredThousand++;
    static BOOL beenhere;
    BOOL shake = FALSE;
    if (beenhere) return;
    beenhere = TRUE;
    if (data.acceleration.x > minAccelX || data.acceleration.x < (-1* minAccelX)){
        shake = TRUE;
        NSLog(@"Shaken X: %f", data.acceleration.x);
    }
    if (data.acceleration.y > minAccelY || data.acceleration.y < (-1* minAccelY)){
        shake = TRUE;
        NSLog(@"Shaken Y: %f", data.acceleration.y);
    }
    if (data.acceleration.z > minAccelZ || data.acceleration.z < (-1* minAccelZ)){
        shake = TRUE;
            NSLog(@"Shaken Z: %f", data.acceleration.x);
    }
    if (shake) {
        steps++;
        [self playAudioAlert:@"pingtone" shouldVibrate:YES]; 
    }
    beenhere = false;
    NSLog(@"Number of steps: %d", steps);
} 

#pragma mark - Audio

- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate
{
	if (shouldVibrate == YES) [NSThread detachNewThreadSelector:@selector(vibrate) toTarget:self withObject:nil];	
	[NSThread detachNewThreadSelector:@selector(playAudio:) toTarget:self withObject:wavFileName];
}

- (void)playAudio:(NSString*)wavFileName
{
	NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:wavFileName ofType:@"wav"]];

    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    NSError* err;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL: url error:&err];
    self.player.delegate = self;
    
    if(err) NSLog(@"Appdelegate: Playing Audio: Failed with reason: %@", [err localizedDescription]);
    else [self.player play];
}

- (void)stopAudio
{
    if(self.player) [self.player stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
}

- (void)vibrate
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  
}

// handle opening ARIS using custom URL of form ARIS://?game=397 
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }

    NSString *strPath = [[url host] lowercaseString];
    if ([strPath isEqualToString:@"games"] || [strPath isEqualToString:@"game"])
    {
        NSString *gameID = [url lastPathComponent];
        [[AppServices sharedAppServices] fetchOneGameGameList:[gameID intValue]];
    }
    return YES;
}

#pragma mark Memory Management
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

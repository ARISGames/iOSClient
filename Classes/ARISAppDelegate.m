//
//  ARISAppDelegate.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import "ARISAppDelegate.h"

@implementation ARISAppDelegate

int readingCountUpToOneHundredThousand = 0;
int steps = 0;

@synthesize window;
@synthesize player;

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != nil) {
        NSLog(@"Error: %@", error);
    }
}

#pragma mark -
#pragma mark Application State


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/movie.m4v"]];
    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    
    
	//[application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];	
	application.idleTimerDisabled = YES;
    
    //Log the current Language
	NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	NSLog(@"Current Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
	NSLog(@"Current language: %@", currentLanguage);
    
    //[[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.2];
    
    //Init keys in UserDefaults in case the user has not visited the ARIS Settings page
	//To set these defaults, edit Settings.bundle->Root.plist
	[[AppModel sharedAppModel] initUserDefaults];

    if([window respondsToSelector:@selector(setRootViewController:)])
        [window setRootViewController:[RootViewController sharedRootViewController]];
    else
        [window addSubview:[RootViewController sharedRootViewController].view];
    
    [Crittercism enableWithAppID: @"5101a46d59e1bd498c000002"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"AppDelegate: applicationDidBecomeActive");
	[[AppModel sharedAppModel]       loadUserDefaults];
    [[AppServices sharedAppServices] resetCurrentlyFetchingVars];

    if([AppModel sharedAppModel].fallbackGameId != 0 && ![AppModel sharedAppModel].currentGame)
        [[AppServices sharedAppServices] fetchOneGameGameList:[AppModel sharedAppModel].fallbackGameId];
    
    [[AppServices sharedAppServices] setShowPlayerOnMap];
    
    [[[AppModel sharedAppModel]uploadManager] checkForFailedContent];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"AppDelegate: LOW MEMORY WARNING RECIEVED");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LowMemoryWarning" object:nil]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"AppDelegate: Begin Application Resign Active");
    
    [[RootViewController sharedRootViewController].gamePlayTabBarController dismissModalViewControllerAnimated:NO];
    
	[[AppModel sharedAppModel] saveUserDefaults];
}

-(void) applicationWillTerminate:(UIApplication *)application {
	NSLog(@"AppDelegate: Begin Application Termination");
	[[AppModel sharedAppModel] saveUserDefaults];
    [[AppModel sharedAppModel] saveCOREData];
}

- (void)startMyMotionDetect
{
    if(![AppModel sharedAppModel].motionManager.accelerometerAvailable) { 
        NSLog(@"Accelerometer not available");
    } else { 
        [AppModel sharedAppModel].motionManager.accelerometerUpdateInterval = 0.2;
        NSOperationQueue *motionQueue = [[NSOperationQueue alloc] init]; 
        [[AppModel sharedAppModel].motionManager startAccelerometerUpdatesToQueue: motionQueue withHandler:
         ^(CMAccelerometerData *data, NSError *error) { [self accelerometerData: data errorMessage: error];}
         ];
    }
}

- (void)accelerometerData:(CMAccelerometerData *)data errorMessage:(NSError *)error {
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

- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate{
	NSLog(@"AppDelegate: Playing an audio Alert sound");
	
	//Vibrate
	if (shouldVibrate == YES) [NSThread detachNewThreadSelector:@selector(vibrate) toTarget:self withObject:nil];	
	//Play the sound on a background thread
	[NSThread detachNewThreadSelector:@selector(playAudio:) toTarget:self withObject:wavFileName];
}

//Play a sound
- (void) playAudio:(NSString*)wavFileName {
    if([AppModel sharedAppModel].inGame){
	NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:wavFileName ofType:@"wav"]];
    NSLog(@"Appdelegate: Playing Audio: %@", url);
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];	
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    NSError* err;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL: url error:&err];
    [self.player setDelegate: self];
    if( err ){
        NSLog(@"Appdelegate: Playing Audio: Failed with reason: %@", [err localizedDescription]);
    }
    else{
        [self.player play];
    }
    }
}

- (void) stopAudio{
    if(self.player){
            [self.player stop];
    }
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                        successfully: (BOOL) flag {
    NSLog(@"Appdelegate: Audio is done playing");
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
}

//Vibrate
- (void) vibrate{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  
}

// handle opening ARIS using custom URL of form ARIS://?game=397 
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"ARIS opened from URL");
    if (!url) {  return NO; }
    NSLog(@"URL found");
    
    // parse URL for game id
    /*NSString *gameIDQuery = [[url query] lowercaseString];
    NSLog(@"gameIDQuery = %@",gameIDQuery);
    
    if (!gameIDQuery) {return NO;}
    NSRange equalsSignRange = [gameIDQuery rangeOfString: @"game=" ];
    if (equalsSignRange.length == 0) {return NO;}
    int equalsSignIndex = equalsSignRange.location;
    NSString *gameID = [gameIDQuery substringFromIndex: equalsSignIndex+equalsSignRange.length];
    NSLog(@"gameID=: %@",gameID);*/
    
    // parse URL for game id

    // check that path is ARIS://games/
    NSString *strPath = [[url host] lowercaseString];
    NSLog(@"Path: %@", strPath);
    
    if ([strPath isEqualToString:@"games"] || [strPath isEqualToString:@"game"]) {
        
        // get GameID
        NSString *gameID = [url lastPathComponent];
        NSLog(@"gameID: %@",gameID);
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURLGamesListReady) name:@"NewGameListReady" object:nil];
        [[AppServices sharedAppServices] fetchOneGameGameList:[gameID intValue]];
    }
    return YES;
}

#pragma mark Memory Management
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

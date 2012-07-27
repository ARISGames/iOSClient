//
//  ARISAppDelegate.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import "ARISAppDelegate.h"

@implementation ARISAppDelegate

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
	//Don't sleep
	application.idleTimerDisabled = YES;
    
	//Init keys in UserDefaults in case the user has not visited the ARIS Settings page
	//To set these defaults, edit Settings.bundle->Root.plist 
	[[AppModel sharedAppModel] initUserDefaults];
	
	//Load defaults from UserDefaults
	[[AppModel sharedAppModel] loadUserDefaults];
    
    //Log the current Language
	NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	NSLog(@"Current Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
	NSLog(@"Current language: %@", currentLanguage);

    if([window respondsToSelector:@selector(setRootViewController:)])
        [window setRootViewController:[RootViewController sharedRootViewController]];
    else
        [window addSubview:[RootViewController sharedRootViewController].view];
}


- (void)applicationDidBecomeActive:(UIApplication *)application{
	NSLog(@"AppDelegate: applicationDidBecomeActive");
	[[AppModel sharedAppModel] loadUserDefaults];
    [[AppServices sharedAppServices]setShowPlayerOnMap];
    [self resetCurrentlyFetchingVars];
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"AppDelegate: LOW MEMORY WARNING RECIEVED");
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LowMemoryWarning" object:nil]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"AppDelegate: Begin Application Resign Active");
    
    [[RootViewController sharedRootViewController].tabBarController dismissModalViewControllerAnimated:NO];
    
	[[AppModel sharedAppModel] saveUserDefaults];
}

-(void) applicationWillTerminate:(UIApplication *)application {
	NSLog(@"AppDelegate: Begin Application Termination");
	[[AppModel sharedAppModel] saveUserDefaults];
    [[AppModel sharedAppModel] saveCOREData];
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
- (void) vibrate {
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);  
}

- (void) resetCurrentlyFetchingVars{
    [AppServices sharedAppServices].currentlyFetchingGamesList = NO;
    [AppServices sharedAppServices].currentlyFetchingInventory = NO;
    [AppServices sharedAppServices].currentlyFetchingLocationList = NO;
    [AppServices sharedAppServices].currentlyFetchingQuestList = NO;
    [AppServices sharedAppServices].currentlyFetchingGameNoteList = NO;
    [AppServices sharedAppServices].currentlyFetchingPlayerNoteList = NO;
    [AppServices sharedAppServices].currentlyUpdatingServerWithInventoryViewed = NO;
    [AppServices sharedAppServices].currentlyUpdatingServerWithMapViewed = NO;
    [AppServices sharedAppServices].currentlyUpdatingServerWithPlayerLocation = NO;
    [AppServices sharedAppServices].currentlyUpdatingServerWithQuestsViewed = NO;
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
        NSLog(@"gameID=: %@",gameID);
        
        
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(handleOpenURLGamesListReady) name:@"NewGameListReady" object:nil];
        [[AppServices sharedAppServices] fetchOneGame:[gameID intValue]];
    }
    
    return YES;
}

#pragma mark Memory Management
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


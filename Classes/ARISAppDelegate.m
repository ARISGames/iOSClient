//
//  ARISAppDelegate.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "Node.h"
#import "TutorialPopupView.h"
#import "BogusSelectGameViewController.h"
#import "GamePickerSearchViewController.h"
#import "GamePickerRecentViewController.h"
#import "GamePickerPopularViewController.h"
#import "GameDetails.h"
#import "webpageViewController.h"
#import "NoteDetailsViewController.h"
#import "LoadingViewController.h"

NSString *errorMessage, *errorDetail;

BOOL isShowingNotification;

@implementation ARISAppDelegate

@synthesize window;
@synthesize tabBarController, gameSelectionTabBarController;
@synthesize defaultViewControllerForMainTabBar;
@synthesize loginViewController;
@synthesize loginViewNavigationController;
@synthesize nearbyObjectsNavigationController;
@synthesize nearbyObjectNavigationController;
@synthesize waitingIndicator,waitingIndicatorView;
@synthesize networkAlert,serverAlert;
@synthesize tutorialViewController;
@synthesize modalPresent,notificationCount;
@synthesize titleLabel,descLabel,notifArray,notificationBarHeight;
@synthesize pubClient;
@synthesize privClient,loadingVC;
@synthesize player;
//@synthesize ARISMoviePlayer;


//@synthesize toolbarViewController;

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
    self.notificationCount = 0;
    notifArray = [[NSMutableArray alloc]initWithCapacity:5];
	//Init keys in UserDefaults in case the user has not visited the ARIS Settings page
	//To set these defaults, edit Settings.bundle->Root.plist 
	[[AppModel sharedAppModel] initUserDefaults];
	
	//Load defaults from UserDefaults
	[[AppModel sharedAppModel] loadUserDefaults];
   
    notificationBarHeight = 20;
    
    //Log the current Language
	NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	NSLog(@"Current Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
	NSLog(@"Current language: %@", currentLanguage);
    
	//register for notifications from views
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(finishLoginAttempt:) name:@"NewLoginResponseReady" object:nil];
	[dispatcher addObserver:self selector:@selector(selectGame:) name:@"SelectGame" object:nil];
	[dispatcher addObserver:self selector:@selector(performLogout:) name:@"LogoutRequested" object:nil];
	[dispatcher addObserver:self selector:@selector(displayNearbyObjects:) name:@"NearbyButtonTouched" object:nil];
	[dispatcher addObserver:self selector:@selector(checkForDisplayCompleteNode) name:@"NewQuestListReady" object:nil];
    [dispatcher addObserver:self selector:@selector(receivedMediaList) name:@"ReceivedMediaList" object:nil];

    UILabel *titleLabelAlloc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    self.titleLabel = titleLabelAlloc;
    UILabel *descLabelAlloc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 15)];
    self.descLabel = descLabelAlloc;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor blackColor];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.font = [UIFont systemFontOfSize:12];
    descLabel.textAlignment = UITextAlignmentCenter;
    descLabel.backgroundColor = [UIColor blackColor];
    [self.window addSubview:titleLabel];
    [self.window addSubview:descLabel];
	//Setup NearbyObjects View
	NearbyObjectsViewController *nearbyObjectsViewController = [[NearbyObjectsViewController alloc]initWithNibName:@"NearbyObjectsViewController" bundle:nil];
    UINavigationController *nearbyObjectsNavigationControllerAlloc = [[UINavigationController alloc] initWithRootViewController: nearbyObjectsViewController];
	self.nearbyObjectsNavigationController = nearbyObjectsNavigationControllerAlloc;
	self.nearbyObjectsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Setup ARView
	//ARViewViewControler *arViewController = [[[ARViewViewControler alloc] initWithNibName:@"ARView" bundle:nil] autorelease];
	//UINavigationController *arNavigationController = [[UINavigationController alloc] initWithRootViewController: arViewController];
	//arNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Setup Quests View
	QuestsViewController *questsViewController = [[QuestsViewController alloc] initWithNibName:@"Quests" bundle:nil];
	UINavigationController *questsNavigationController = [[UINavigationController alloc] initWithRootViewController: questsViewController];
	questsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Setup GPS View
	GPSViewController *gpsViewController = [[GPSViewController alloc] initWithNibName:@"GPS" bundle:nil];
	UINavigationController *gpsNavigationController = [[UINavigationController alloc] initWithRootViewController: gpsViewController];
	gpsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

	//Setup Inventory View
	InventoryListViewController *inventoryListViewController = [[InventoryListViewController alloc] initWithNibName:@"InventoryList" bundle:nil];
	UINavigationController *inventoryNavigationController = [[UINavigationController alloc] initWithRootViewController: inventoryListViewController];
	inventoryNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
	//Setup Attributes View
    AttributesViewController *attributesViewController = [[AttributesViewController alloc] initWithNibName:@"AttributesViewController" bundle:nil];
	UINavigationController *attributesNavigationController = [[UINavigationController alloc] initWithRootViewController: attributesViewController];
	attributesNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Setup Notes View
    NotebookViewController *notesViewController = [[NotebookViewController alloc] initWithNibName:@"NotebookViewController" bundle:nil];
	UINavigationController *notesNavigationController = [[UINavigationController alloc] initWithRootViewController: notesViewController];
	notesNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
	//Setup Camera View
	/*CameraViewController *cameraViewController = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
	UINavigationController *cameraNavigationController = [[UINavigationController alloc] initWithRootViewController: cameraViewController];
	cameraNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;*/

	//Setup Audio Recorder View
	AudioRecorderViewController *audioRecorderViewController = [[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil];
	UINavigationController *audioRecorderNavigationController = [[UINavigationController alloc] initWithRootViewController: audioRecorderViewController];
	audioRecorderNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;	
	
	//QR Scanner Developer View
	QRScannerViewController *qrScannerViewController = [[QRScannerViewController alloc] initWithNibName:@"QRScanner" bundle:nil];
	UINavigationController *qrScannerNavigationController = [[UINavigationController alloc] initWithRootViewController: qrScannerViewController];
	qrScannerNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Logout View
	LogoutViewController *logoutViewController = [[LogoutViewController alloc] initWithNibName:@"Logout" bundle:nil];
	UINavigationController *logoutNavigationController = [[UINavigationController alloc] initWithRootViewController: logoutViewController];
	logoutNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Developer View
	DeveloperViewController *developerViewController = [[DeveloperViewController alloc] initWithNibName:@"Developer" bundle:nil];
	UINavigationController *developerNavigationController = [[UINavigationController alloc] initWithRootViewController: developerViewController];
	developerNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		
	//Bogus Game Picker View
    BogusSelectGameViewController *bogusSelectGameViewController = [[BogusSelectGameViewController alloc] init];

	//Login View
	loginViewController = [[LoginViewController alloc] initWithNibName:@"Login" bundle:nil];
	loginViewNavigationController = [[UINavigationController alloc] initWithRootViewController: loginViewController];
	loginViewNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[loginViewNavigationController.view setFrame:UIScreen.mainScreen.applicationFrame];
    [window addSubview:loginViewNavigationController.view];

    
    
	//Setup the Main Tab Bar
    UITabBarController *tabBarControllerAlloc = [[UITabBarController alloc] init];
	self.tabBarController = tabBarControllerAlloc;
	self.tabBarController.delegate = self;
	UINavigationController *moreNavController = self.tabBarController.moreNavigationController;
	moreNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	moreNavController.delegate = self;
	self.tabBarController.viewControllers = [NSMutableArray arrayWithObjects: 
										questsNavigationController, 
										gpsNavigationController,
										inventoryNavigationController,
										qrScannerNavigationController,
										//arNavigationController,
                                        attributesNavigationController,
                                        notesNavigationController,
										bogusSelectGameViewController,
										logoutNavigationController,
										//developerNavigationController,
										nil];
    self.defaultViewControllerForMainTabBar = questsNavigationController;
    self.tabBarController.view.hidden = YES;
    [window addSubview:self.tabBarController.view];
    [AppModel sharedAppModel].defaultGameTabList = self.tabBarController.customizableViewControllers;
    
    //Setup the Game Selection Tab Bar
    
    UITabBarController *gameSelectionTabBarControllerAlloc = [[UITabBarController alloc] init];
    self.gameSelectionTabBarController = gameSelectionTabBarControllerAlloc;
    self.gameSelectionTabBarController.delegate = self;
    
    GamePickerNearbyViewController *gamePickerNearbyViewController = [[GamePickerNearbyViewController alloc] initWithNibName:@"GamePickerNearbyViewController" bundle:nil];
	UINavigationController *gamePickerNearbyNC = [[UINavigationController alloc] initWithRootViewController: gamePickerNearbyViewController];
	gamePickerNearbyNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    GamePickerSearchViewController *gamePickerSearchVC = [[GamePickerSearchViewController alloc]initWithNibName:@"GamePickerSearchViewController" bundle:nil];
    UINavigationController *gamePickerSearchNC = [[UINavigationController alloc] initWithRootViewController:gamePickerSearchVC];
    gamePickerSearchNC.navigationBar.barStyle = UIBarStyleBlackOpaque;

    GamePickerRecentViewController *gamePickerRecentVC = [[GamePickerRecentViewController alloc]initWithNibName:@"GamePickerRecentViewController" bundle:nil];
    UINavigationController *gamePickerRecentNC = [[UINavigationController alloc] initWithRootViewController:gamePickerRecentVC];
    gamePickerRecentNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    GamePickerPopularViewController *gamePickerPopularVC = [[GamePickerPopularViewController alloc]initWithNibName:@"GamePickerPopularViewController" bundle:nil];
    UINavigationController *gamePickerPopularNC = [[UINavigationController alloc] initWithRootViewController:gamePickerPopularVC];
    gamePickerPopularNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    
	//Logout View
	LogoutViewController *alogoutViewController = [[LogoutViewController alloc] initWithNibName:@"Logout" bundle:nil];
	UINavigationController *alogoutNavigationController = [[UINavigationController alloc] initWithRootViewController: alogoutViewController];
	alogoutNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    
    self.gameSelectionTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                          gamePickerNearbyNC,
                                                          //gamePickerMapNC,
                                                          gamePickerSearchNC,
                                                          gamePickerPopularNC,
                                                          gamePickerRecentNC,
                                                          alogoutNavigationController,
                                                          nil];
    //[self.gameSelectionTabBarController.view setFrame:UIScreen.mainScreen.applicationFrame];
    [window addSubview:self.gameSelectionTabBarController.view];

    
    
    //Setup The Tutorial View Controller
    TutorialViewController *tutorialViewControllerAlloc = [[TutorialViewController alloc]init];
	self.tutorialViewController = tutorialViewControllerAlloc ;
	self.tutorialViewController.view.frame = self.tabBarController.view.frame;
	self.tutorialViewController.view.hidden = YES;
	self.tutorialViewController.view.userInteractionEnabled = NO;
	[self.tabBarController.view addSubview:self.tutorialViewController.view];
	
                                              
    
	//Setup Location Manager
	[NSTimer scheduledTimerWithTimeInterval:3.0 
									 target:[[MyCLController sharedMyCLController]locationManager] 
								   selector:@selector(startUpdatingLocation) 
								   userInfo:nil 
									repeats:NO];
    [[AppModel sharedAppModel] loadUserDefaults];
    if ([AppModel sharedAppModel].playerId == 0) {
        self.loginViewNavigationController.view.hidden = NO;
        self.tabBarController.view.hidden = YES;
        self.gameSelectionTabBarController.view.hidden = YES;
    }
    else {
        [[AppServices sharedAppServices]setShowPlayerOnMap];
        [AppModel sharedAppModel].loggedIn = YES;
        self.loginViewNavigationController.view.hidden = YES;
        self.tabBarController.view.hidden = YES;
        self.gameSelectionTabBarController.view.hidden = NO;
    }
	//self.waitingIndicatorView = [[WaitingIndicatorView alloc] init];
    
    
    /*//PUSHER STUFF
    //Setup Pusher Client
    self.pubClient = [PTPusher pusherWithKey:@"7fe26fe9f55d4b78ea02" delegate:self];
    self.privClient = [PTPusher pusherWithKey:@"7fe26fe9f55d4b78ea02" delegate:self];
    self.privClient.authorizationURL = [NSURL URLWithString:@"http://www.arisgames.org/devserver/pusher/private_auth.php"];
        
    PTPusherChannel *pubChannel = [pubClient subscribeToChannelNamed:@"public-pusher_room_channel"];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveChannelEventNotification:)
     name:PTPusherEventReceivedNotification
     object:pubChannel];
    
    PTPusherPrivateChannel *privChannel = [privClient subscribeToPrivateChannelNamed:@"pusher_room_channel"];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveChannelEventNotification:)
     name:PTPusherEventReceivedNotification
     object:privChannel];
     */
}
/*
//PUSHER STUFF
- (void)didReceiveChannelEventNotification:(NSNotification *)note
{
    PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
    // do something with event
    
    NSLog(@"Received an event from Pusher!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.channel
                                                    message:event.name
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];	
    [alert release];
}*/

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
    
    [self.tabBarController dismissModalViewControllerAnimated:NO];
    
	[[AppModel sharedAppModel] saveUserDefaults];
}

-(void) applicationWillTerminate:(UIApplication *)application {
	NSLog(@"AppDelegate: Begin Application Termination");
	[[AppModel sharedAppModel] saveUserDefaults];
    [[AppModel sharedAppModel] saveCOREData];
}




 

#pragma mark -
#pragma mark Notifications, Warnings and Other Views

-(void)showNotifications{
    NSNotification *showNotificationsNotification = [NSNotification notificationWithName:@"showNotifications" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:showNotificationsNotification];
    NSLog(@"AppDelegate: showNotifications");
    
    if([self.notifArray count]>0){
        NSLog(@"AppDelegate: showNotifications: We have something to display");
        if(!isShowingNotification){//lower frame into position if its not already there
            isShowingNotification = YES;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.5];
            NSLog(@"AppDelegate: showNotifications: Begin Resizing");
            NSLog(@"TabBC frame BEFORE origin: %f notificationBarHeight %d",self.tabBarController.view.frame.origin.y,self.notificationBarHeight);
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            if(self.tabBarController.modalViewController){
                self.tabBarController.modalViewController.view.frame = CGRectMake(self.tabBarController.modalViewController.view.frame.origin.x,40+[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y-20, self.tabBarController.modalViewController.view.frame.size.width, 440-[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+20); 
            }
           
        self.tabBarController.view.frame = CGRectMake(self.tabBarController.view.frame.origin.x,40+[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y-self.notificationBarHeight, self.tabBarController.view.frame.size.width, 440-[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+self.notificationBarHeight); 
            [self.titleLabel setFrame:CGRectMake(0,[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y, 320, 20)];
            [self.descLabel setFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y +20, 320, 15)];
        [UIView commitAnimations];
        }
        NSLog(@"TabBC frame AFTER origin: %f notificationBarHeight %d",self.tabBarController.view.frame.origin.y,notificationBarHeight);
        NSLog(@"AppDelegate: showNotifications: Set Text and Init alpha");

        titleLabel.alpha = 0.0;
        descLabel.alpha = 0.0;
        titleLabel.text = [[notifArray objectAtIndex:0] objectForKey:@"title"];
        descLabel.text = [[notifArray objectAtIndex:0] objectForKey:@"prompt"];
        
        [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            NSLog(@"AppDelegate: showNotifications: Begin Fade in");
            titleLabel.alpha = 1.0;
            descLabel.alpha = 1.0;
        }completion:^(BOOL finished){
            if(finished){
                NSLog(@"AppDelegate: showNotifications: Fade in Complete, Begin Fade Out");
            [UIView animateWithDuration:1.5 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
                titleLabel.alpha = 0.0;
                descLabel.alpha = 0.0;
            }completion:^(BOOL finished){
                if(finished){
                    NSLog(@"AppDelegate: showNotifications: Fade Out Complete, Pop and Start over");
                    if([notifArray count] > 0) [self.notifArray removeObjectAtIndex:0];
                    [self showNotifications];
                }
            }];
            }
        }];
            }
    else{
        [self hideNotifications];
    }
}

-(void)hideNotifications{
    NSNotification *hideNotificationsNotification = [NSNotification notificationWithName:@"hideNotifications" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:hideNotificationsNotification];
    
    if(!tabBarController.view.hidden){
    [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
        if(isShowingNotification){
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            
            if(self.tabBarController.modalViewController){
                self.tabBarController.modalViewController.view.frame = CGRectMake(self.tabBarController.modalViewController.view.frame.origin.x, [UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y-20, self.tabBarController.modalViewController.view.frame.size.width, 480-[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+20);             }
            
            self.tabBarController.view.frame = CGRectMake(self.tabBarController.view.frame.origin.x, [UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y-notificationBarHeight, self.tabBarController.view.frame.size.width, 480-[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+notificationBarHeight); 
            
            [self.titleLabel setFrame:CGRectMake(0, -20, 320, 20)];
            [self.descLabel setFrame:CGRectMake(0, -20, 320, 15)];
        }
    }completion:^(BOOL finished){
        isShowingNotification = NO;
    }];
    }
    
    
}


- (void) showGameSelectionTabBarAndHideOthers {
    
    //Put it onscreen
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
    self.tabBarController.selectedIndex = 0;
    [self hideNotifications];
    self.tabBarController.view.hidden = YES;
    self.gameSelectionTabBarController.view.hidden = NO;
    self.loginViewNavigationController.view.hidden = YES;
    [UIView commitAnimations];

}



- (void) showServerAlertWithEmail:(NSString *)title message:(NSString *)message details:(NSString*)detail{
	errorMessage = message;
    errorDetail = detail;
    
	if (!self.serverAlert){
        UIAlertView *serverAlertAlloc = [[UIAlertView alloc] initWithTitle:title
                                                                   message:NSLocalizedString(@"ARISAppDelegateWIFIErrorMessageKey", @"")
                                                                  delegate:self cancelButtonTitle:NSLocalizedString(@"IgnoreKey", @"") otherButtonTitles:NSLocalizedString(@"ReportKey", @""),nil];
		self.serverAlert = serverAlertAlloc;
		[self.serverAlert show];	
 	}
	else {
		NSLog(@"AppDelegate: showServerAlertWithEmail was called, but a server alert was already present");
	}
    
}

- (void) showNetworkAlert{
	NSLog (@"AppDelegate: Showing Network Alert");
	if (self.loadingVC) {
        [self.loadingVC dismissModalViewControllerAnimated:NO];
        [self tabBarController].selectedIndex = 0;
        [self showGameSelectionTabBarAndHideOthers];
    }
	if (!self.networkAlert) {
		networkAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"PoorConnectionTitleKey", @"") 
                                                  message: NSLocalizedString(@"PoorConnectionMessageKey", @"")
												 delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
	}
	if (self.networkAlert.visible == NO) [networkAlert show];
    
}

- (void) removeNetworkAlert {
	NSLog (@"AppDelegate: Removing Network Alert");
	
	if (self.networkAlert != nil) {
		[self.networkAlert dismissWithClickedButtonIndex:0 animated:YES];
	}
}



- (void) showNewWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar {
	NSLog (@"AppDelegate: Showing Waiting Indicator With Message:%@",message);
	//if (self.waitingIndicatorView) [self.waitingIndicatorView dismiss];
	if(!self.loadingVC){
        if (self.waitingIndicatorView){ 
            [self removeNewWaitingIndicator];
        }
        WaitingIndicatorView *waitingIndicatorViewAlloc = [[WaitingIndicatorView alloc] initWithWaitingMessage:message showProgressBar:displayProgressBar];
        self.waitingIndicatorView = waitingIndicatorViewAlloc;
        [self.waitingIndicatorView show];
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the activity indicator show before returning	
    }
}

- (void) removeNewWaitingIndicator {
	NSLog (@"AppDelegate: Removing Waiting Indicator");
	if (self.waitingIndicatorView != nil) [self.waitingIndicatorView dismiss];
    self.waitingIndicatorView = nil;
}


- (void) showWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar {
	NSLog (@"AppDelegate: Showing Waiting Indicator");
	if (!self.waitingIndicator) {
        WaitingIndicatorViewController *waitingIndicatorAlloc = [[WaitingIndicatorViewController alloc] initWithNibName:@"WaitingIndicator" bundle:nil];
		self.waitingIndicator = waitingIndicatorAlloc;
	}
	self.waitingIndicator.message = message;
	self.waitingIndicator.progressView.hidden = !displayProgressBar;
	
	//by adding a subview to window, we make sure it is put on top
	if ([AppModel sharedAppModel].loggedIn == YES) [window addSubview:self.waitingIndicator.view]; 
    
}

- (void) removeWaitingIndicator {
	NSLog (@"AppDelegate: Removing Waiting Indicator");
	if (self.waitingIndicator != nil) [self.waitingIndicator.view removeFromSuperview ];
}


- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController {
	UINavigationController *nearbyObjectNavigationControllerAlloc = [[UINavigationController alloc] initWithRootViewController:nearbyObjectViewController];
	self.nearbyObjectNavigationController = nearbyObjectNavigationControllerAlloc;
	self.nearbyObjectNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
	//Display
    
    [self.tabBarController presentModalViewController:self.nearbyObjectNavigationController animated:NO];
}

- (void)dismissNearbyObjectView:(UIViewController *)nearbyObjectViewController{
    
    [nearbyObjectViewController dismissModalViewControllerAnimated:NO];
    if(isShowingNotification){
        notificationBarHeight = 0;
        
        self.tabBarController.view.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+40, 320, 420);
    }
    
}

- (void) returnToHomeView{
	NSLog(@"AppDelegate: Returning to Home View and Popping More Nav Controller");
    [self.tabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
	//[self.tabBarController setSelectedViewController:self.defaultViewControllerForMainTabBar];	
}

- (void) checkForDisplayCompleteNode{
    int nodeID = [AppModel sharedAppModel].currentGame.completeNodeId;
    if ([AppModel sharedAppModel].currentGame.completedQuests == [AppModel sharedAppModel].currentGame.totalQuests &&
        [AppModel sharedAppModel].currentGame.completedQuests > 0  && nodeID != 0) {
        NSLog(@"AppDelegate: checkForIntroOrCompleteNodeDisplay: Displaying Complete Node");
		Node *completeNode = [[AppModel sharedAppModel] nodeForNodeId:[AppModel sharedAppModel].currentGame.completeNodeId];
		[completeNode display];
	}
}

- (void) displayIntroNode{
    int nodeId = [AppModel sharedAppModel].currentGame.launchNodeId;
    if (nodeId && nodeId != 0) {
        NSLog(@"AppDelegate: displayIntroNode");
        Node *launchNode = [[AppModel sharedAppModel] nodeForNodeId:[AppModel sharedAppModel].currentGame.launchNodeId];
        [launchNode display];
    }
    else NSLog(@"AppDelegate: displayIntroNode: Game did not specify an intro node, skipping");
}

- (void) showNearbyTab:(BOOL)yesOrNo {
    if([AppModel sharedAppModel].tabsReady){
        //[AppModel sharedAppModel].tabsReady = NO;
        NSMutableArray *tabs = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
        
        if (yesOrNo) {
            NSLog(@"AppDelegate: showNearbyTab: YES");
            if (![tabs containsObject:self.nearbyObjectsNavigationController]) {
                [tabs insertObject:self.nearbyObjectsNavigationController atIndex:0];
            }
        }
        else {
            NSLog(@"AppDelegate: showNearbyTab: NO");
            
            if ([tabs containsObject:self.nearbyObjectsNavigationController]) {
                [tabs removeObject:self.nearbyObjectsNavigationController];
                //Hide any popups
                UIViewController *vc = [self.nearbyObjectsNavigationController performSelector:@selector(visibleViewController)];
                if ([vc respondsToSelector:@selector(dismissTutorial)]) {
                    [vc performSelector:@selector(dismissTutorial)];
                }
                
            }
            
        }
        
        [self.tabBarController setViewControllers:tabs animated:NO];
        
        NSNotification *n = [NSNotification notificationWithName:@"TabBarItemsChanged" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
}


#pragma mark -

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

 

#pragma mark -
#pragma mark Login and Game Selection



- (void)attemptLoginWithUserName:(NSString *)userName andPassword:(NSString *)password {	
	NSLog(@"AppDelegate: Attempt Login for: %@ Password: %@", userName, password);
	[AppModel sharedAppModel].userName = userName;
	[AppModel sharedAppModel].password = password;
    
	[self showNewWaitingIndicator:@"Logging In..." displayProgressBar:NO];
	[[AppServices sharedAppServices] login];
}


- (void)finishLoginAttempt:(NSNotification *)notification {
	NSLog(@"AppDelegate: Finishing Login Attempt");
    
	//handle login response
	if([AppModel sharedAppModel].loggedIn) {
		NSLog(@"AppDelegate: Login Success");
        
        self.tabBarController.view.hidden = YES;
        self.gameSelectionTabBarController.view.hidden = NO;
        self.loginViewNavigationController.view.hidden = YES;
        
        self.gameSelectionTabBarController.selectedIndex = 0;
        
        
	} else {
		NSLog(@"AppDelegate: Login Failed, check for a network issue");
		if (self.networkAlert) NSLog(@"AppDelegate: Network is down, skip login alert");
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginErrorTitleKey",@"")
															message:NSLocalizedString(@"LoginErrorMessageKey",@"")
														   delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"")otherButtonTitles: nil];
			[alert show];	
		}
	}
	
}


- (void)selectGame:(NSNotification *)notification {
    //NSDictionary *loginObject = [notification object];
	NSDictionary *userInfo = notification.userInfo;
	Game *selectedGame = [userInfo objectForKey:@"game"];
    
	NSLog(@"AppDelegate: Game Selected. '%@' game was selected", selectedGame.name);
	

    //Put it onscreen
    //CGContextRef context = UIGraphicsGetCurrentContext();
  //  [UIView beginAnimations:nil context:context];
   // [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
    self.tabBarController.view.hidden = NO;
    self.gameSelectionTabBarController.view.hidden = YES;
    self.loginViewNavigationController.view.hidden = YES;
    

    
    
   // [UIView commitAnimations];
    
    
    
    [self returnToHomeView];
	
	//Set the model to this game
	[AppModel sharedAppModel].currentGame = selectedGame;
	[[AppModel sharedAppModel] saveUserDefaults];
	
	//Clear out the old game data
    [[AppServices sharedAppServices] fetchTabBarItemsForGame: selectedGame.gameId];
	[[AppServices sharedAppServices] resetAllPlayerLists];
    [[AppServices sharedAppServices] resetAllGameLists];
	[tutorialViewController dismissAllTutorials];
	
	//Notify the Server
	NSLog(@"AppDelegate: Game Selected. Notifying Server");
	[[AppServices sharedAppServices] updateServerGameSelected];
	
	
	UINavigationController *navigationController
    ;
	
	//Get the naviation controller and visible view controller
	if ([self.tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
		navigationController = (UINavigationController*)self.tabBarController.selectedViewController;
	}
	else {
		navigationController = nil;
	}
	
    //Start loading all the data
    [[AppServices sharedAppServices] fetchAllGameLists];
	[[AppServices sharedAppServices] fetchAllPlayerLists];
    [AppModel sharedAppModel].hasReceivedMediaList = NO;

    
   loadingVC = [[LoadingViewController alloc]initWithNibName:@"LoadingViewController" bundle:nil];
    loadingVC.progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
    [self.tabBarController presentModalViewController:self.loadingVC animated:NO];
    	
}

-(void)changeTabBar{
    UINavigationController *tempNav = [[UINavigationController alloc] init];
    NSArray *newCustomVC = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *newTabList = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *tmpTabList = [[NSMutableArray alloc] initWithCapacity:11];

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tabIndex"
                                                  ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    tmpTabList = [[AppModel sharedAppModel].gameTabList sortedArrayUsingDescriptors:sortDescriptors];
    Tab *tmpTab = [[Tab alloc] init];
    for(int y = 0; y < [tmpTabList count];y++){
        tmpTab = [tmpTabList objectAtIndex:y];
                if ([tmpTab.tabName isEqualToString:@"QUESTS"]) tmpTab.tabName = NSLocalizedString(@"QuestViewTitleKey",@"");
                else if([tmpTab.tabName isEqualToString:@"GPS"]) tmpTab.tabName = NSLocalizedString(@"MapViewTitleKey",@"");
                else if([tmpTab.tabName isEqualToString:@"INVENTORY"]) tmpTab.tabName = NSLocalizedString(@"InventoryViewTitleKey",@"");
                else if([tmpTab.tabName isEqualToString:@"QR"]) tmpTab.tabName = NSLocalizedString(@"QRScannerTitleKey",@"");
                else if([tmpTab.tabName isEqualToString:@"PLAYER"]) tmpTab.tabName = NSLocalizedString(@"PlayerTitleKey",@"");
                else if([tmpTab.tabName isEqualToString:@"NOTE"]) tmpTab.tabName = NSLocalizedString(@"NotebookTitleKey",@"");
                else if([tmpTab.tabName isEqualToString:@"PICKGAME"]) tmpTab.tabName = NSLocalizedString(@"GamePickerTitleKey",@"");
                else{
                    tmpTab.tabIndex = 0;
                }
        if(tmpTab.tabIndex != 0) {
            
        newTabList = [newTabList arrayByAddingObject:tmpTab];
        }
    }
    for(int y = 0; y < [newTabList count];y++){
        tmpTab = [newTabList objectAtIndex:y];
    for(int x = 0; x < [[AppModel sharedAppModel].defaultGameTabList count];x++){
        
        tempNav = (UINavigationController *)[[AppModel sharedAppModel].defaultGameTabList objectAtIndex:x];
        if([tempNav.navigationItem.title isEqualToString:tmpTab.tabName])newCustomVC = [newCustomVC arrayByAddingObject:tempNav];
            }
    }

    self.tabBarController.viewControllers = [NSArray arrayWithArray: newCustomVC];
    [AppModel sharedAppModel].tabsReady = YES;
}

- (void)performLogout:(NSNotification *)notification {
    NSLog(@"Performing Logout: Clearing NSUserDefaults and Displaying Login Screen");
	
	//Clear any user realated info in AppModel (except server)
	[[AppModel sharedAppModel] clearUserDefaults];
	
	
	//clear the tutorial popups
	[tutorialViewController dismissAllTutorials];
	
	//(re)load the login view
	self.tabBarController.view.hidden = YES;
    self.loginViewNavigationController.view.hidden = NO;
    self.gameSelectionTabBarController.view.hidden = YES;
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

-(void)receivedMediaList{
    //Display the intro node
 
    [AppModel sharedAppModel].hasReceivedMediaList = YES;
    
}


- (void)newError: (NSString *)text {
	NSLog(@"%@", text);
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

- (void) handleOpenURLGamesListReady {
    NSLog(@"game opened");
    
    //unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    Game *selectedGame = [[[AppModel sharedAppModel] gameList] objectAtIndex:0];	
    GameDetails *gameDetailsVC = [[GameDetails alloc]initWithNibName:@"GameDetails" bundle:nil];
    gameDetailsVC.game = selectedGame;
    
    // show gameSelectionTabBarController
    self.tabBarController.view.hidden = YES;
    self.loginViewController.view.hidden = YES;
    self.gameSelectionTabBarController.view.hidden = NO;
    
    NSLog(@"gameID= %i",selectedGame.gameId);
    NSLog(@"game= %@",selectedGame.name);
    NSLog(@"gameDetailsVC nib name = %@",gameDetailsVC.nibName); 
    
    // Push Game Detail View Controller
    [(UINavigationController*)self.gameSelectionTabBarController.selectedViewController pushViewController:gameDetailsVC animated:YES];  
    
}

#pragma mark AlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	//Since only the server error alert with email ever uses this, we know who we are dealing with
	NSLog(@"AppDelegate: AlertView clickedButtonAtIndex: %d",buttonIndex);
	
	if (buttonIndex == 1) {
		NSLog(@"AppDelegate: AlertView button wants to send an email" );
		//Send an Email
		//NSString *body = [NSString stringWithFormat:@"%@",alertView.message];
        NSString * body = [NSString stringWithFormat:@"%@\n\nDetails:\n%@", errorMessage, errorDetail];
		MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		[controller setToRecipients: [NSMutableArray arrayWithObjects: @"arisgames-dev@googlegroups.com",nil]];
		[controller setSubject:@"ARIS Error Report"];
		[controller setMessageBody:body isHTML:NO]; 
		if (controller) [self.tabBarController presentModalViewController:controller animated:YES];
	}
	
	self.serverAlert = nil;
    
}

#pragma mark MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
	if (result == MFMailComposeResultSent) {
		NSLog(@"AppDelegate: mailComposeController result == MFMailComposeResultSent");
	}
	[tabBarController dismissModalViewControllerAnimated:YES];
}

#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController{
    NSLog(@"AppDelegate: tabBarController didSelectViewController");	
    

        [tabBar.moreNavigationController popToRootViewControllerAnimated:NO];
    
	//Hide any popups
	if ([viewController respondsToSelector:@selector(visibleViewController)]) {
		UIViewController *vc = [viewController performSelector:@selector(visibleViewController)];
		if ([vc respondsToSelector:@selector(dismissTutorial)]) {
			[vc performSelector:@selector(dismissTutorial)];
		}
	}

    if(isShowingNotification){
        notificationBarHeight = 0;

        self.tabBarController.view.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+40, 320, 420);
    }
}


#pragma mark Memory Management
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


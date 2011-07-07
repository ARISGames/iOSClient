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
#import "GamePickerMapViewController.h"
#import "GamePickerSearchViewController.h"
#import "GamePickerRecentViewController.h"


@implementation ARISAppDelegate

@synthesize window;
@synthesize tabBarController, gameSelectionTabBarController;
@synthesize defaultViewControllerForMainTabBar;
@synthesize loginViewController;
@synthesize loginViewNavigationController;
@synthesize nearbyObjectsNavigationController;
@synthesize nearbyObjectNavigationController;
@synthesize myCLController;
@synthesize waitingIndicator,waitingIndicatorView;
@synthesize networkAlert,serverAlert;
@synthesize tutorialViewController;
@synthesize modalPresent,notificationCount;


//@synthesize toolbarViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
		
	//Don't sleep
	application.idleTimerDisabled = YES;
		
    self.notificationCount = 0;
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
	[languages release];
	[currentLanguage release];
    
	//register for notifications from views
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(finishLoginAttempt:) name:@"NewLoginResponseReady" object:nil];
	[dispatcher addObserver:self selector:@selector(selectGame:) name:@"SelectGame" object:nil];
	[dispatcher addObserver:self selector:@selector(performLogout:) name:@"LogoutRequested" object:nil];
	[dispatcher addObserver:self selector:@selector(displayNearbyObjects:) name:@"NearbyButtonTouched" object:nil];
	[dispatcher addObserver:self selector:@selector(checkForDisplayCompleteNode) name:@"NewQuestListReady" object:nil];
    
	//Setup NearbyObjects View
	NearbyObjectsViewController *nearbyObjectsViewController = [[NearbyObjectsViewController alloc]initWithNibName:@"NearbyObjectsViewController" bundle:nil];
	self.nearbyObjectsNavigationController = [[UINavigationController alloc] initWithRootViewController: nearbyObjectsViewController];
	[nearbyObjectsViewController release];
	self.nearbyObjectsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Setup ARView
	//ARViewViewControler *arViewController = [[[ARViewViewControler alloc] initWithNibName:@"ARView" bundle:nil] autorelease];
	//UINavigationController *arNavigationController = [[UINavigationController alloc] initWithRootViewController: arViewController];
	//arNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Setup Quests View
	QuestsViewController *questsViewController = [[[QuestsViewController alloc] initWithNibName:@"Quests" bundle:nil] autorelease];
	UINavigationController *questsNavigationController = [[UINavigationController alloc] initWithRootViewController: questsViewController];
	questsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Setup GPS View
	GPSViewController *gpsViewController = [[[GPSViewController alloc] initWithNibName:@"GPS" bundle:nil] autorelease];
	UINavigationController *gpsNavigationController = [[UINavigationController alloc] initWithRootViewController: gpsViewController];
	gpsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

	//Setup Inventory View
	InventoryListViewController *inventoryListViewController = [[[InventoryListViewController alloc] initWithNibName:@"InventoryList" bundle:nil] autorelease];
	UINavigationController *inventoryNavigationController = [[UINavigationController alloc] initWithRootViewController: inventoryListViewController];
	inventoryNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
	//Setup Attributes View
    AttributesViewController *attributesViewController = [[[AttributesViewController alloc] initWithNibName:@"AttributesViewController" bundle:nil] autorelease];
	UINavigationController *attributesNavigationController = [[UINavigationController alloc] initWithRootViewController: attributesViewController];
	attributesNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
	//Setup Camera View
	CameraViewController *cameraViewController = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
	UINavigationController *cameraNavigationController = [[UINavigationController alloc] initWithRootViewController: cameraViewController];
	cameraNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

	//Setup Audio Recorder View
	AudioRecorderViewController *audioRecorderViewController = [[[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil] autorelease];
	UINavigationController *audioRecorderNavigationController = [[UINavigationController alloc] initWithRootViewController: audioRecorderViewController];
	audioRecorderNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;	
	
	//QR Scanner Developer View
	QRScannerViewController *qrScannerViewController = [[[QRScannerViewController alloc] initWithNibName:@"QRScanner" bundle:nil] autorelease];
	UINavigationController *qrScannerNavigationController = [[UINavigationController alloc] initWithRootViewController: qrScannerViewController];
	qrScannerNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Logout View
	LogoutViewController *logoutViewController = [[[LogoutViewController alloc] initWithNibName:@"Logout" bundle:nil] autorelease];
	UINavigationController *logoutNavigationController = [[UINavigationController alloc] initWithRootViewController: logoutViewController];
	logoutNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

	//Start Over View
	StartOverViewController *startOverViewController = [[[StartOverViewController alloc] initWithNibName:@"StartOverViewController" bundle:nil] autorelease];
	UINavigationController *startOverNavigationController = [[UINavigationController alloc] initWithRootViewController: startOverViewController];
	startOverNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;	
	
	//Developer View
	DeveloperViewController *developerViewController = [[[DeveloperViewController alloc] initWithNibName:@"Developer" bundle:nil] autorelease];
	UINavigationController *developerNavigationController = [[UINavigationController alloc] initWithRootViewController: developerViewController];
	developerNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	
	//Bogus Game Picker View
    BogusSelectGameViewController *bogusSelectGameViewController = [[BogusSelectGameViewController alloc] init];


	//Login View
	loginViewController = [[[LoginViewController alloc] initWithNibName:@"Login" bundle:nil] autorelease];
	loginViewNavigationController = [[UINavigationController alloc] initWithRootViewController: loginViewController];
	loginViewNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[loginViewNavigationController.view setFrame:UIScreen.mainScreen.applicationFrame];
    [window addSubview:loginViewNavigationController.view];

    
    
	//Setup the Main Tab Bar
	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.delegate = self;
	UINavigationController *moreNavController = tabBarController.moreNavigationController;
	moreNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	moreNavController.delegate = self;
	self.tabBarController.viewControllers = [NSMutableArray arrayWithObjects: 
										questsNavigationController, 
										gpsNavigationController,
										inventoryNavigationController,
										qrScannerNavigationController,
										//arNavigationController,
                                        attributesNavigationController,
										cameraNavigationController,
										audioRecorderNavigationController,
										bogusSelectGameViewController,
										logoutNavigationController,
										startOverNavigationController,
										//developerNavigationController,
										nil];
    self.defaultViewControllerForMainTabBar = questsNavigationController;
    [window addSubview:self.tabBarController.view];
    
    
    //Setup the Game Selection Tab Bar
    
    self.gameSelectionTabBarController = [[UITabBarController alloc] init];
    
    GamePickerMapViewController *gamePickerNearbyViewController = [[[GamePickerNearbyViewController alloc] initWithNibName:@"GamePickerNearbyViewController" bundle:nil] autorelease];
	UINavigationController *gamePickerNearbyNC = [[UINavigationController alloc] initWithRootViewController: gamePickerNearbyViewController];
	gamePickerNearbyNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    GamePickerMapViewController *gamePickerMapVC = [[GamePickerMapViewController alloc]initWithNibName:@"GamePickerMapViewController" bundle:nil];
    UINavigationController *gamePickerMapNC = [[UINavigationController alloc] initWithRootViewController:gamePickerMapVC];
    gamePickerMapNC.navigationBar.barStyle = UIBarStyleBlackOpaque;

    GamePickerSearchViewController *gamePickerSearchVC = [[GamePickerSearchViewController alloc]initWithNibName:@"GamePickerSearchViewController" bundle:nil];
    UINavigationController *gamePickerSearchNC = [[UINavigationController alloc] initWithRootViewController:gamePickerSearchVC];
    gamePickerSearchNC.navigationBar.barStyle = UIBarStyleBlackOpaque;

    GamePickerRecentViewController *gamePickerRecentVC = [[GamePickerRecentViewController alloc]initWithNibName:@"GamePickerRecentViewController" bundle:nil];
    UINavigationController *gamePickerRecentNC = [[UINavigationController alloc] initWithRootViewController:gamePickerRecentVC];
    gamePickerRecentNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.gameSelectionTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                          gamePickerNearbyNC,
                                                          gamePickerMapNC,
                                                          gamePickerSearchNC,
                                                          gamePickerRecentNC,
                                                          nil];
    //[self.gameSelectionTabBarController.view setFrame:UIScreen.mainScreen.applicationFrame];
    [window addSubview:self.gameSelectionTabBarController.view];

    
    
    //Setup The Tutorial View Controller
	self.tutorialViewController = [[TutorialViewController alloc]init];
	self.tutorialViewController.view.frame = self.tabBarController.view.frame;
	self.tutorialViewController.view.hidden = YES;
	self.tutorialViewController.view.userInteractionEnabled = NO;
	[self.tabBarController.view addSubview:self.tutorialViewController.view];
	
                                              
    
	//Setup Location Manager
	myCLController = [[MyCLController alloc] init];
	[NSTimer scheduledTimerWithTimeInterval:3.0 
									 target:myCLController.locationManager 
								   selector:@selector(startUpdatingLocation) 
								   userInfo:nil 
									repeats:NO];
    
		
    self.loginViewNavigationController.view.hidden = NO;
    self.tabBarController.view.hidden = YES;
    self.gameSelectionTabBarController.view.hidden = YES;



}
- (void)displayNotificationTitle:(NSMutableDictionary *) titleAndPrompt{
     self.notificationCount++;
    
    NSMutableDictionary *navBarTitlePromptAndColorDict;
    
    UINavigationController *tempNC;
    
    int x = 0;
    
    //Loop through every viewController and display the notification 
    while (x < [self.tabBarController.customizableViewControllers count])
        {
            //the 7th viewController is "bogusViewController which we want to ignore
            //but it is also then a good spot to check if a modal is on screen
            if([[self.tabBarController.customizableViewControllers objectAtIndex:x] isKindOfClass:[BogusSelectGameViewController class]]) {
                if(self.tabBarController.modalViewController)
                {
                    //set tempNC to the modalView if there is a modal up
                    tempNC = (UINavigationController *)self.tabBarController.modalViewController;
                    self.modalPresent = YES;
                }
                else
                    x++; //if there isnt a modal on screen skip the bogus viewController and go to the next
                
            }
            
            else tempNC = (UINavigationController *)[self.tabBarController.customizableViewControllers objectAtIndex:x];

    NSString *title = [titleAndPrompt objectForKey:@"title"];
    NSString *prompt = [titleAndPrompt objectForKey:@"prompt"];
    

    
    NSString *origTitle = [[tempNC.topViewController.navigationItem.title copy] retain];

    
    navBarTitlePromptAndColorDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",prompt,@"prompt",[UIColor grayColor],@"color", tempNC,@"navbar", nil];
    
       
    //tempNC.topViewController.title = @"Quest was Completed!";
    [self performSelector:@selector(changeNavTitle:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease]  afterDelay:(0+2.5*(self.notificationCount-1))];
    [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] afterDelay:(0+2.5*(self.notificationCount-1))];
    
    [navBarTitlePromptAndColorDict setValue:[UIColor lightGrayColor] forKey:@"color"];    
    [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] afterDelay:(.5+2.5*(self.notificationCount-1))];
    
    [navBarTitlePromptAndColorDict setValue:[UIColor grayColor] forKey:@"color"];    
    [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] afterDelay:(1+2.5*(self.notificationCount-1))];
    
    [navBarTitlePromptAndColorDict setValue:[UIColor lightGrayColor] forKey:@"color"];
    [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] afterDelay:(1.5+2.5*(self.notificationCount-1))];
    
    [navBarTitlePromptAndColorDict setValue:[UIColor grayColor] forKey:@"color"];    
    [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] afterDelay:(2+2.5*(self.notificationCount-1))];
    
    [navBarTitlePromptAndColorDict setValue:[UIColor blackColor] forKey:@"color"];
    [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] afterDelay:(2.5+2.5*(self.notificationCount-1))];
    
    [navBarTitlePromptAndColorDict setValue:origTitle forKey:@"title"];
    [navBarTitlePromptAndColorDict setValue:nil forKey:@"prompt"];
    [self performSelector:@selector(changeNavTitle:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] afterDelay:(2.5+2.5*(self.notificationCount-1))];
    [origTitle release];

            x++;
        }
    [self performSelector:@selector(decrementNotificationCount:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] afterDelay:(2.5+2.5*(self.notificationCount-1))];
    
}

- (void) changeNavColor: (NSDictionary *) navBarAndColorDict {
    UINavigationController *tempNC = [navBarAndColorDict objectForKey:@"navbar"];
    UIColor *color = [navBarAndColorDict objectForKey:@"color"];
    [UIView beginAnimations:@"changeNavColor" context:nil];
    [UIView setAnimationDuration:0.5];
    tempNC.topViewController.navigationController.navigationBar.tintColor = color;
    [UIView commitAnimations];
}

-(void) decrementNotificationCount: (NSDictionary *) navBarDict {
    self.notificationCount--;
    
}

-(void) changeNavTitle: (NSDictionary *) navBarTitleAndPromptDict {
        UINavigationController *tempNC = [navBarTitleAndPromptDict objectForKey:@"navbar"];
   
    tempNC.topViewController.navigationItem.title = [navBarTitleAndPromptDict objectForKey:@"title"];
    tempNC.topViewController.navigationItem.prompt = [navBarTitleAndPromptDict objectForKey:@"prompt"];
    
    //Code below just disables the buttons when a notification is up
    if(tempNC.topViewController.navigationItem.leftBarButtonItem) 
    {
        if (tempNC.topViewController.navigationItem.leftBarButtonItem.enabled) {
            tempNC.topViewController.navigationItem.leftBarButtonItem.enabled = NO;  
        }
        else tempNC.topViewController.navigationItem.leftBarButtonItem.enabled = YES;
    }
    if(tempNC.topViewController.navigationItem.rightBarButtonItem)
    {
        if (tempNC.topViewController.navigationItem.rightBarButtonItem.enabled) {
            tempNC.topViewController.navigationItem.rightBarButtonItem.enabled = NO;  
        }    
        else tempNC.topViewController.navigationItem.rightBarButtonItem.enabled = YES; 
    }
    
   
}


- (void)attemptLoginWithUserName:(NSString *)userName andPassword:(NSString *)password {	
	NSLog(@"AppDelegate: Attempt Login for: %@ Password: %@", userName, password);
	[AppModel sharedAppModel].username = userName;
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
        
        
	} else {
		NSLog(@"AppDelegate: Login Failed, check for a network issue");
		if (self.networkAlert) NSLog(@"AppDelegate: Network is down, skip login alert");
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginErrorTitleKey",@"")
															message:NSLocalizedString(@"LoginErrorMessageKey",@"")
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];
		}
	}
	
}

- (void) showGameSelectionTabBarAndHideOthers {
    [self returnToHomeView];
    self.tabBarController.view.hidden = YES;
    self.gameSelectionTabBarController.view.hidden = NO;
    self.loginViewNavigationController.view.hidden = YES;
}

- (void)selectGame:(NSNotification *)notification {
    //NSDictionary *loginObject = [notification object];
	NSDictionary *userInfo = notification.userInfo;
	Game *selectedGame = [userInfo objectForKey:@"game"];
    
	NSLog(@"AppDelegate: Game Selected. '%@' game was selected", selectedGame.name);
	
    self.tabBarController.view.hidden = NO;
    self.gameSelectionTabBarController.view.hidden = YES;
    self.loginViewNavigationController.view.hidden = YES;
    
    [self returnToHomeView];
	
	//Set the model to this game
	[AppModel sharedAppModel].currentGame = selectedGame;
	[[AppModel sharedAppModel] saveUserDefaults];
	
	//Clear out the old game data
	[[AppServices sharedAppServices] resetAllPlayerLists];
    [[AppServices sharedAppServices] resetAllGameLists];
	[tutorialViewController dismissAllTutorials];
	
	//Notify the Server
	NSLog(@"AppDelegate: Game Selected. Notifying Server");
	[[AppServices sharedAppServices] updateServerGameSelected];
	
	
	UINavigationController *navigationController
    ;
	
	//Get the naviation controller and visible view controller
	if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
		navigationController = (UINavigationController*)tabBarController.selectedViewController;
	}
	else {
		navigationController = nil;
	}
	
    //Start loading all the data
    [[AppServices sharedAppServices] fetchAllGameLists];
	[[AppServices sharedAppServices] fetchAllPlayerLists];
    
    //Display the intro node
    if ([AppModel sharedAppModel].currentGame.completedQuests < 1) [self displayIntroNode];
    	
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



- (void)applicationDidBecomeActive:(UIApplication *)application{
	NSLog(@"AppDelegate: applicationDidBecomeActive");
	[[AppModel sharedAppModel] loadUserDefaults];
}



- (void) showServerAlertWithEmail:(NSString *)title message:(NSString *)message details:(NSString*)detail{
	
	if (!self.serverAlert){
		self.serverAlert = [[UIAlertView alloc] initWithTitle:title
														message:[NSString stringWithFormat:@"%@\n\nDetails:\n%@", message, detail]
													   delegate:self cancelButtonTitle:@"Ignore" otherButtonTitles: @"Report",nil];
		[self.serverAlert show];	
 	}
	else {
		NSLog(@"AppDelegate: showServerAlertWithEmail was called, but a server alert was already present");
	}

}

- (void) showNetworkAlert{
	NSLog (@"AppDelegate: Showing Network Alert");
	
	if (!self.networkAlert) {
		networkAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"PoorConnectionTitleKey", @"") 
											message: NSLocalizedString(@"PoorConnectionMessageKey", @"")
												 delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
	NSLog (@"AppDelegate: Showing Waiting Indicator");
	if (self.waitingIndicatorView) [self.waitingIndicatorView release];
	
	self.waitingIndicatorView = [[WaitingIndicatorView alloc] initWithWaitingMessage:message showProgressBar:NO];
	[self.waitingIndicatorView show];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the activity indicator show before returning	
}

- (void) removeNewWaitingIndicator {
	NSLog (@"AppDelegate: Removing Waiting Indicator");
	if (self.waitingIndicatorView != nil) [self.waitingIndicatorView dismiss];
}


- (void) showWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar {
	NSLog (@"AppDelegate: Showing Waiting Indicator");
	if (!self.waitingIndicator) {
		self.waitingIndicator = [[WaitingIndicatorViewController alloc] initWithNibName:@"WaitingIndicator" bundle:nil];
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


- (void) showNearbyTab:(BOOL)yesOrNo {
	NSMutableArray *tabs = [NSMutableArray arrayWithArray:tabBarController.viewControllers];
	
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



- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate{
	NSLog(@"AppDelegate: Playing an audio Alert sound");
	
	//Vibrate
	if (shouldVibrate == YES) [NSThread detachNewThreadSelector:@selector(vibrate) toTarget:self withObject:nil];	
	//Play the sound on a background thread
	[NSThread detachNewThreadSelector:@selector(playAudio:) toTarget:self withObject:wavFileName];
}

//Play a sound
- (void) playAudio:(NSString*)wavFileName {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  

	
	SystemSoundID alert;  
	NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:wavFileName ofType:@"wav"]];
	AudioServicesCreateSystemSoundID((CFURLRef)url, &alert);  
	AudioServicesPlaySystemSound (alert);
				  
	[pool release];
}

//Vibrate
- (void) vibrate {
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);  
}

- (void)newError: (NSString *)text {
	NSLog(@"%@", text);
}

- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController {	
	nearbyObjectNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyObjectViewController];
	nearbyObjectNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		
	//Display
	[self.tabBarController presentModalViewController:nearbyObjectNavigationController animated:YES];
	[nearbyObjectNavigationController release];
}


- (void) returnToHomeView{
	NSLog(@"AppDelegate: Returning to Home View and Popping More Nav Controller");
    [self.tabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
	[self.tabBarController setSelectedViewController:self.defaultViewControllerForMainTabBar];	
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

#pragma mark AlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	//Since only the server error alert with email ever uses this, we know who we are dealing with
	NSLog(@"AppDelegate: AlertView clickedButtonAtIndex: %d",buttonIndex);
	
	if (buttonIndex == 1) {
		NSLog(@"AppDelegate: AlertView button wants to send an email" );
		//Send an Email
		NSString *body = [NSString stringWithFormat:@"%@",alertView.message];
		MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		[controller setToRecipients: [NSMutableArray arrayWithObjects: @"arisgames-dev@googlegroups.com",nil]];
		[controller setSubject:@"ARIS Error Report"];
		[controller setMessageBody:body isHTML:NO]; 
		if (controller) [self.tabBarController presentModalViewController:controller animated:YES];
		[controller release];
	}
	
	[self.serverAlert release];
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

	 
}


#pragma mark Memory Management

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"AppDelegate: Begin Application Resign Active");
    
   [tabBarController dismissModalViewControllerAnimated:NO];

	[[AppModel sharedAppModel] saveUserDefaults];
}

-(void) applicationWillTerminate:(UIApplication *)application {
	NSLog(@"AppDelegate: Begin Application Termination");
	[[AppModel sharedAppModel] saveUserDefaults];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
@end


//
//  ARISAppDelegate.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import "ARISAppDelegate.h"
#import "Node.h"

@implementation ARISAppDelegate

@synthesize appModel;
@synthesize window;
@synthesize tabBarController;
@synthesize loginViewController;
@synthesize loginViewNavigationController;
@synthesize gamePickerViewController;
@synthesize gamePickerNavigationController;
@synthesize nearbyBar;
@synthesize nearbyObjectNavigationController;
@synthesize myCLController;
@synthesize waitingIndicator;
@synthesize networkAlert;

//@synthesize toolbarViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	//Don't sleep
	application.idleTimerDisabled = YES;
	
	//init app model
	appModel = [[AppModel alloc] init];
	
	//Init keys in UserDefaults in case the user has not visited the ARIS Settings page
	//To set these defaults, edit Settings.bundle->Root.plist 
	[appModel initUserDefaults];
	
	//Load defaults from UserDefaults
	[appModel loadUserDefaults];
	[appModel retain];
	
	
	//Check for Internet conductivity
	NSLog(@"AppDelegate: Verifying Connection to: %@",appModel.serverName);
	Reachability *r = [Reachability reachabilityWithHostName:appModel.serverName];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL connection = (internetStatus == ReachableViaWiFi) || (internetStatus == ReachableViaWWAN);
	connection = YES; //For debugging locally
	if (!connection) {
		NSLog(@"AppDelegate: Internet Connection Failed");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No connection to the Internet" message: @"Please connect to the internet and restart ARIS" delegate: self cancelButtonTitle: nil otherButtonTitles: nil];
		[alert show];
		[alert release];
		return;
	} else {
		NSLog(@"AppDelegate: Internet Connection Functional");
	}

	//register for notifications from views
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(performUserLogin:) name:@"PerformUserLogin" object:nil];
	[dispatcher addObserver:self selector:@selector(selectGame:) name:@"SelectGame" object:nil];
	[dispatcher addObserver:self selector:@selector(performLogout:) name:@"LogoutRequested" object:nil];
	[dispatcher addObserver:self selector:@selector(displayNearbyObjects:) name:@"NearbyButtonTouched" object:nil];

	//Setup ARView
	ARViewViewControler *arViewController = [[[ARViewViewControler alloc] initWithNibName:@"ARView" bundle:nil] autorelease];
	UINavigationController *arNavigationController = [[UINavigationController alloc] initWithRootViewController: arViewController];
	arNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Setup Tasks View
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
	
	
	//Game Picker View
	gamePickerViewController = [[[GamePickerViewController alloc] initWithNibName:@"GamePicker" bundle:nil] autorelease];
	gamePickerViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	gamePickerNavigationController = [[UINavigationController alloc] initWithRootViewController: gamePickerViewController];
	gamePickerNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[loginViewController retain]; //This view may be removed and readded to the window

	//Login View
	loginViewController = [[[LoginViewController alloc] initWithNibName:@"Login" bundle:nil] autorelease];
	[loginViewController setModel:appModel];
	loginViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	loginViewNavigationController = [[UINavigationController alloc] initWithRootViewController: loginViewController];
	loginViewNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[loginViewController retain]; //This view may be removed and readded to the window
	
	//Add the view controllers to the Tab Bar
	tabBarController.viewControllers = [NSMutableArray arrayWithObjects: 
										questsNavigationController, 
										gpsNavigationController,
										inventoryNavigationController,
										qrScannerNavigationController,
										//arNavigationController,
										cameraNavigationController,
										audioRecorderNavigationController,
										gamePickerNavigationController,
										logoutNavigationController,
										startOverNavigationController,
										//developerNavigationController,
										nil];	

	[window addSubview:tabBarController.view];	

	//Customize the 'more' nav controller on the tab bar
	UINavigationController *moreNavController = tabBarController.moreNavigationController;
	moreNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	moreNavController.delegate = self;
	
	//Setup Location Manager
	myCLController = [[MyCLController alloc] initWithAppModel:appModel];
	[myCLController.locationManager startUpdatingLocation];
		
	//Display the login screen if this user is not logged in
	if (appModel.loggedIn == YES) {
		[appModel fetchGameList];
		if (!appModel.gameId || appModel.gameId == 0 ) {
			NSLog(@"Appdelegate: Player already logged in, but a site has not been selected. Display site picker");
			tabBarController.view.hidden = YES;
			[window addSubview:gamePickerNavigationController.view];
		}
		else {
			NSLog(@"Appdelegate: Player already logged in and they have a site selected. Go into the default module");
			[appModel fetchMediaList];
			[appModel fetchLocationList];
			[appModel fetchInventory];
			
			[self playAudioAlert:@"questChange" shouldVibrate:NO];
		}
	}
	else {
		NSLog(@"Appdelegate: Player not logged in, display login");
		tabBarController.view.hidden = YES;
		[window addSubview:loginViewNavigationController.view];
	}
	
	//Inventory Bar, which is really a view
	nearbyBar = [[NearbyBar alloc] initWithFrame:CGRectMake(0.0, 63.0, 320.0, 20.0)];
	[window addSubview:nearbyBar];	
	
}


- (void) showNetworkAlert{
	NSLog (@"AppDelegate: Showing Network Alert");
	
	if (!self.networkAlert) {
		networkAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:
						@"ARIS is not able to communicate with the server. Check your internet connection."
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




- (void) showWaitingIndicator:(NSString *)message {
	NSLog (@"AppDelegate: Showing Waiting Indicator");
	if (!self.waitingIndicator) {
		self.waitingIndicator = [[WaitingIndicatorViewController alloc] initWithNibName:@"WaitingIndicator" bundle:nil];
	}
	self.waitingIndicator.message = message;
	
	//by adding a subview to window, we make sure it is put on top
	if (appModel.loggedIn == YES) {
		//[NSThread detachNewThreadSelector:@selector(addSubview:) toTarget:self.window withObject:self.waitingIndicator.view];
		[self.window addSubview:self.waitingIndicator.view]; 
	}
}

- (void) removeWaitingIndicator {
	NSLog (@"AppDelegate: Removing Waiting Indicator");
	if (self.waitingIndicator != nil) [self.waitingIndicator.view removeFromSuperview ];
}

- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate{
	NSLog(@"AppDelegate: Playing an audio Alert sound");
	
	//Vibrate
	if (shouldVibrate == YES) 	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);  

	//Play a sound
	SystemSoundID alert;  
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:wavFileName ofType:@"wav"]], &alert);  
	AudioServicesPlaySystemSound (alert);  
	
}





- (void)newError: (NSString *)text {
	NSLog(@"%@", text);
}

- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController {
	nearbyObjectNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyObjectViewController];
	nearbyObjectNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Create a close button
	nearbyObjectViewController.navigationItem.leftBarButtonItem = 
		[[UIBarButtonItem alloc] initWithTitle:@"Back"
								style: UIBarButtonItemStyleBordered
								target:nearbyObjectNavigationController.view 
								action:@selector(removeFromSuperview)];	
	//Display
	[window addSubview:nearbyObjectNavigationController.view]; //Didn't display the tab bar below!
}




- (void)performUserLogin:(NSNotification *)notification {
	NSLog(@"AppDelegate: Login Requested");
	
	NSDictionary *userInfo = notification.userInfo;
	
	NSLog(@"AppDelegate: Perform Login for: %@ Paswword: %@", [userInfo objectForKey:@"username"], [userInfo objectForKey:@"password"]);
	appModel.username = [userInfo objectForKey:@"username"];
	appModel.password = [userInfo objectForKey:@"password"];

	[appModel login];
	
	//handle login response
	if(appModel.loggedIn) {
		NSLog(@"AppDelegate: Login Success");
		[loginViewNavigationController.view removeFromSuperview];
		[window addSubview:gamePickerNavigationController.view]; //This will automatically load it's own data
		gamePickerViewController.view.frame = [UIScreen mainScreen].applicationFrame;

	} else {
		NSLog(@"AppDelegate: Login Failed, check for a network issue");
		if (self.networkAlert) NSLog(@"AppDelegate: Network is down, skip login alert");
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Invalid username or password."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];
		}

		
	}
	
}

- (void)selectGame:(NSNotification *)notification {
    //NSDictionary *loginObject = [notification object];
	NSDictionary *userInfo = notification.userInfo;
	Game *selectedGame = [userInfo objectForKey:@"game"];
	
	NSLog(@"AppDelegate: Game Selected. '%@' game was selected using '%@' as it's site", selectedGame.name, selectedGame.site);

	[gamePickerNavigationController.view removeFromSuperview];
	
	//Set the model to this game
	appModel.site = selectedGame.site;
	appModel.gameId = selectedGame.gameId;
	appModel.gamePcMediaId = selectedGame.pcMediaId;
	
	//Notify the Server
	NSLog(@"AppDelegate: Game Selected. Notifying Server");
	[appModel updateServerGameSelected];
	
	//Set tabBar to the first item
	tabBarController.selectedIndex = 0;
	
	//Display the tabBar (and it's content)
	tabBarController.view.hidden = NO;
	
	UINavigationController *navigationController;
	UIViewController *visibleViewController;
	
	//Get the naviation controller and visible view controller
	if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
		navigationController = (UINavigationController*)tabBarController.selectedViewController;
		visibleViewController = [navigationController visibleViewController];
	}
	else {
		navigationController = nil;
		visibleViewController = tabBarController.selectedViewController;
	}
	
	NSLog(@"AppDelegate: %@ selected",[visibleViewController title]);
	[appModel fetchMediaList];
	[appModel fetchLocationList];
	[appModel fetchInventory];
	
	[self playAudioAlert:@"questChange" shouldVibrate:NO];
	
	//Use setModel to refresh the content
	if([visibleViewController respondsToSelector:@selector(refresh)]) {
		[visibleViewController performSelector:@selector(refresh) withObject:nil];
	}
}


- (void)performLogout:(NSNotification *)notification {
    NSLog(@"Performing Logout: Clearing NSUserDefaults and Displaying Login Screen");
	
	//Clear any user realated info in appModel (except server)
	[appModel clearUserDefaults];
	[appModel loadUserDefaults];
	
	//(re)load the login view
	tabBarController.view.hidden = YES;
	[window addSubview:loginViewNavigationController.view];
}




#pragma mark Tab Bar delegate

// A Player selected a tab from the tab bar
- (void)tabBarController:(UITabBarController *)tabController didSelectViewController:(UIViewController *)viewController {
		
	UINavigationController *navigationController;
	UIViewController *visibleViewController;
	
	//Get the naviation controller and visible view controller
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		navigationController = (UINavigationController*)viewController;
		visibleViewController = [navigationController visibleViewController];
	}
	else {
		navigationController = nil;
		visibleViewController = viewController;
	}
	
	NSLog(@"AppDelegate: %@ selected",[visibleViewController title]);
	
	//Hides the existing Controller
	UIViewController *selViewController = [tabBarController selectedViewController];
	[selViewController.navigationController.view removeFromSuperview];
	
	[self playAudioAlert:@"click" shouldVibrate:NO];
	
}


#pragma mark navigation controller delegate
- (void)navigationController:(UINavigationController *)navigationController 
	   didShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated {
	
}

#pragma mark Memory Management

-(void) applicationWillTerminate:(UIApplication *)application {
	NSLog(@"Begin Application Termination");
	
	[appModel saveUserDefaults];
}

- (void)dealloc {
	[appModel release];
	[super dealloc];
}
@end


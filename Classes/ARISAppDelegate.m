//
//  ARISAppDelegate.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import "ARISAppDelegate.h"

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

//@synthesize toolbarViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	//Don't sleep
	application.idleTimerDisabled = YES;
	
	//init app model
	appModel = [[AppModel alloc] init];
	
	//Init keys in UserDefaults in case the user has not visited the ARIS Settings page
	//To set these defaults, edit Settings.bundle->Root.plist and initUSerDefaults in appMode.m
	[appModel initUserDefaults];
	
	//Load defaults from UserDefaults
	[appModel loadUserDefaults];
	
	[appModel retain];

	//register for notifications from views
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(performUserLogin:) name:@"PerformUserLogin" object:nil];
	[dispatcher addObserver:self selector:@selector(selectGame:) name:@"SelectGame" object:nil];
	[dispatcher addObserver:self selector:@selector(setGameList:) name:@"ReceivedGameList" object:nil];
	[dispatcher addObserver:self selector:@selector(performLogout:) name:@"LogoutRequested" object:nil];
	[dispatcher addObserver:self selector:@selector(displayNearbyObjects:) name:@"NearbyButtonTouched" object:nil];

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

	//QR Scanner Developer View
	QRScannerViewController *qrScannerViewController = [[[QRScannerViewController alloc] initWithNibName:@"QRScanner" bundle:nil] autorelease];
	UINavigationController *qrScannerNavigationController = [[UINavigationController alloc] initWithRootViewController: qrScannerViewController];
	qrScannerNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

	//IM View
	IMViewController *imViewController = [[[IMViewController alloc] initWithNibName:@"IM" bundle:nil] autorelease];
	UINavigationController *imNavigationController = [[UINavigationController alloc] initWithRootViewController: imViewController];
	imNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Logout View
	LogoutViewController *logoutViewController = [[[LogoutViewController alloc] initWithNibName:@"Logout" bundle:nil] autorelease];
	UINavigationController *logoutNavigationController = [[UINavigationController alloc] initWithRootViewController: logoutViewController];
	logoutNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
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
										gpsNavigationController,
										questsNavigationController, 
										inventoryNavigationController,
										qrScannerNavigationController,
										cameraNavigationController,
										imNavigationController,
										gamePickerNavigationController,
										logoutNavigationController,
										developerNavigationController,
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
		if ([appModel.site isEqualToString:@"Default"]) {
			NSLog(@"Appdelegate: Player already logged in, but a site has not been selected. Display site picker");
			tabBarController.view.hidden = YES;
			[window addSubview:gamePickerNavigationController.view];
		}
		else NSLog(@"Appdelegate: Player already logged in and they have a site selected. Go into the default module");
	}
	else {
		NSLog(@"Appdelegate: Player not logged in, display login");
		tabBarController.view.hidden = YES;
		[window addSubview:loginViewNavigationController.view];
	}
	
	//Inventory Bar, which is really a view
<<<<<<< .mine
	nearbyBar = [[NearbyBar alloc] initWithFrame:CGRectMake(0.0, 63.0, 320.0, 20.0)];
=======
	nearbyBar = [[NearbyBar alloc] initWithFrame:CGRectMake(0.0, 63.0, 320.0, 15.0)];
>>>>>>> .r10729
	[window addSubview:nearbyBar];	
}


# pragma mark custom methods, notification handlers
- (void)newError: (NSString *)text {
	NSLog(text);
}

- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController {	
	nearbyObjectNavigationController = [[UINavigationController alloc] initWithRootViewController: nearbyObjectViewController];
	nearbyObjectNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//Create a close button
	nearbyObjectViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																												target:nearbyObjectNavigationController.view 
																												action:@selector(removeFromSuperview)];
	//Display
	[window addSubview:nearbyObjectNavigationController.view]; //Didn't display the tab bar below!
}

- (void)performUserLogin:(NSNotification *)notification {
	NSDictionary *userInfo = notification.userInfo;
	
	NSLog([NSString stringWithFormat:@"AppDelegate: Perform Login for: %@ Paswword: %@", [userInfo objectForKey:@"username"], [userInfo objectForKey:@"password"]] );
	appModel.username = [userInfo objectForKey:@"username"];
	appModel.password = [userInfo objectForKey:@"password"];
	BOOL loginSuccessful = [appModel login];
	NSLog([appModel description]);
	//handle login response
	if(loginSuccessful) {
		NSLog(@"AppDelegate: Login Success");
		[loginViewNavigationController.view removeFromSuperview];
		[appModel fetchGameList];
		[window addSubview:gamePickerNavigationController.view];
		gamePickerViewController.view.frame = [UIScreen mainScreen].applicationFrame;

	} else {
		NSLog(@"AppDelegate: Login Failed");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Invalid username or password."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
	
}

- (void)selectGame:(NSNotification *)notification {
    //NSDictionary *loginObject = [notification object];
	NSDictionary *userInfo = notification.userInfo;
	Game *selectedGame = [userInfo objectForKey:@"game"];
	
	NSLog([NSString stringWithFormat:@"AppDelegate: Game Selected. '%@' game was selected using '%@' as it's site", selectedGame.name, selectedGame.site]);

	[gamePickerNavigationController.view removeFromSuperview];
	
	//Set tabBar to the first item
	tabBarController.selectedIndex = 0;
	
	//Set the model to this game
	appModel.site = selectedGame.site;
	
	//Display the tabBar (and it's content)
	tabBarController.view.hidden = NO;
	
	//Get the visible view controller and make sure it's model has been set
	UIViewController *viewController = [tabBarController selectedViewController];
	UIViewController *visibleViewController;
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *navigationController = (UINavigationController*) viewController;
		visibleViewController = [navigationController visibleViewController];
		[visibleViewController performSelector:@selector(setModel:) withObject:appModel];
	}
	else {
		visibleViewController = viewController;
		[visibleViewController performSelector:@selector(setModel:) withObject:appModel];
	}
}

- (void)setGameList:(NSNotification *)notification {
    //NSDictionary *loginObject = [notification object];
	NSDictionary *userInfo = notification.userInfo;
	NSMutableArray *gameList = [userInfo objectForKey:@"gameList"];
	NSLog(@"AppDelegate: Setting Game List on controller");
	[gamePickerViewController setGameList:gameList];
	[gamePickerViewController slideIn];
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
	
	//Use setModel to refresh the content
	if([visibleViewController respondsToSelector:@selector(setModel:)]) {
		[visibleViewController performSelector:@selector(setModel:) withObject:appModel];
	}
	
	//Hides the existing Controller
	UIViewController *selViewController = [tabBarController selectedViewController];
	[selViewController.navigationController.view removeFromSuperview];
	
	//Displays the view Controller
	[window addSubview:viewController.navigationController.view];	
	
}


#pragma mark navigation controller delegate
- (void)navigationController:(UINavigationController *)navigationController 
	   didShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated {
	
	if([viewController class] == [gamePickerViewController class]) {
		[viewController performSelector:@selector(setGameList:) withObject:appModel.gameList];
	}
	if([viewController respondsToSelector:@selector(setModel:)]) {
		[viewController performSelector:@selector(setModel:) withObject:appModel];
	}
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


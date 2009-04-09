//
//  ARISAppDelegate.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import "ARISAppDelegate.h"
#import "model/Game.h"
#import "NearbyLocation.h"

//private
@interface ARISAppDelegate (hidden)

-(void) contractTabBar;
-(void) expandTabBar;

@end

@implementation ARISAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize loginViewController;
@synthesize toolbarViewController;
@synthesize gamePickerViewController;
@synthesize genericWebViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	//init app model
	appModel = [[AppModel alloc] init];
	appModel.baseAppURL = @"http://atsosxdev.doit.wisc.edu/aris/games/index.php";
	appModel.site = @"Default";
	[appModel loadUserDefaults];
	[appModel retain];

	//register for notifications from views
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(performUserLogin:) name:@"PerformUserLogin" object:nil];
	[dispatcher addObserver:self selector:@selector(selectGame:) name:@"SelectGame" object:nil];
	[dispatcher addObserver:self selector:@selector(setGameList:) name:@"ReceivedGameList" object:nil];
	[dispatcher addObserver:self selector:@selector(performLogout:) name:@"LogoutRequested" object:nil];
	[dispatcher addObserver:self selector:@selector(displayNearbyObjects:) name:@"NearbyButtonTouched" object:nil];
	[dispatcher addObserver:self selector:@selector(destroyNearbyObjectsView:) name:@"BackButtonTouched" object:nil];
	
	//set frame rect of Tabbar view to sit below title/nav bar
	[self contractTabBar];
	
	UIView *tableView = gamePickerViewController.view;
	tableView.frame = CGRectMake(0.0f, 485.0f, 320.0f, 416.0f);
	
    // Add the tab bar controller's current view as a subview of the window
	[window addSubview:toolbarViewController.view];
	[window addSubview:tabBarController.view];	

	
	//Display the login screen if this user is not logged in
	if (appModel.loggedIn == YES) {
		[appModel fetchGameList];
		if (appModel.site == @"Default") {
			NSLog(@"Player already logged in, but a site has not been selected. Display site picker");
			[window addSubview:gamePickerViewController.view];
		}
		else NSLog(@"Player already logged in and they have a site selected. Go into the default module");
	}
	else {
		NSLog(@"Player not logged in, display login");
		[window addSubview:loginViewController.view];
	}
	
	UINavigationController *moreNavController = tabBarController.moreNavigationController;
	//customize the more nav controller
	moreNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	moreNavController.delegate = self;
	
	//make sure first view controller in tab has model set
	UIViewController *selViewController = [tabBarController selectedViewController];
	[selViewController performSelector:@selector(setModel:) withObject:appModel];
	
	//Setup MyCLController
	myCLController = [[MyCLController alloc] init];
	myCLController.delegate = self;
	[myCLController.locationManager startUpdatingLocation];
}

// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabController didSelectViewController:(UIViewController *)viewController {
	if(tabBarController.selectedIndex == 4) {
		[self expandTabBar];
	} else if(tabBarController.selectedIndex < 4) {
		//navController = 
		[self contractTabBar];
		[toolbarViewController setToolbarTitle:viewController.title];
	}
	
	if([viewController respondsToSelector:@selector(setModel:)]) {
		[viewController performSelector:@selector(setModel:) withObject:appModel];
	}
	
	UINavigationController *navController = viewController.navigationController;
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}




# pragma mark custom methods, notification handlers

- (void)contractTabBar {
	UIView *tabBar = tabBarController.view;
	tabBar.frame = CGRectMake(0.0f, 64.0f, 320.0f, 416.0f);
}

- (void)expandTabBar {
	UIView *tabBar = tabBarController.view;
	tabBar.frame = CGRectMake(0.0f, 20.0f, 320.0f, 460.0f);
}

- (void)performUserLogin:(NSNotification *)notification {
	NSDictionary *userInfo = notification.userInfo;
	
	NSLog([NSString stringWithFormat:@"Perform Login for: %@ Paswword: %@", [userInfo objectForKey:@"username"], [userInfo objectForKey:@"password"]] );
	appModel.username = [userInfo objectForKey:@"username"];
	appModel.password = [userInfo objectForKey:@"password"];
	BOOL loginSuccessful = [appModel login];
	NSLog([appModel description]);
	//handle login response
	if(loginSuccessful) {
		NSLog(@"Login Success");
		[loginViewController setNavigationTitle:@"Select a Game"];	
		[loginViewController.view removeFromSuperview];
		[window addSubview:gamePickerViewController.view];
		[appModel fetchGameList];
	} else {
		NSLog(@"Login Failed");
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
	
	NSLog([NSString stringWithFormat:@"Game Selected: %@", selectedGame.name]);

	[gamePickerViewController.view removeFromSuperview];
	
	//change tab bar selected index
	tabBarController.selectedIndex = 0;
	
	//Set the model to this game
	appModel.site = selectedGame.name;
		
	//Load the default module, TODO
	appModel.currentModule = @"TODO";
}

- (void)setGameList:(NSNotification *)notification {
    //NSDictionary *loginObject = [notification object];
	NSDictionary *userInfo = notification.userInfo;
	NSMutableArray *gameList = [userInfo objectForKey:@"gameList"];
	NSLog(@"SETTING Game List on controller");
	[gamePickerViewController setGameList:gameList];
	[gamePickerViewController slideIn];
}

- (void)performLogout:(NSNotification *)notification {
    NSLog(@"Performing Logout: Clearing NSUserDefaults and Displaying Login Screen");
	
	//Clear NSUserDefaults
	NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
	[defaults removeObjectForKey:@"loggedIn"];	
	[defaults release];
	
	
	//(re)load the login view
	[window addSubview:loginViewController.view];
	loginViewController.view.hidden == NO;
}

- (void)displayNearbyObjects:(NSNotification *)notification {
	NSLog(@"Nearby Button Notification recieved by App Delegate");
	//We should have the nearbyLocationList aray in the model that tells us what is nearby
	//If only one object exists (a single NPC, Node or Item) launch it in a modal UIWebView
	//Otherwise, create a list
	
	if ([appModel.nearbyLocationsList count] == 1) {
		//Take them to the item
		NearbyLocation *loc = [appModel.nearbyLocationsList objectAtIndex: 0 ];
		NSString *moduleName;
		if ([loc.type isEqualToString: @"Item"]) moduleName = @"RESTInventory";
		else moduleName = @"RESTNodeViewer";
		NSString *baseURL = [appModel getURLStringForModule:moduleName];
		NSString *URLparams = loc.URL;
		NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
		
		NSLog([NSString stringWithFormat:@"Loading genericWebView for: %@ at %@", loc.name, fullURL ]);
		[genericWebViewController setModel:appModel];
		[genericWebViewController setURL: fullURL];
		[genericWebViewController setToolbarTitle:loc.name];
		[window addSubview:genericWebViewController.view];
	}
	else {
		//Take them to a list 
	}
	
}

- (void)destroyNearbyObjectsView:(NSNotification *)notification {
	NSLog(@"Removing View: Nearby Objects");
	[genericWebViewController.view removeFromSuperview];
}

#pragma mark --- Delegate methods for MyCLController ---
- (void)updateLatitude: (NSString *)latitude andLongitude:(NSString *)longitude andAccuracy:(float)accuracy  {	
	//Update the Model
	appModel.lastLatitude = [latitude copy];
	appModel.lastLongitude = [longitude copy];
	appModel.lastLocationAccuracy = accuracy;
	
	//Tell the other parts of the client
	NSNotification *updatedLocationNotification = [NSNotification notificationWithName:@"PlayerMoved" object:self];
	[[NSNotificationCenter defaultCenter] postNotification:updatedLocationNotification];

	//Tell the model to update the server and fetch any nearby locations
	[appModel updateServerLocationAndfetchNearbyLocationList];
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

- (void)newError: (NSString *)text {
	NSLog(text);
}

-(void) applicationWillTerminate:(UIApplication *)application {
	NSLog(@"Begin Application Termination");
	
	//Set User Defaults for next Load
	NSLog(@"Saving Settings in User Defaults");
	NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
	[defaults setObject:appModel.site forKey:@"site"];
	[defaults setBool:appModel.loggedIn forKey:@"loggedIn"];
	[defaults setObject:appModel.username forKey:@"username"];
	[defaults setObject:appModel.password forKey:@"password"];
	[defaults setObject:appModel.baseAppURL forKey:@"baseAppURL"];
	
	[defaults release];
	
	
}

- (void)dealloc {
	[appModel release];
	[super dealloc];
}
@end


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
#import "Item.h"
#import "ItemDetailsViewController.h"

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
	[dispatcher addObserver:self selector:@selector(processNearbyLocationsList:) name:@"ReceivedNearbyLocationList" object:nil];
	[dispatcher addObserver:self selector:@selector(displayNearbyObjects:) name:@"NearbyButtonTouched" object:nil];
	[dispatcher addObserver:self selector:@selector(destroyNearbyObjectsView:) name:@"BackButtonTouched" object:nil];
	
	//set frame rect of Tabbar view to sit below title/nav bar
	[self contractTabBar];
	
	UIView *tableView = gamePickerViewController.view;
	tableView.frame = CGRectMake(0.0f, 485.0f, 320.0f, 416.0f);
	
    // Add the tab bar controller's current view as a subview of the window
	[window addSubview:toolbarViewController.view];
	[toolbarViewController setModel:appModel];
	
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
	
	//make sure first view controller in tab has model set, but black it out
	UIViewController *selViewController = [tabBarController selectedViewController];
	[selViewController performSelector:@selector(setModel:) withObject:appModel];
	
	//Setup MyCLController
	myCLController = [[MyCLController alloc] initWithAppModel:appModel];
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
	
	NSLog([NSString stringWithFormat:@"AppDelegate: '%@' Selected using '%@' as it's site", selectedGame.name, selectedGame.site]);

	[gamePickerViewController.view removeFromSuperview];
	
	//change tab bar selected index
	tabBarController.selectedIndex = 0;
	
	//Set the model to this game
	appModel.site = selectedGame.site;
	
	//Refresh the first ViewController that has been hiding under the login/select game stuff by reloading it's model
	UIViewController *selViewController = [tabBarController selectedViewController];
	[selViewController performSelector:@selector(setModel:) withObject:appModel];
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
	
	//Clear NSUserDefaults
	NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
	[defaults removeObjectForKey:@"loggedIn"];	
	[defaults release];
	
	
	//(re)load the login view
	[window addSubview:loginViewController.view];
	loginViewController.view.hidden == NO;
}

- (void)processNearbyLocationsList:(NSNotification *)notification {
    NSLog(@"App Delegate recieved Nearby Locations List Notification");
	NSArray *nearbyLocations = notification.object;
	//Check for a force View flag in one of the nearby locations and display if found
	for (NSObject *unknownNearbyLocation in nearbyLocations) {
		if ([unknownNearbyLocation isKindOfClass:[NearbyLocation class]]) {
			NearbyLocation *nearbyLocation = unknownNearbyLocation;
			if (nearbyLocation.forceView == YES) {
				NSLog(@"A forced view location is nearby");
				NSString *baseURL = [appModel getURLStringForModule:@"RESTNodeViewer"];
				NSString *URLparams = nearbyLocation.URL;
				NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
					
				NSLog([NSString stringWithFormat:@"Loading genericWebView for: %@ at %@", nearbyLocation.name, fullURL ]);
					
										
				[genericWebViewController setModel:appModel];
				[genericWebViewController setURL: fullURL];
				[genericWebViewController setToolbarTitle:nearbyLocation.name];
				[window addSubview:genericWebViewController.view];					
			}
		}
	}
}



- (void)displayNearbyObjects:(NSNotification *)notification {
	NSLog(@"Nearby Button Touched Notification recieved by App Delegate");
	//We should have the nearbyLocationList aray in the model that tells us what is nearby
	//If only one object exists (a single NPC, Node or Item) launch it in a modal UIWebView
	//Otherwise, create a list
	
	//if ([appModel.nearbyLocationsList count] == 1) {
		//Take them to the object
		if ([[appModel.nearbyLocationsList objectAtIndex: 0 ] isKindOfClass:[Item class]]) {
			//It's an item, use a real view controller
			Item *nearbyItem = [appModel.nearbyLocationsList objectAtIndex: 0 ];
			ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] initWithNibName:@"ItemDetailsView" bundle:[NSBundle mainBundle]];
			[itemDetailsViewController setModel:appModel];
			[itemDetailsViewController setItem:nearbyItem];
			itemDetailsViewController.inInventory = NO;
			[tabBarController presentModalViewController:itemDetailsViewController animated:YES];
			[itemDetailsViewController release];
		}
		else if ([[appModel.nearbyLocationsList objectAtIndex: 0 ] isKindOfClass:[NearbyLocation class]]){
			//It is a NearbyLocation, using the old WebView approach
			NearbyLocation *loc = [appModel.nearbyLocationsList objectAtIndex: 0 ];
			NSString *baseURL = [appModel getURLStringForModule:@"RESTNodeViewer"];
			NSString *URLparams = loc.URL;
			NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
		
			NSLog([NSString stringWithFormat:@"Loading genericWebView for: %@ at %@", loc.name, fullURL ]);
			[genericWebViewController setModel:appModel];
			[genericWebViewController setURL: fullURL];
			[genericWebViewController setToolbarTitle:loc.name];
			[window addSubview:genericWebViewController.view];
		}
	//}
	//else {
		//Take them to a list 
	//}
	
}

- (void)destroyNearbyObjectsView:(NSNotification *)notification {
	NSLog(@"Removing View: Nearby Objects");
	[genericWebViewController.view removeFromSuperview];
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


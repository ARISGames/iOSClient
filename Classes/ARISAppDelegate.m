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
#import "webpageViewController.h"
#import "NoteDetailsViewController.h"
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
@synthesize titleLabel,descLabel,notifArray,tabShowY;


//@synthesize toolbarViewController;

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != nil) {
        NSLog(@"Error: %@", error);
    }
}

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
   
    tabShowY = 20;
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
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 15)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor blackColor];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:12];
    descLabel.textAlignment = UITextAlignmentCenter;
    descLabel.backgroundColor = [UIColor blackColor];
    [self.window addSubview:titleLabel];
    [self.window addSubview:descLabel];
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
    
    //Setup Notes View
    NotebookViewController *notesViewController = [[[NotebookViewController alloc] initWithNibName:@"NotebookViewController" bundle:nil] autorelease];
	UINavigationController *notesNavigationController = [[UINavigationController alloc] initWithRootViewController: notesViewController];
	notesNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
	//Setup Camera View
	/*CameraViewController *cameraViewController = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
	UINavigationController *cameraNavigationController = [[UINavigationController alloc] initWithRootViewController: cameraViewController];
	cameraNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;*/

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
										startOverNavigationController,
										//developerNavigationController,
										nil];
    self.defaultViewControllerForMainTabBar = questsNavigationController;
    self.tabBarController.view.hidden = YES;
    [window addSubview:self.tabBarController.view];
    [AppModel sharedAppModel].defaultGameTabList = self.tabBarController.customizableViewControllers;
    
    //Setup the Game Selection Tab Bar
    
    self.gameSelectionTabBarController = [[UITabBarController alloc] init];
    self.gameSelectionTabBarController.delegate = self;
    
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
    
    
	//Logout View
	LogoutViewController *alogoutViewController = [[[LogoutViewController alloc] initWithNibName:@"Logout" bundle:nil] autorelease];
	UINavigationController *alogoutNavigationController = [[UINavigationController alloc] initWithRootViewController: alogoutViewController];
	alogoutNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    
    self.gameSelectionTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                          gamePickerNearbyNC,
                                                          gamePickerMapNC,
                                                          gamePickerSearchNC,
                                                          gamePickerRecentNC,
                                                          alogoutNavigationController,
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

}

-(void)showNotifications{
    
    NSLog(@"AppDelegate: showNotifications");
    
    if([self.notifArray count]>0){
        NSLog(@"AppDelegate: showNotifications: We have something to display");
        if(!isShowingNotification){//lower frame into position if its not already there
            isShowingNotification = YES;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.5];
            NSLog(@"AppDelegate: showNotifications: Begin Resizing");
            NSLog(@"TabBC frame BEFORE origin: %f tabShowY %d",self.tabBarController.view.frame.origin.y,tabShowY);
            if(self.tabBarController.modalViewController){
                self.tabBarController.modalViewController.view.frame = CGRectMake(self.tabBarController.modalViewController.view.frame.origin.x,40+[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y-20, self.tabBarController.modalViewController.view.frame.size.width, 440-[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+20); 
            }
           
        self.tabBarController.view.frame = CGRectMake(self.tabBarController.view.frame.origin.x,40+[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y-tabShowY, self.tabBarController.view.frame.size.width, 440-[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+tabShowY); 
            [self.titleLabel setFrame:CGRectMake(0,[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y, 320, 20)];
            [self.descLabel setFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y +20, 320, 15)];
        [UIView commitAnimations];
        }
        NSLog(@"TabBC frame AFTER origin: %f tabShowY %d",self.tabBarController.view.frame.origin.y,tabShowY);
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
    
    if(!tabBarController.view.hidden){
    [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
        if(isShowingNotification){
            if(self.tabBarController.modalViewController){
                self.tabBarController.modalViewController.view.frame = CGRectMake(self.tabBarController.modalViewController.view.frame.origin.x, [UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y-20, self.tabBarController.modalViewController.view.frame.size.width, 480-[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+20);             }
            
        self.tabBarController.view.frame = CGRectMake(self.tabBarController.view.frame.origin.x, [UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y-tabShowY, self.tabBarController.view.frame.size.width, 480-[UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+tabShowY); 
            
        [self.titleLabel setFrame:CGRectMake(0, -20, 320, 20)];
        [self.descLabel setFrame:CGRectMake(0, -20, 320, 15)];
        }
    }completion:^(BOOL finished){
        isShowingNotification = NO;
    }];
    }
    
    
}

/*- (void)displayNotificationTitle:(NSMutableDictionary *) titleAndPrompt{
    self.notificationCount++;
    
    
    float secBetweenStages = 1;
    float totalTime = secBetweenStages*5;
    
    NSMutableDictionary *navBarTitlePromptAndColorDict;
    
    UINavigationController *tempNC;
    
    int x = 0;
    
    //Loop through every viewController and display the notification 
    while (x <= [self.tabBarController.viewControllers count]) {
        
        //Do a little trick where we actually loop through one time more than the number of VCs so we can pickup any modals
        if (x < [self.tabBarController.viewControllers count]) tempNC = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:x];  
        else if (self.tabBarController.modalViewController){
            tempNC = (UINavigationController *)self.tabBarController.modalViewController;
            self.modalPresent = YES;
        }
        else {
            x++;
            continue;
        }
        
        //Check if this VC will crash out script (like the bogusVC we use to go back to the game selection)
        if (![tempNC respondsToSelector: @selector(topViewController)]) {
            x++;
            continue;
        }

       
        NSString *title = [titleAndPrompt objectForKey:@"title"];
        NSString *prompt = [titleAndPrompt objectForKey:@"prompt"];
        
        NSString *origTitle = [[tempNC.topViewController.navigationItem.title copy] retain];

        navBarTitlePromptAndColorDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",prompt,@"prompt",[UIColor grayColor],@"color", tempNC,@"navbar", nil];        
                       
        //tempNC.topViewController.title = @"Quest was Completed!";
        [self performSelector:@selector(changeNavTitle:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease]  
                   afterDelay:(0*secBetweenStages+totalTime*(self.notificationCount-1))];
        [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] 
                   afterDelay:(0*secBetweenStages+totalTime*(self.notificationCount-1))];
        
        [navBarTitlePromptAndColorDict setValue:[UIColor lightGrayColor] forKey:@"color"];    
        [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] 
                   afterDelay:(1*secBetweenStages+totalTime*(self.notificationCount-1))];
        
        [navBarTitlePromptAndColorDict setValue:[UIColor grayColor] forKey:@"color"];    
        [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] 
                   afterDelay:(2*secBetweenStages+totalTime*(self.notificationCount-1))];
        
        [navBarTitlePromptAndColorDict setValue:[UIColor lightGrayColor] forKey:@"color"];
        [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] 
                   afterDelay:(3*secBetweenStages+totalTime*(self.notificationCount-1))];
        
        [navBarTitlePromptAndColorDict setValue:[UIColor grayColor] forKey:@"color"];    
        [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] 
                   afterDelay:(4*secBetweenStages+totalTime*(self.notificationCount-1))];
        
        [navBarTitlePromptAndColorDict setValue:[UIColor blackColor] forKey:@"color"];
        [self performSelector:@selector(changeNavColor:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] 
                   afterDelay:(5*secBetweenStages+totalTime*(self.notificationCount-1))];
        
        [navBarTitlePromptAndColorDict setValue:origTitle forKey:@"title"];
        [navBarTitlePromptAndColorDict setValue:nil forKey:@"prompt"];
        [self performSelector:@selector(changeNavTitle:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] 
                   afterDelay:(5*secBetweenStages+totalTime*(self.notificationCount-1))];
        [origTitle release];

        x++;
    }
   
    [self performSelector:@selector(decrementNotificationCount:) withObject:[[navBarTitlePromptAndColorDict copy] autorelease] 
               afterDelay:(5*secBetweenStages+totalTime*(self.notificationCount-1))];
    
} 

- (void) changeNavColor: (NSDictionary *) navBarAndColorDict {
    UIColor *color = [navBarAndColorDict objectForKey:@"color"];
    [UIView beginAnimations:@"changeNavColor" context:nil];
    [UIView setAnimationDuration:0.5];
    self.titleLabel.backgroundColor = color;
    self.descLabel.backgroundColor = color;
    
    [UIView commitAnimations];
}

-(void) decrementNotificationCount: (NSDictionary *) navBarDict {
    self.notificationCount--;
    
}
*/
/*
-(void) changeNavTitle: (NSDictionary *) navBarTitleAndPromptDict {
    UINavigationController *tempNC = [navBarTitleAndPromptDict objectForKey:@"navbar"];

    
    //tempNC.topViewController.navigationItem.title = [navBarTitleAndPromptDict objectForKey:@"title"];
    if ([navBarTitleAndPromptDict objectForKey:@"prompt"])
    {
        [UIView beginAnimations:@"changeNotificationTitle" context:nil];
        [UIView setAnimationDuration:0.5];
        self.titleLabel.hidden = NO;
        self.descLabel.hidden = NO;
        tempNC.topViewController.navigationItem.prompt = @" ";
        self.titleLabel.text = [navBarTitleAndPromptDict objectForKey:@"title"];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [tempNC.topViewController.navigationController.navigationBar.window performSelector:@selector(addSubview:) withObject:self.titleLabel afterDelay:.6];
        
        self.descLabel.text = [navBarTitleAndPromptDict objectForKey:@"prompt"];
        self.descLabel.font = [UIFont systemFontOfSize:14];
        self.descLabel.textAlignment = UITextAlignmentCenter;
        self.descLabel.textColor = [UIColor whiteColor];
        self.descLabel.backgroundColor = [UIColor clearColor];
        [tempNC.topViewController.navigationController.navigationBar.window performSelector:@selector(addSubview:) withObject:self.descLabel afterDelay:.6];
        [UIView commitAnimations];
    }
    else
    {
        if(self.notificationCount <= 1)
        tempNC.topViewController.navigationItem.prompt = nil;
        [self.titleLabel removeFromSuperview];
        [self.descLabel removeFromSuperview];

    }
    */
    //Code below just disables the buttons when a notification is up
    /*
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
    */
   
//}


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
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];
		}
	}
	
}

- (void) showGameSelectionTabBarAndHideOthers {
    
    //Put it onscreen
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
    self.tabBarController.view.hidden = YES;
    self.gameSelectionTabBarController.view.hidden = NO;
    self.loginViewNavigationController.view.hidden = YES;
    [UIView commitAnimations];
    
    
    [self returnToHomeView];

}

- (void)selectGame:(NSNotification *)notification {
    //NSDictionary *loginObject = [notification object];
	NSDictionary *userInfo = notification.userInfo;
	Game *selectedGame = [userInfo objectForKey:@"game"];
    
	NSLog(@"AppDelegate: Game Selected. '%@' game was selected", selectedGame.name);
	

    //Put it onscreen
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
    self.tabBarController.view.hidden = NO;
    self.gameSelectionTabBarController.view.hidden = YES;
    self.loginViewNavigationController.view.hidden = YES;
    [UIView commitAnimations];
    
    
    
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
    
    //Display the intro node
    if ([AppModel sharedAppModel].currentGame.completedQuests < 1) [self displayIntroNode];
    	
}

-(void)changeTabBar{
    UINavigationController *tempNav = [[UINavigationController alloc] init];
    NSArray *newCustomVC = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *newTabList = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *tmpTabList = [[NSMutableArray alloc] initWithCapacity:11];

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"tabIndex"
                                                  ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    tmpTabList = [[AppModel sharedAppModel].gameTabList sortedArrayUsingDescriptors:sortDescriptors];
    Tab *tmpTab = [[Tab alloc] init];
    for(int y = 0; y < [tmpTabList count];y++){
        tmpTab = [tmpTabList objectAtIndex:y];
                if ([tmpTab.tabName isEqualToString:@"QUESTS"]) tmpTab.tabName = @"Quests";
                else if([tmpTab.tabName isEqualToString:@"GPS"]) tmpTab.tabName = @"Map";
                else if([tmpTab.tabName isEqualToString:@"INVENTORY"]) tmpTab.tabName = @"Inventory";
                else if([tmpTab.tabName isEqualToString:@"QR"]) tmpTab.tabName = @"Decoder";
                else if([tmpTab.tabName isEqualToString:@"PLAYER"]) tmpTab.tabName = @"Attributes";
                //else if([tmpTab.tabName isEqualToString:@"CAMERA"]) tmpTab.tabName = @"Camera";
               // else if([tmpTab.tabName isEqualToString:@"MICROPHONE"]) tmpTab.tabName = @"Recorder";
                else if([tmpTab.tabName isEqualToString:@"NOTE"]) tmpTab.tabName = @"Notebook";
                else if([tmpTab.tabName isEqualToString:@"LOGOUT"]) tmpTab.tabName = @"Logout";
                else if([tmpTab.tabName isEqualToString:@"STARTOVER"]) tmpTab.tabName = @"Start Over";
                else if([tmpTab.tabName isEqualToString:@"PICKGAME"]) tmpTab.tabName = @"Select Game";
        if(tmpTab.tabIndex != 0) {
            
        newTabList = [newTabList arrayByAddingObject:tmpTab];
        }
    }
    for(int y = 0; y < [newTabList count];y++){
        tmpTab = [newTabList objectAtIndex:y];
    for(int x = 0; x < [[AppModel sharedAppModel].defaultGameTabList count];x++){
        
        tempNav = (UINavigationController *)[[AppModel sharedAppModel].defaultGameTabList objectAtIndex:x];
        if([tmpTab.tabName isEqualToString:@"Select Game"]){
            BogusSelectGameViewController *bogusSelectGameViewController = [[BogusSelectGameViewController alloc] init];
            newCustomVC = [newCustomVC arrayByAddingObject:bogusSelectGameViewController];
            //[bogusSelectGameViewController release];
            break;
        }

        if([tempNav.navigationItem.title isEqualToString:tmpTab.tabName]) newCustomVC = [newCustomVC arrayByAddingObject:tempNav];
            }
    }

    self.tabBarController.viewControllers = [NSArray arrayWithArray: newCustomVC];
    //[newCustomVC release];
    //[newTabList release];
    //[tmpTabList release];
   // [tempNav release];

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



- (void)applicationDidBecomeActive:(UIApplication *)application{
	NSLog(@"AppDelegate: applicationDidBecomeActive");
	[[AppModel sharedAppModel] loadUserDefaults];
    [[AppServices sharedAppServices]setShowPlayerOnMap];

}

- (void) resetCurrentlyFetchingVars{
    [AppServices sharedAppServices].currentlyFetchingGamesList = NO;
    [AppServices sharedAppServices].currentlyFetchingInventory = NO;
    [AppServices sharedAppServices].currentlyFetchingLocationList = NO;
    [AppServices sharedAppServices].currentlyFetchingQuestList = NO;
    [AppServices sharedAppServices].currentlyUpdatingServerWithInventoryViewed = NO;
    [AppServices sharedAppServices].currentlyUpdatingServerWithMapViewed = NO;
    [AppServices sharedAppServices].currentlyUpdatingServerWithPlayerLocation = NO;
    [AppServices sharedAppServices].currentlyUpdatingServerWithQuestsViewed = NO;
}

- (void) showServerAlertWithEmail:(NSString *)title message:(NSString *)message details:(NSString*)detail{
	errorMessage = message;
    errorDetail = detail;

	if (!self.serverAlert){
		self.serverAlert = [[UIAlertView alloc] initWithTitle:title
														message:@"You may need to login to your Wifi connection from Safari. \nYou also may need to verify ARIS server settings in system preferences. \nIf the problem persists, please send us some debugging information"
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
	NSLog (@"AppDelegate: Showing Waiting Indicator With Message:%@",message);
	//if (self.waitingIndicatorView) [self.waitingIndicatorView dismiss];
	
    if (self.waitingIndicatorView){ 
        [self removeNewWaitingIndicator];
        [self.waitingIndicatorView release];}
	
	self.waitingIndicatorView = [[WaitingIndicatorView alloc] initWithWaitingMessage:message showProgressBar:NO];
        [self.waitingIndicatorView show];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the activity indicator show before returning	
}

- (void) removeNewWaitingIndicator {
	NSLog (@"AppDelegate: Removing Waiting Indicator");
	if (self.waitingIndicatorView != nil) [self.waitingIndicatorView dismiss];
    self.waitingIndicatorView = nil;
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
    if([AppModel sharedAppModel].tabsReady){
        [AppModel sharedAppModel].tabsReady = NO;
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



- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate{
	NSLog(@"AppDelegate: Playing an audio Alert sound");
	
	//Vibrate
	if (shouldVibrate == YES) [NSThread detachNewThreadSelector:@selector(vibrate) toTarget:self withObject:nil];	
	//Play the sound on a background thread
	[NSThread detachNewThreadSelector:@selector(playAudio:) toTarget:self withObject:wavFileName];
}

//Play a sound
- (void) playAudio:(NSString*)wavFileName {

	NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:wavFileName ofType:@"wav"]];
    NSLog(@"Appdelegate: Playing Audio: %@", url);
    NSError* err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL: url error:&err];
    
    if( err ){
        NSLog(@"Appdelegate: Playing Audio: Failed with reason: %@", [err localizedDescription]);
    }
    else{
        [player play];
    }
}

//Vibrate
- (void) vibrate {
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);  
}

- (void)newError: (NSString *)text {
	NSLog(@"%@", text);
}

- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController {
	
	self.nearbyObjectNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyObjectViewController];
	self.nearbyObjectNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		
	//Display

    [self.tabBarController presentModalViewController:self.nearbyObjectNavigationController animated:NO];
    [nearbyObjectNavigationController release];
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

    if(isShowingNotification){
        tabShowY = 0;

        self.tabBarController.view.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+[UIApplication sharedApplication].statusBarFrame.origin.y+40, 320, 420);
    }
}


#pragma mark Memory Management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"AppDelegate: LOW MEMORY WARNING RECIEVED");
    
    [[AppServices sharedAppServices]fetchGameMediaListAsynchronously:YES];
   /* 
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low Memory Warning"
                                                    message:@"The device you are using does not currently have enough free memory to reliably run ARIS. Please close out of some of the other running programs and restart ARIS"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];	
    [alert release];*/
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tabBarController release];
    [window release];
    [tabBarController release];
    [gameSelectionTabBarController release];
    [defaultViewControllerForMainTabBar release];
    [loginViewController release];
    [loginViewNavigationController release];
    [nearbyObjectsNavigationController release];
    [nearbyObjectNavigationController release];
    [waitingIndicator release];
    [waitingIndicatorView release];
    [networkAlert release];
    [serverAlert release];
    [tutorialViewController release];
    [titleLabel release];
    [descLabel release];
	[super dealloc];
}
@end


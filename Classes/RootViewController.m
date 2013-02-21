//
//  RootViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "AppServices.h"

#import "LoginViewController.h"
#import "PlayerSettingsViewController.h"
#import "GameNotificationViewController.h"

#import "GameDetailsViewController.h"
#import "webpageViewController.h"
#import "NoteDetailsViewController.h"

//Game Picker Tab VCs
#import "GamePickerNearbyViewController.h"
#import "GamePickerSearchViewController.h"
#import "GamePickerPopularViewController.h"
#import "GamePickerRecentViewController.h"
#import "AccountSettingsViewController.h"

//Game Play Tab VCs
#import "QuestsViewController.h"
#import "IconQuestsViewController.h"
#import "InventoryListViewController.h"
#import "GPSViewController.h"
#import "AttributesViewController.h"
#import "NotebookViewController.h"
#import "DecoderViewController.h"
#import "BogusSelectGameViewController.h"
#import "NearbyObjectsViewController.h"

#import "Node.h"

GameNotificationViewController *gameNotificationViewController;

NSString *errorMessage;
NSString *errorDetail;

@implementation RootViewController

@synthesize tutorialViewController;
@synthesize loginNavigationController;
@synthesize gameSelectionTabBarController;
@synthesize gamePlayTabBarController;
@synthesize playerSettingsNavigationController;
@synthesize nearbyObjectsNavigationController;
@synthesize nearbyObjectNavigationController;
@synthesize loadingViewController;
@synthesize waitingIndicatorAlertViewController;
@synthesize networkAlert;
@synthesize serverAlert;
@synthesize pusherClient;
//@synthesize playerChannel;
//@synthesize groupChannel;
@synthesize gameChannel;
//@synthesize webpageChannel;
@synthesize usesIconQuestView;

+ (id)sharedRootViewController
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return _sharedObject;
}

- (void) initViewControllers //For non-tab-bar vc's
{
    //Login View Controller
    LoginViewController* loginViewController = [[LoginViewController alloc] initWithNibName:@"Login" bundle:nil];
    self.loginNavigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    self.loginNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.loginNavigationController.view.frame = self.view.frame;
    [self.view addSubview:self.loginNavigationController.view];
    
    //Player Settings View Controller
    PlayerSettingsViewController *playerSettingsViewController = [[PlayerSettingsViewController alloc] initWithNibName:@"PlayerSettingsViewController" bundle:nil];
    self.playerSettingsNavigationController = [[UINavigationController alloc] initWithRootViewController: playerSettingsViewController];
    self.playerSettingsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self.playerSettingsNavigationController.view setFrame:UIScreen.mainScreen.applicationFrame];
    self.playerSettingsNavigationController.view.frame = self.view.frame;
    self.playerSettingsNavigationController.view.hidden = YES;
    [self.view addSubview:self.playerSettingsNavigationController.view];
    
    //Tutorial View Controller
    tutorialViewController = [[TutorialViewController alloc] init];
    tutorialViewController.view.frame = self.gamePlayTabBarController.view.frame;
    tutorialViewController.view.hidden = YES;
    tutorialViewController.view.userInteractionEnabled = NO;
    [self.gamePlayTabBarController.view addSubview:tutorialViewController.view];
    
    self.waitingIndicatorAlertViewController = [[WaitingIndicatorAlertViewController alloc] init];
    
    gameNotificationViewController = [[GameNotificationViewController alloc] initWithNibName:nil bundle:nil];
    [self.view addSubview:gameNotificationViewController.view];
}

- (void) initGamePickerTabs
{
    //Nearby Games
    GamePickerNearbyViewController *gamePickerNearbyViewController = [[GamePickerNearbyViewController alloc] initWithNibName:@"GamePickerNearbyViewController" bundle:nil];
    UINavigationController *gamePickerNearbyNC = [[UINavigationController alloc] initWithRootViewController: gamePickerNearbyViewController];
    gamePickerNearbyNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Search Games
    GamePickerSearchViewController *gamePickerSearchVC = [[GamePickerSearchViewController alloc]initWithNibName:@"GamePickerSearchViewController" bundle:nil];
    UINavigationController *gamePickerSearchNC = [[UINavigationController alloc] initWithRootViewController:gamePickerSearchVC];
    gamePickerSearchNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Popular Games
    GamePickerPopularViewController *gamePickerPopularVC = [[GamePickerPopularViewController alloc]initWithNibName:@"GamePickerPopularViewController" bundle:nil];
    UINavigationController *gamePickerPopularNC = [[UINavigationController alloc] initWithRootViewController:gamePickerPopularVC];
    gamePickerPopularNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Recent Games
    GamePickerRecentViewController *gamePickerRecentVC = [[GamePickerRecentViewController alloc]initWithNibName:@"GamePickerRecentViewController" bundle:nil];
    UINavigationController *gamePickerRecentNC = [[UINavigationController alloc] initWithRootViewController:gamePickerRecentVC];
    gamePickerRecentNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Account Settings
    AccountSettingsViewController *accountSettingsViewController = [[AccountSettingsViewController alloc] initWithNibName:@"Account" bundle:nil];
    UINavigationController *accountSettingsNC = [[UINavigationController alloc] initWithRootViewController:accountSettingsViewController];
    accountSettingsNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Setup the Game Selection Tab Bar
    self.gameSelectionTabBarController = [[UITabBarController alloc] init];
    self.gameSelectionTabBarController.delegate = self;
    
    self.gameSelectionTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                          gamePickerNearbyNC,
                                                          gamePickerSearchNC,
                                                          gamePickerPopularNC,
                                                          gamePickerRecentNC,
                                                          accountSettingsNC,
                                                          nil];
    [self.view addSubview:self.gameSelectionTabBarController.view];
}

- (void) initGamePlayTabs
{
    //Setup NearbyObjects View
    NearbyObjectsViewController *nearbyObjectsViewController = [[NearbyObjectsViewController alloc]initWithNibName:@"NearbyObjectsViewController" bundle:nil];
    self.nearbyObjectsNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyObjectsViewController];
    self.nearbyObjectsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Setup ARView
    //ARViewViewControler *arViewController = [[[ARViewViewControler alloc] initWithNibName:@"ARView" bundle:nil] autorelease];
    //UINavigationController *arNavigationController = [[UINavigationController alloc] initWithRootViewController: arViewController];
    //arNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Setup Quests View
    QuestsViewController *questsViewController = [[QuestsViewController alloc] initWithNibName:@"Quests" bundle:nil];
    UINavigationController *questsNavigationController = [[UINavigationController alloc] initWithRootViewController: questsViewController];
    questsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Setup Quests Icon View
    IconQuestsViewController *iconQuestsViewController = [[IconQuestsViewController alloc] initWithNibName:@"IconQuestsViewController" bundle:nil];
    UINavigationController *iconQuestsNavigationController = [[UINavigationController alloc] initWithRootViewController: iconQuestsViewController];
    iconQuestsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
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
    
    //Decoder View Controller
    DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithNibName:@"Decoder" bundle:nil];
    UINavigationController *decoderNavigationController = [[UINavigationController alloc] initWithRootViewController:decoderViewController];
    decoderNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Bogus Game Picker View
    BogusSelectGameViewController *bogusSelectGameViewController = [[BogusSelectGameViewController alloc] init];
    
    //Setup the Game Play Tab Bar
    self.gamePlayTabBarController = [[UITabBarController alloc] init];
    self.gamePlayTabBarController.delegate = self;
    
    self.gamePlayTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                     questsNavigationController,
                                                     iconQuestsNavigationController,
                                                     gpsNavigationController,
                                                     inventoryNavigationController,
                                                     attributesNavigationController,
                                                     decoderNavigationController,
                                                     notesNavigationController,
                                                     bogusSelectGameViewController,
                                                     nil];
    
    //More Tab
    UINavigationController *moreNavController = self.gamePlayTabBarController.moreNavigationController;
    moreNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    moreNavController.delegate = self;
    
    self.gamePlayTabBarController.view.hidden = YES;
    [self.view addSubview:self.gamePlayTabBarController.view];
    [AppModel sharedAppModel].defaultGameTabList = self.gamePlayTabBarController.customizableViewControllers;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if(self)
    {
        self.view.frame = frame;

        //Init VC's
        [self initGamePickerTabs];
        [self initGamePlayTabs];
        [self initViewControllers];

        //Setup Pusher Client
        self.pusherClient = [PTPusher pusherWithKey:@"79f6a265dbb7402a49c9" delegate:self encrypted:YES];
        self.pusherClient.authorizationURL = [NSURL URLWithString:@"http://dev.arisgames.org/server/events/auths/private_auth.php"];
        
        //Start Polling Location
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:[[MyCLController sharedMyCLController]locationManager] selector:@selector(startUpdatingLocation) userInfo:nil repeats:NO];
        
        //register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoginAttempt:)         name:@"NewLoginResponseReady"         object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterGameFromOutside:)       name:@"NewOneGameGameListReady"       object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectGame:)                 name:@"SelectGame"                    object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginGamePlay)               name:@"GameFinishedLoading"           object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPlayerSettings:)         name:@"ProfSettingsRequested"         object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performLogout:)              name:@"PassChangeRequested"           object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performLogout:)              name:@"LogoutRequested"               object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForDisplayCompleteNode) name:@"NewlyCompletedQuestsAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMediaList)           name:@"ReceivedMediaList"             object:nil];
        
        //Set up visibility of views at top of heirarchy
        [[AppModel sharedAppModel] loadUserDefaults];
        if([AppModel sharedAppModel].playerId == 0)
        {
            self.loginNavigationController.view.hidden     = NO;
            self.gamePlayTabBarController.view.hidden      = YES;
            self.gameSelectionTabBarController.view.hidden = YES;
        }
        else
        {
            [[AppServices sharedAppServices] setShowPlayerOnMap];
            [AppModel sharedAppModel].loggedIn = YES;
            self.gameSelectionTabBarController.view.hidden      = NO;
            self.loginNavigationController.view.hidden          = YES;
            self.gamePlayTabBarController.view.hidden           = YES;
            self.playerSettingsNavigationController.view.hidden = YES;
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait animated:NO];
}

#pragma mark Notifications, Warnings and Other Views

- (void) showGameSelectionTabBarAndHideOthers
{
    //Put it onscreen
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    self.gamePlayTabBarController.selectedIndex = 0;
    self.gamePlayTabBarController.view.hidden = YES;
    self.gameSelectionTabBarController.view.hidden = NO;
    self.loginNavigationController.view.hidden = YES;
    self.playerSettingsNavigationController.view.hidden = YES;
    [UIView commitAnimations];
    [AppModel sharedAppModel].fallbackGameId = 0;
    [[AppModel sharedAppModel] saveUserDefaults];
    
    [gameNotificationViewController stopListeningToModel];
    [gameNotificationViewController cutOffGameNotifications];
}

- (void) showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
    [alert show];
}

- (void) showServerAlertWithEmail:(NSString *)title message:(NSString *)message details:(NSString*)detail
{
	errorMessage = message;
    errorDetail = detail;
    
	if (!self.serverAlert)
    {
        UIAlertView *serverAlertAlloc = [[UIAlertView alloc] initWithTitle:title
                                                                   message:NSLocalizedString(@"ARISAppDelegateWIFIErrorMessageKey", @"")
                                                                  delegate:self cancelButtonTitle:NSLocalizedString(@"IgnoreKey", @"")
                                                         otherButtonTitles:NSLocalizedString(@"ReportKey", @""),nil];
		self.serverAlert = serverAlertAlloc;
		[self.serverAlert show];
 	}
	else
        NSLog(@"RootViewController: showServerAlertWithEmail was called, but a server alert was already present");
}

- (void) showNetworkAlert
{
	NSLog (@"RootViewController: Showing Network Alert");
	if (self.loadingViewController)
    {
        [self.loadingViewController dismissModalViewControllerAnimated:NO];
        [self gamePlayTabBarController].selectedIndex = 0;
        [self showGameSelectionTabBarAndHideOthers];
    }
	if (!self.networkAlert)
    {
		networkAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PoorConnectionTitleKey", @"")
                                                  message:NSLocalizedString(@"PoorConnectionMessageKey", @"")
												 delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
	}
	if (self.networkAlert.visible == NO) [networkAlert show];
}

- (void) removeNetworkAlert
{	
	if (self.networkAlert != nil)
		[self.networkAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) showWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar
{
    [self removeWaitingIndicator];
    
	[self.waitingIndicatorAlertViewController displayMessage:message withProgressBar:displayProgressBar];
}

- (void) removeWaitingIndicator
{
    [self.waitingIndicatorAlertViewController dismissMessage];
}

- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController
{
    [AppModel sharedAppModel].currentlyInteractingWithObject = YES;
	self.nearbyObjectNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyObjectViewController];
	self.nearbyObjectNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.nearbyObjectNavigationController.view.frame = gamePlayTabBarController.view.bounds;
    [self.gamePlayTabBarController.view addSubview: self.nearbyObjectNavigationController.view];
}

- (void)dismissNearbyObjectView:(UIViewController *)nearbyObjectViewController
{
    [AppModel sharedAppModel].currentlyInteractingWithObject = NO;
    [nearbyObjectViewController.view removeFromSuperview];
    [self.nearbyObjectNavigationController.view removeFromSuperview];
    [[AppServices sharedAppServices] fetchAllPlayerLists];
}

- (void) beginGamePlay
{
    NSLog(@"RootViewController: beginGamePlay");
    
    [gameNotificationViewController startListeningToModel];

    int nodeId = [AppModel sharedAppModel].currentGame.launchNodeId;
    if (nodeId && nodeId != 0)
        [[[AppModel sharedAppModel] nodeForNodeId:nodeId] display];
    else
        [AppModel sharedAppModel].currentlyInteractingWithObject = NO;
}

- (void) checkForDisplayCompleteNode
{
    int nodeId = [AppModel sharedAppModel].currentGame.completeNodeId;
    if (nodeId != 0 &&
        [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] == [AppModel sharedAppModel].currentGame.questsModel.totalQuestsInGame &&
        [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] > 0)
    {
        NSLog(@"RootViewController: checkForIntroOrCompleteNodeDisplay: Displaying Complete Node");
		[[[AppModel sharedAppModel] nodeForNodeId:nodeId] display];
	}
}

- (void) showNearbyTab:(BOOL)showTab
{
    if([AppModel sharedAppModel].tabsReady)
    {
        NSMutableArray *tabs = [NSMutableArray arrayWithArray:self.gamePlayTabBarController.viewControllers];
        
        if(showTab)
        {
            NSLog(@"RootViewController: showNearbyTab: YES");
            if (![tabs containsObject:self.nearbyObjectsNavigationController])
                [tabs insertObject:self.nearbyObjectsNavigationController atIndex:0];
        }
        else
        {
            NSLog(@"RootViewController: showNearbyTab: NO");
            if ([tabs containsObject:self.nearbyObjectsNavigationController])
            {
                [tabs removeObject:self.nearbyObjectsNavigationController];
                //Hide any popups
                UIViewController *vc = [self.nearbyObjectsNavigationController performSelector:@selector(visibleViewController)];
                if ([vc respondsToSelector:@selector(dismissTutorial)])
                    [vc performSelector:@selector(dismissTutorial)];
            }
        }
        
        [self.gamePlayTabBarController setViewControllers:tabs animated:NO];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TabBarItemsChanged" object:self userInfo:nil]];
    }
}

#pragma mark Login and Game Selection
- (void)createUserAndLoginWithGroup:(NSString *)groupName andGameId:(int)gameId inMuseumMode:(BOOL)museumMode
{
    NSLog(@"RootViewController: Attempt Create User for: %@", groupName);
	[AppModel sharedAppModel].museumMode = museumMode;
    
    [self showWaitingIndicator:@"Creating User And Logging In..." displayProgressBar:NO];
	[[AppServices sharedAppServices] createUserAndLoginWithGroup:[NSString stringWithFormat:@"%d-%@", gameId, groupName]];
    
    if(gameId != 0)
    {
        [[AppServices sharedAppServices] fetchOneGameGameList:gameId];
    }
}

- (void)attemptLoginWithUserName:(NSString *)userName andPassword:(NSString *)password andGameId:(int)gameId inMuseumMode:(BOOL)museumMode
{
	NSLog(@"RootViewController: Attempt Login for: %@ Password: %@", userName, password);
	[AppModel sharedAppModel].userName = userName;
	[AppModel sharedAppModel].password = password;
	[AppModel sharedAppModel].museumMode = museumMode;
    
    [self showWaitingIndicator:@"Logging In..." displayProgressBar:NO];
	[[AppServices sharedAppServices] login];
    
    if(gameId != 0)
    {
        [[AppServices sharedAppServices] fetchOneGameGameList:gameId];
    }
}

- (void) showPlayerSettings:(NSNotification *)notification
{
    [(PlayerSettingsViewController *)self.playerSettingsNavigationController.topViewController refreshViewFromModel];
    self.playerSettingsNavigationController.view.hidden = NO;
    [(PlayerSettingsViewController *)self.playerSettingsNavigationController.topViewController manuallyForceViewDidAppear];
    self.gameSelectionTabBarController.view.hidden = NO;
    self.gameSelectionTabBarController.selectedIndex = 0;
}

- (void)finishLoginAttempt:(NSNotification *)notification
{
	NSLog(@"RootViewController: Finishing Login Attempt");
    
	//handle login response
	if([AppModel sharedAppModel].loggedIn)
    {
		NSLog(@"RootViewController: Login Success");
        
        self.gamePlayTabBarController.view.hidden = YES;
        self.loginNavigationController.view.hidden = YES;
        if([AppModel sharedAppModel].museumMode)
        {
            [self showPlayerSettings:nil];
            if([AppModel sharedAppModel].playerMediaId == 0 || [AppModel sharedAppModel].playerMediaId == -1)
                [(PlayerSettingsViewController *) self.playerSettingsNavigationController.topViewController playerPicCamButtonTouched:nil];
        }
        else
        {
            self.playerSettingsNavigationController.view.hidden = YES;
            self.gameSelectionTabBarController.view.hidden = NO;
            self.gameSelectionTabBarController.selectedIndex = 0;
        }
    }
    else
    {
		NSLog(@"RootViewController: Login Failed, check for a network issue");
		if (self.networkAlert)
            NSLog(@"RootViewController: Network is down, skip login alert");
		else
        {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginErrorTitleKey",@"")
                                                            message:NSLocalizedString(@"LoginErrorMessageKey",@"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
                                                  otherButtonTitles:nil];
			[alert show];
		}
	}
}

- (void)selectGame:(NSNotification *)notification
{
	[self loadAndPlayGame:[notification.userInfo objectForKey:@"game"]];
}

-(void)loadAndPlayGame:(Game *)game
{    
	NSLog(@"RootViewController: Playing Game: '%@'", game.name);
    [AppModel sharedAppModel].currentlyInteractingWithObject = NO;

    loadingViewController = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    loadingViewController.progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
    
    [self.gamePlayTabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
    [self.gamePlayTabBarController presentModalViewController:self.loadingViewController animated:NO];
    
    self.gamePlayTabBarController.view.hidden           = NO;
    self.gameSelectionTabBarController.view.hidden      = YES;
    self.loginNavigationController.view.hidden          = YES;
    self.playerSettingsNavigationController.view.hidden = YES;
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the keyboard go away before loading the object
    
	//Clear out the old game data
    if(self.gameChannel)    [pusherClient unsubscribeFromChannel:(PTPusherChannel *)self.gameChannel];
    //if(self.groupChannel)   [client unsubscribeFromChannel:(PTPusherChannel *)self.groupChannel];
    //if(self.webpageChannel) [client unsubscribeFromChannel:(PTPusherChannel *)self.webpageChannel];
    
    [[AppServices sharedAppServices] fetchTabBarItemsForGame:game.gameId];
	[[AppServices sharedAppServices] resetAllPlayerLists];
    [[AppServices sharedAppServices] resetAllGameLists];
    [[AppServices sharedAppServices] resetCurrentlyFetchingVars];
	[tutorialViewController dismissAllTutorials];
    
	//Set the model to this game
	[AppModel sharedAppModel].currentGame = game;
    [AppModel sharedAppModel].fallbackGameId = game.gameId;
	[[AppModel sharedAppModel] saveUserDefaults];
    [game getReadyToPlay];
	
    [[AppServices sharedAppServices] fetchAllGameLists];

	[[AppServices sharedAppServices] updateServerGameSelected];
    
    [AppModel sharedAppModel].hasReceivedMediaList = NO;
    
    //playerChannel = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-player-channel",[AppModel sharedAppModel].playerId]];
    //groupChannel  = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%@-group-channel",@"group"]];
    gameChannel   = [self.pusherClient subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-game-channel",[AppModel sharedAppModel].currentGame.gameId]];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(didReceivePlayerChannelEventNotification:)
    //                                             name:PTPusherEventReceivedNotification
    //                                           object:playerChannel];
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(didReceiveGroupChannelEventNotification:)
    //                                             name:PTPusherEventReceivedNotification
    //                                           object:groupChannel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveGameChannelEventNotification:)
                                                 name:PTPusherEventReceivedNotification
                                               object:gameChannel];
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(didReceiveWebpageChannelEventNotification:)
    //                                             name:PTPusherEventReceivedNotification
    //                                          object:webpageChannel];
    
}

-(void)changeTabBar //What the heck does 'changeTabBar' mean?
{
    UINavigationController *tempNav = [[UINavigationController alloc] init];
    NSArray *newCustomVC = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *newTabList = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *tmpTabList = [[NSMutableArray alloc] initWithCapacity:11];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tabIndex"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    //Boolean isIconQuestsView = YES;
    
    tmpTabList = [[AppModel sharedAppModel].gameTabList sortedArrayUsingDescriptors:sortDescriptors];
    Tab *tmpTab = [[Tab alloc] init];
    for(int y = 0; y < [tmpTabList count];y++)
    {
        tmpTab = [tmpTabList objectAtIndex:y];
        if ([tmpTab.tabName isEqualToString:@"QUESTS"])
        {
            tmpTab.tabName = NSLocalizedString(@"QuestViewTitleKey",@"");
            usesIconQuestView = (BOOL)tmpTab.tabDetail1;
        }
        else if([tmpTab.tabName isEqualToString:@"GPS"])       tmpTab.tabName = NSLocalizedString(@"MapViewTitleKey",@"");
        else if([tmpTab.tabName isEqualToString:@"INVENTORY"]) tmpTab.tabName = NSLocalizedString(@"InventoryViewTitleKey",@"");
        else if([tmpTab.tabName isEqualToString:@"QR"])        tmpTab.tabName = NSLocalizedString(@"QRScannerTitleKey",@"");
        else if([tmpTab.tabName isEqualToString:@"PLAYER"])    tmpTab.tabName = NSLocalizedString(@"PlayerTitleKey",@"");
        else if([tmpTab.tabName isEqualToString:@"NOTE"])      tmpTab.tabName = NSLocalizedString(@"NotebookTitleKey",@"");
        else if([tmpTab.tabName isEqualToString:@"PICKGAME"])  tmpTab.tabName = NSLocalizedString(@"GamePickerTitleKey",@"");
        else tmpTab.tabIndex = 0;
        
        if(tmpTab.tabIndex != 0 && !([AppModel sharedAppModel].museumMode && [tmpTab.tabName isEqualToString:NSLocalizedString(@"GamePickerTitleKey", @"")]))
            newTabList = [newTabList arrayByAddingObject:tmpTab];
    }
    
    for(int y = 0; y < [newTabList count]; y++)
    {
        tmpTab = [newTabList objectAtIndex:y];
        if([tmpTab.tabName isEqualToString:NSLocalizedString(@"QuestViewTitleKey",@"")])
        {
            if(usesIconQuestView)tempNav = (UINavigationController *)[[AppModel sharedAppModel].defaultGameTabList objectAtIndex:8];
            else tempNav = (UINavigationController *)[[AppModel sharedAppModel].defaultGameTabList objectAtIndex:0];
            newCustomVC = [newCustomVC arrayByAddingObject:tempNav];
        }
        else
        {
            for(int x = 0; x < [[AppModel sharedAppModel].defaultGameTabList count]; x++)
            {
                tempNav = (UINavigationController *)[[AppModel sharedAppModel].defaultGameTabList objectAtIndex:x];
                if([tempNav.navigationItem.title isEqualToString:tmpTab.tabName])newCustomVC = [newCustomVC arrayByAddingObject:tempNav];
            }
        }
    }
    
    self.gamePlayTabBarController.viewControllers = [NSArray arrayWithArray: newCustomVC];
    [AppModel sharedAppModel].tabsReady = YES;
}

- (void)performLogout:(NSNotification *)notification
{
    NSLog(@"Performing Logout: Clearing NSUserDefaults and Displaying Login Screen");
	
    //if(playerChannel) [client unsubscribeFromChannel:(PTPusherChannel *)playerChannel];
    if(gameChannel) [pusherClient unsubscribeFromChannel:(PTPusherChannel *)gameChannel];
    //if(groupChannel) [client unsubscribeFromChannel:(PTPusherChannel *)groupChannel];
    //if(webpageChannel) [client unsubscribeFromChannel:(PTPusherChannel *)webpageChannel];
    
	//Clear any user realated info in AppModel (except server)
	[[AppModel sharedAppModel] clearUserDefaults];
	
	//clear the tutorial popups
	[tutorialViewController dismissAllTutorials];
	
	//(re)load the login view
	self.gamePlayTabBarController.view.hidden = YES;
    self.gameSelectionTabBarController.view.hidden = YES;
    self.playerSettingsNavigationController.view.hidden = YES;
    self.loginNavigationController.view.hidden = NO;
    
    [gameNotificationViewController stopListeningToModel];
    [gameNotificationViewController cutOffGameNotifications];
}

-(void)receivedMediaList
{
    //Display the intro node
    [AppModel sharedAppModel].hasReceivedMediaList = YES;
}

- (void)newError: (NSString *)text
{
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
    
    if ([strPath isEqualToString:@"games"] || [strPath isEqualToString:@"game"])
    {
        NSString *gameID = [url lastPathComponent];
        NSLog(@"gameID=: %@",gameID);
        
        [[AppServices sharedAppServices] fetchOneGameGameList:[gameID intValue]];
    }
    return YES;
}

- (void) enterGameFromOutside:(NSNotification *)notification
{
    NSLog(@"game opened");
    Game *game = [notification.userInfo objectForKey:@"game"];
        
    //Configure view heirarchy to right before gameplay
    self.gamePlayTabBarController.view.hidden = YES;
    self.loginNavigationController.view.hidden = YES;
    
    if([AppModel sharedAppModel].museumMode)
    {
        self.playerSettingsNavigationController.view.hidden = NO;
        [(PlayerSettingsViewController *) self.playerSettingsNavigationController.topViewController manuallyForceViewDidAppear];
    }
    else
    {
        self.playerSettingsNavigationController.view.hidden = YES;
    }

    // Push Game Detail View Controller
    GameDetailsViewController *gameDetailsViewController = [[GameDetailsViewController alloc] initWithNibName:@"GameDetails" bundle:nil];
    gameDetailsViewController.game = game;
    self.gameSelectionTabBarController.selectedIndex = 3; //recent (so when they go back, they'll see the game they just left)
    self.gameSelectionTabBarController.view.hidden = NO;
    [(UINavigationController*)self.gameSelectionTabBarController.selectedViewController pushViewController:gameDetailsViewController animated:YES];
    [self.navigationController pushViewController:gameDetailsViewController animated:YES];
}

#pragma mark AlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//Since only the server error alert with email ever uses this, we know who we are dealing with
	NSLog(@"RootViewController: AlertView clickedButtonAtIndex: %d",buttonIndex);
	
	if (buttonIndex == 1)
    {
		NSLog(@"RootViewController: AlertView button wants to send an email" );
		//Send an Email
		//NSString *body = [NSString stringWithFormat:@"%@",alertView.message];
        NSString * body = [NSString stringWithFormat:@"%@\n\nDetails:\n%@", errorMessage, errorDetail];
		MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		[controller setToRecipients: [NSMutableArray arrayWithObjects: @"arisgames-dev@googlegroups.com",nil]];
		[controller setSubject:@"ARIS Error Report"];
		[controller setMessageBody:body isHTML:NO];
		if (controller)
            [self.gamePlayTabBarController presentModalViewController:controller animated:YES];
	}
	
	self.serverAlert = nil;
}

#pragma mark MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
	if (result == MFMailComposeResultSent) {
		NSLog(@"RootViewController: mailComposeController result == MFMailComposeResultSent");
	}
	[gamePlayTabBarController dismissModalViewControllerAnimated:YES];
}

#pragma mark UITabBarControllerDelegate methods

- (void)gamePlayTabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"RootViewController: gamePlayTabBarController didSelectViewController");
    
    [tabBar.moreNavigationController popToRootViewControllerAnimated:NO];
    
	//Hide any popups
	if ([viewController respondsToSelector:@selector(visibleViewController)]) {
		UIViewController *vc = [viewController performSelector:@selector(visibleViewController)];
		if ([vc respondsToSelector:@selector(dismissTutorial)]) {
			[vc performSelector:@selector(dismissTutorial)];
		}
	}
}

- (void) didReceiveGameChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"game"].location == NSNotFound) return;
    NSLog(@"Event Received");
    
    if([event.name isEqualToString:@"alert"])
        [[RootViewController sharedRootViewController] showAlert:@"Game Notice:" message:event.data];
    else if([event.name isEqualToString:@"display"])
    {
        NSString * data = [event.data stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        Location *loc = [[AppModel sharedAppModel].currentGame.locationsModel locationForId:[data intValue]];
        if(loc != nil)
            [loc.object display];
    }
    
    return;
}

- (void) didReceivePlayerChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"player"].location == NSNotFound) return;
    NSLog(@"Event Received");
    if([event.name isEqualToString:@"alert"])
        [[RootViewController sharedRootViewController] showAlert:@"Player Notice:" message:event.data];
    else if([event.name isEqualToString:@"display"])
    {
        NSString * data = [event.data stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        Location *loc = [[AppModel sharedAppModel].currentGame.locationsModel locationForId:[data intValue]];
        if(loc != nil)
            [loc.object display];
    }
    
    return;
}

- (void) didReceiveGroupChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"group"].location == NSNotFound) return;
    NSLog(@"Event Received");
    if([event.name isEqualToString:@"alert"])
        [[RootViewController sharedRootViewController] showAlert:@"Group Notice:" message:event.data];
    else if([event.name isEqualToString:@"display"])
    {
        NSString * data = [event.data stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        Location *loc = [[AppModel sharedAppModel].currentGame.locationsModel locationForId:[data intValue]];
        if(loc != nil)
            [loc.object display];
    }
    
    return;
}

- (void) didReceiveWebpageChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"webpage"].location == NSNotFound) return;
    NSLog(@"Event Received");
    if([event.name isEqualToString:@"alert"])
        [[RootViewController sharedRootViewController] showAlert:@"Webpage Notice:" message:event.data];
    else if([event.name isEqualToString:@"display"])
    {
        NSString * data = [event.data stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        Location *loc = [[AppModel sharedAppModel].currentGame.locationsModel locationForId:[data intValue]];
        if(loc != nil)
            [loc.object display];
    }
    
    return;
}

/*
 Notes on how this works:(Phil Dougherty- 10/23/12)
 Under normal navigation:
 UIApplication and RootView must agree that rotation is allowed. If so, rotates.
 When viewcontroller presented (modal-y stuff):
 UIApplication and Presented View Controller must agree.
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

#pragma mark Memory Management
- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[AppModel sharedAppModel].mediaCache clearCache];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
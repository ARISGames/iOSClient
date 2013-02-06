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

#import "NearbyObjectsViewController.h"
#import "BogusSelectGameViewController.h"

#import "GameDetailsViewController.h"
#import "webpageViewController.h"
#import "NoteDetailsViewController.h"

//Game Picker Tab VCs
#import "GamePickerNearbyViewController.h"
#import "GamePickerSearchViewController.h"
#import "GamePickerPopularViewController.h"
#import "GamePickerRecentViewController.h"
#import "AccountSettingsViewController.h"

//Game Tab VCs
#import "QuestsViewController.h"
#import "IconQuestsViewController.h"
#import "InventoryListViewController.h"
#import "GPSViewController.h"
#import "AttributesViewController.h"
#import "NotebookViewController.h"
#import "DecoderViewController.h"

#import "Node.h"

NSString *errorMessage, *errorDetail;

BOOL isShowingNotification;
BOOL isShowingPopOver;

@implementation RootViewController

@synthesize gameSelectionTabBarController;
@synthesize gameTabBarController;
@synthesize loginNavigationController;
@synthesize playerSettingsNavigationController;
@synthesize nearbyObjectsNavigationController;
@synthesize nearbyObjectNavigationController;
@synthesize loadingViewController;
@synthesize waitingIndicatorAlertViewController;
@synthesize networkAlert;
@synthesize serverAlert;
@synthesize notificationView;
@synthesize notifArray;
@synthesize popOverViewController;
@synthesize popOverArray;
@synthesize tutorialViewController;
@synthesize squishedVCFrame;
@synthesize notSquishedVCFrame;
@synthesize client;
@synthesize playerChannel;
@synthesize groupChannel;
@synthesize gameChannel;
@synthesize webpageChannel;
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if(self)
    {
        self.view.frame = frame;
        
        SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
        SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
        
        [self.gameTabBarController setDelegate:self];
        
        NSMutableArray* notifyArrayAlloc = [[NSMutableArray alloc]initWithCapacity:5];
        self.notifArray = notifyArrayAlloc;
        
        popOverArray = [[NSMutableArray alloc]initWithCapacity:5];
        popOverViewController = [[PopOverViewController alloc] init];
        
        //register for notifications from views
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoginAttempt:) name:@"NewLoginResponseReady" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectGame:) name:@"SelectGame" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPlayerSettings:) name:@"ProfSettingsRequested" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performLogout:) name:@"PassChangeRequested" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performLogout:) name:@"LogoutRequested" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForDisplayCompleteNode) name:@"NewQuestListReady" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMediaList) name:@"ReceivedMediaList" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURLGamesListReady) name:@"OneGameReady" object:nil];
        
        self.notificationView = [[UIWebView alloc] initWithFrame:CGRectMake(0, TRUE_ZERO_Y-8, SCREEN_WIDTH, 28)];
        self.notificationView.backgroundColor = [UIColor whiteColor];
        
        notSquishedVCFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT);
        squishedVCFrame = CGRectMake(0, TRUE_ZERO_Y + NOTIFICATION_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NOTIFICATION_HEIGHT);
        
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
        
        //QR Scanner Developer View
        DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithNibName:@"Decoder" bundle:nil];
        UINavigationController *decoderNavigationController = [[UINavigationController alloc] initWithRootViewController:decoderViewController];
        decoderNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        //Logout View
        AccountSettingsViewController *accountSettingsViewController = [[AccountSettingsViewController alloc] initWithNibName:@"Account" bundle:nil];
        UINavigationController *accountSettingsNavigationController = [[UINavigationController alloc] initWithRootViewController: accountSettingsViewController];
        accountSettingsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        //Developer View
        DeveloperViewController *developerViewController = [[DeveloperViewController alloc] initWithNibName:@"Developer" bundle:nil];
        UINavigationController *developerNavigationController = [[UINavigationController alloc] initWithRootViewController: developerViewController];
        developerNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        //Bogus Game Picker View
        BogusSelectGameViewController *bogusSelectGameViewController = [[BogusSelectGameViewController alloc] init];
        
        //Login View
        LoginViewController* loginViewController = [[LoginViewController alloc] initWithNibName:@"Login" bundle:nil];
        loginNavigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        loginNavigationController.view.frame = self.view.frame;
        [self.view addSubview:loginNavigationController.view];
        
        //Setup the Main Tab Bar
        self.gameTabBarController = [[UITabBarController alloc] init];
        self.gameTabBarController.delegate = self;
        UINavigationController *moreNavController = self.gameTabBarController.moreNavigationController;
        moreNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        moreNavController.delegate = self;
        self.gameTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                 questsNavigationController,
                                                 gpsNavigationController,
                                                 inventoryNavigationController,
                                                 decoderNavigationController,
                                                 //arNavigationController,
                                                 attributesNavigationController,
                                                 notesNavigationController,
                                                 bogusSelectGameViewController,
                                                 accountSettingsNavigationController,
                                                 //developerNavigationController,
                                                 iconQuestsNavigationController,
                                                 nil];
        self.gameTabBarController.view.hidden = YES;
        [self.gameTabBarController.view setFrame:self.view.bounds];
        [self.view addSubview:self.gameTabBarController.view];
        [AppModel sharedAppModel].defaultGameTabList = self.gameTabBarController.customizableViewControllers;
        
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
        
        GamePickerPopularViewController *gamePickerPopularVC = [[GamePickerPopularViewController alloc]initWithNibName:@"GamePickerPopularViewController" bundle:nil];
        UINavigationController *gamePickerPopularNC = [[UINavigationController alloc] initWithRootViewController:gamePickerPopularVC];
        gamePickerPopularNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        GamePickerRecentViewController *gamePickerRecentVC = [[GamePickerRecentViewController alloc]initWithNibName:@"GamePickerRecentViewController" bundle:nil];
        UINavigationController *gamePickerRecentNC = [[UINavigationController alloc] initWithRootViewController:gamePickerRecentVC];
        gamePickerRecentNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        //Logout View
        AccountSettingsViewController *anaccountSettingsViewController = [[AccountSettingsViewController alloc] initWithNibName:@"Account" bundle:nil];
        UINavigationController *anaccountSettingsNavigationController = [[UINavigationController alloc] initWithRootViewController: anaccountSettingsViewController];
        anaccountSettingsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        self.gameSelectionTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                              gamePickerNearbyNC,
                                                              //gamePickerMapNC,
                                                              gamePickerSearchNC,
                                                              gamePickerPopularNC,
                                                              gamePickerRecentNC,
                                                              anaccountSettingsNavigationController,
                                                              nil];
        //[self.gameSelectionTabBarController.view setFrame:UIScreen.mainScreen.applicationFrame];
        [self.view addSubview:self.gameSelectionTabBarController.view];
        
        //Global Player View
        PlayerSettingsViewController *playerSettingsViewController = [[PlayerSettingsViewController alloc] initWithNibName:@"PlayerSettingsViewController" bundle:nil];
        playerSettingsNavigationController = [[UINavigationController alloc] initWithRootViewController: playerSettingsViewController];
        playerSettingsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [playerSettingsNavigationController.view setFrame:UIScreen.mainScreen.applicationFrame];
        playerSettingsNavigationController.view.frame = self.view.frame;
        playerSettingsNavigationController.view.hidden = YES;
        [self.view addSubview:playerSettingsNavigationController.view];
        
        //Setup The Tutorial View Controller
        TutorialViewController *tutorialViewControllerAlloc = [[TutorialViewController alloc]init];
        self.tutorialViewController = tutorialViewControllerAlloc ;
        self.tutorialViewController.view.frame = self.gameTabBarController.view.frame;
        self.tutorialViewController.view.hidden = YES;
        self.tutorialViewController.view.userInteractionEnabled = NO;
        [self.gameTabBarController.view addSubview:self.tutorialViewController.view];
        
        //Setup Location Manager
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:[[MyCLController sharedMyCLController]locationManager]
                                       selector:@selector(startUpdatingLocation)
                                       userInfo:nil
                                        repeats:NO];
        
        //Set up visibility of views at top of heirarchy
        [[AppModel sharedAppModel] loadUserDefaults];
        if([AppModel sharedAppModel].playerId == 0)
        {
            self.loginNavigationController.view.hidden = NO;
            self.gameTabBarController.view.hidden = YES;
            self.gameSelectionTabBarController.view.hidden = YES;
        }
        else
        {
            [[AppServices sharedAppServices]setShowPlayerOnMap];
            [AppModel sharedAppModel].loggedIn = YES;
            self.loginNavigationController.view.hidden = YES;
            self.gameTabBarController.view.hidden = YES;
            /*if([AppModel sharedAppModel].museumMode)
             {
             self.gameSelectionTabBarController.view.hidden = YES;
             self.playerSettingsNavigationController.view.hidden = NO;
             }*/
            //else
            //{
            self.gameSelectionTabBarController.view.hidden = NO;
            self.playerSettingsNavigationController.view.hidden = YES;
            //}
        }
        
        self.waitingIndicatorAlertViewController = [[WaitingIndicatorAlertViewController alloc] init];
                
        //PUSHER STUFF
        //Setup Pusher Client
        self.client = [PTPusher pusherWithKey:@"79f6a265dbb7402a49c9" delegate:self encrypted:YES];
        self.client.authorizationURL = [NSURL URLWithString:@"http://dev.arisgames.org/server/events/auths/private_auth.php"];        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait animated:NO];
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

#pragma mark Notifications, Warnings and Other Views

-(void)enqueueNotificationWithFullString:(NSString *)fullString andBoldedString:(NSString *)boldedString
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:fullString,@"fullString",boldedString,@"boldedString", nil];
    [self.notifArray addObject:dict];
    if(!(isShowingNotification || isShowingPopOver))
        [self showNotifications];
}

-(void)enqueuePopOverWithTitle:(NSString *)title description:(NSString *)description webViewText:(NSString *)text andMediaId:(int) mediaId
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",description,@"description",text,@"text",[NSNumber numberWithInt:mediaId],@"mediaId", nil];
    [popOverArray addObject:dict];
    
    if(!(isShowingPopOver || isShowingNotification))
        [self showPopOver];
}

-(void)showNotifications
{
    NSLog(@"RootViewController: showNotifications");
    if([popOverArray count] > 0)
    {
        [self hideNotifications];
        [self showPopOver];
    }
    else if([self.notifArray count]>0)
    {
        NSLog(@"RootViewController: showNotifications: We have something to display");
        if(!isShowingNotification)
        {
            //lower frame into position if its not already there
            isShowingNotification = YES;
            [self.view addSubview:self.notificationView];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:.5];
            NSLog(@"RootViewController: showNotifications: Begin Resizing");
            NSLog(@"TabBC frame BEFORE origin: %f",self.gameTabBarController.view.frame.origin.y);
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            //NOTES: While the status bar is hidden, the view still is basing its origin on where the bottom of the status bar would be. Thus there is 20 pixels subtracted from all y-values to account for this.
            if(self.presentedViewController)
                self.presentedViewController.view.frame = squishedVCFrame;
            
            self.gameTabBarController.view.frame = squishedVCFrame;
            [UIView commitAnimations];
        }
        NSLog(@"TabBC frame AFTER origin: %f",self.gameTabBarController.view.frame.origin.y);
        NSLog(@"RootViewController: showNotifications: Set Text and Init alpha");
        
        notificationView.alpha = 0.0;
        NSString* fullString = [[notifArray objectAtIndex:0] objectForKey:@"fullString"];
        NSString* boldString = [[notifArray objectAtIndex:0] objectForKey:@"boldedString"];
        NSString* part1;
        NSString* part2;
        NSString* part3;
        
        NSRange boldRange = [fullString rangeOfString:boldString];
        if (boldRange.location == NSNotFound)
        {
            part1 = fullString;
            part2 = @"";
            part3 = @"";
        }
        else
        {
            part1 = [fullString substringToIndex:boldRange.location];
            part2 = [fullString substringWithRange:boldRange];
            part3 = [fullString substringFromIndex:(boldRange.location + boldRange.length)];
        }
        
        
        NSString* htmlContentString = [NSString stringWithFormat:
                                       @"<html>"
                                       "<style type=\"text/css\">"
                                       "body { vertical-align:text-top; text-align: center; font-family:Arial; font-size:16;}"
                                       ".different { font: 16px Arial, Helvetica, sans-serif;font-weight:bold;color:DarkBlue}"
                                       "</style>"
                                       "<body>"
                                       "%@<span class='different'>%@</span>%@"
                                       "</body></html>", part1, part2, part3];
        
        [notificationView loadHTMLString:htmlContentString baseURL:nil];
        
        [UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            NSLog(@"RootViewController: showNotifications: Begin Fade in");
            self.notificationView.alpha = 1.0;
        }completion:^(BOOL finished){
            if(finished){
                NSLog(@"RootViewController: showNotifications: Fade in Complete, Begin Fade Out");
                [UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
                    self.notificationView.alpha = 0.0;
                }completion:^(BOOL finished){
                    if(finished){
                        NSLog(@"RootViewController: showNotifications: Fade Out Complete, Pop and Start over");
                        if([notifArray count] > 0) [self.notifArray removeObjectAtIndex:0];
                        [self showNotifications];
                    }
                }];
            }
        }];
    }
    else
        [self hideNotifications];
}

-(void)showPopOver
{
    NSLog(@"RootViewController: showPopOvers");
    if([popOverArray count] > 0)
    {
        isShowingPopOver = YES;
        [popOverViewController view]; //used to force viewDidLoad before setTitle: descripion:...
        [popOverViewController setTitle:[[popOverArray objectAtIndex:0] objectForKey:@"title"] description:[[popOverArray objectAtIndex:0] objectForKey:@"description"] webViewText:[[popOverArray objectAtIndex:0] objectForKey:@"text"] andMediaId:[[[popOverArray objectAtIndex:0] objectForKey:@"mediaId"] intValue]];
        if (!(popOverViewController.isViewLoaded && popOverViewController.view.window))
            [self.view addSubview:popOverViewController.view];
        if([popOverArray count] > 0)
            [popOverArray removeObjectAtIndex:0];
    }
    else if (popOverViewController.isViewLoaded && popOverViewController.view.window)
    {
        [popOverViewController dismissViewControllerAnimated:NO completion:nil];
        [popOverViewController.view removeFromSuperview];
        isShowingPopOver = NO;
        [self showNotifications];
    }
    else
    {
        isShowingPopOver = NO;    //may not ever get here; defensive programming
        [self showNotifications];
    }
}

-(void)hideNotifications
{
    if(!gameTabBarController.view.hidden)
    {
        [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            if(isShowingNotification){
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
                
                
                if(self.presentedViewController) {
                    self.presentedViewController.view.frame = notSquishedVCFrame;
                }
                
                self.gameTabBarController.view.frame = notSquishedVCFrame;
            }
        }completion:^(BOOL finished){
            isShowingNotification = NO;
        }];
    }
    [self.notificationView removeFromSuperview];
    NSNotification *hideNotificationsNotification = [NSNotification notificationWithName:@"hideNotifications" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:hideNotificationsNotification];
}

- (void) showGameSelectionTabBarAndHideOthers
{
    //Put it onscreen
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    self.gameTabBarController.selectedIndex = 0;
    self.gameTabBarController.view.hidden = YES;
    self.gameSelectionTabBarController.view.hidden = NO;
    self.loginNavigationController.view.hidden = YES;
    self.playerSettingsNavigationController.view.hidden = YES;
    [UIView commitAnimations];
    [AppModel sharedAppModel].fallbackGameId = 0;
    [[AppModel sharedAppModel] saveUserDefaults];
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
                                                                  delegate:self cancelButtonTitle:NSLocalizedString(@"IgnoreKey", @"") otherButtonTitles:NSLocalizedString(@"ReportKey", @""),nil];
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
        [self gameTabBarController].selectedIndex = 0;
        [self showGameSelectionTabBarAndHideOthers];
    }
	if (!self.networkAlert)
    {
		networkAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"PoorConnectionTitleKey", @"")
                                                  message: NSLocalizedString(@"PoorConnectionMessageKey", @"")
												 delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
	}
	if (self.networkAlert.visible == NO) [networkAlert show];
}

- (void) removeNetworkAlert
{
	NSLog (@"RootViewController: Removing Network Alert");
	
	if (self.networkAlert != nil)
		[self.networkAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) showWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar
{
	NSLog (@"RootViewController: Showing Waiting Indicator");
    [self removeWaitingIndicator];
    
	[self.waitingIndicatorAlertViewController displayMessage:message withProgressBar:displayProgressBar];
}

- (void) removeWaitingIndicator
{
	NSLog (@"RootViewController: Removing Waiting Indicator");
    [self.waitingIndicatorAlertViewController dismissMessage];
}

- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController
{
    [AppServices sharedAppServices].currentlyInteractingWithObject = YES;
	self.nearbyObjectNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyObjectViewController];
	self.nearbyObjectNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.nearbyObjectNavigationController.view.frame = gameTabBarController.view.bounds;
    [self.gameTabBarController.view addSubview: self.nearbyObjectNavigationController.view];
}

- (void)dismissNearbyObjectView:(UIViewController *)nearbyObjectViewController
{
    [AppServices sharedAppServices].currentlyInteractingWithObject = NO;
    [nearbyObjectViewController.view removeFromSuperview];
    [self.nearbyObjectNavigationController.view removeFromSuperview];
    [[AppServices sharedAppServices] fetchAllPlayerLists];
}

- (void) returnToHomeView
{
	NSLog(@"RootViewController: Returning to Home View and Popping More Nav Controller");
    [self.gameTabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
}

- (void) displayIntroNode
{
    int nodeId = [AppModel sharedAppModel].currentGame.launchNodeId;
    if (nodeId && nodeId != 0)
    {
        NSLog(@"RootViewController: displayIntroNode");
        Node *launchNode = [[AppModel sharedAppModel] nodeForNodeId:[AppModel sharedAppModel].currentGame.launchNodeId];
        [launchNode display];
    }
    else
    {
        NSLog(@"RootViewController: displayIntroNode: Game did not specify an intro node, skipping");
        [AppServices sharedAppServices].currentlyInteractingWithObject = NO;
    }
    
    //What is this doing? -Phil 11-13-2012
    //Causing all views to load, so that they will enque notifications even if they haven't been viewed before -Jacob 1/14/13
    for(UIViewController * viewController in  gameTabBarController.viewControllers)
        [viewController view];
}

- (void) checkForDisplayCompleteNode
{
    int nodeID = [AppModel sharedAppModel].currentGame.completeNodeId;
    if ([AppModel sharedAppModel].currentGame.completedQuests == [AppModel sharedAppModel].currentGame.totalQuests &&
        [AppModel sharedAppModel].currentGame.completedQuests > 0  && nodeID != 0)
    {
        NSLog(@"RootViewController: checkForIntroOrCompleteNodeDisplay: Displaying Complete Node");
		Node *completeNode = [[AppModel sharedAppModel] nodeForNodeId:[AppModel sharedAppModel].currentGame.completeNodeId];
		[completeNode display];
	}
}

- (void) showNearbyTab:(BOOL)yesOrNo
{
    if([AppModel sharedAppModel].tabsReady)
    {
        NSMutableArray *tabs = [NSMutableArray arrayWithArray:self.gameTabBarController.viewControllers];
        
        if(yesOrNo)
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
        
        [self.gameTabBarController setViewControllers:tabs animated:NO];
        
        NSNotification *n = [NSNotification notificationWithName:@"TabBarItemsChanged" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:n];
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
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self
                       selector:@selector(handleOpenURLGamesListReady)
                           name:@"OneGameReady"
                         object:nil];
        [[AppServices sharedAppServices] fetchOneGame:gameId];
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
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self
                       selector:@selector(handleOpenURLGamesListReady)
                           name:@"OneGameReady"
                         object:nil];
        [[AppServices sharedAppServices] fetchOneGame:gameId];
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
        
        self.gameTabBarController.view.hidden = YES;
        self.loginNavigationController.view.hidden = YES;
        if([AppModel sharedAppModel].museumMode)
        {
            [self showPlayerSettings:nil];
            if([AppModel sharedAppModel].playerMediaId == 0 || [AppModel sharedAppModel].playerMediaId == -1)
                [(PlayerSettingsViewController *)self.playerSettingsNavigationController.topViewController playerPicCamButtonTouched:nil];
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
    //NSDictionary *loginObject = [notification object];
	NSDictionary *userInfo = notification.userInfo;
	Game *selectedGame = [userInfo objectForKey:@"game"];
    [AppServices sharedAppServices].currentlyInteractingWithObject = NO;
    
	NSLog(@"RootViewController: Game Selected. '%@' game was selected", selectedGame.name);
	
    //Put it onscreen
    //Start loading all the data
    loadingViewController = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil]; //this is dumb. should have one, and re-use it.
    loadingViewController.progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
    [self.gameTabBarController presentModalViewController:self.loadingViewController animated:NO];
    
    self.gameTabBarController.view.hidden = NO;
    self.gameSelectionTabBarController.view.hidden = YES;
    self.loginNavigationController.view.hidden = YES;
    self.playerSettingsNavigationController.view.hidden = YES;
    
    [self returnToHomeView];
    
	//Clear out the old game data
    if(gameChannel) [client unsubscribeFromChannel:(PTPusherChannel *)gameChannel];
    if(groupChannel) [client unsubscribeFromChannel:(PTPusherChannel *)groupChannel];
    if(webpageChannel) [client unsubscribeFromChannel:(PTPusherChannel *)webpageChannel];
    
    [[AppServices sharedAppServices] fetchTabBarItemsForGame:selectedGame.gameId];
	[[AppServices sharedAppServices] resetAllPlayerLists];
    [[AppServices sharedAppServices] resetAllGameLists];
    [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] resetCurrentlyFetchingVars];
	[tutorialViewController dismissAllTutorials];
    
	//Set the model to this game
	[AppModel sharedAppModel].currentGame = selectedGame;
    [AppModel sharedAppModel].fallbackGameId = [AppModel sharedAppModel].currentGame.gameId;
	[[AppModel sharedAppModel] saveUserDefaults];
	
    
    
    [[AppServices sharedAppServices] fetchAllGameLists];
    
	//Notify the Server
	NSLog(@"RootViewController: Game Selected. Notifying Server");
	[[AppServices sharedAppServices] updateServerGameSelected];
    
    [AppModel sharedAppModel].hasReceivedMediaList = NO;
    
    playerChannel = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-player-channel",[AppModel sharedAppModel].playerId]];
    if([AppModel sharedAppModel].groupGame == [AppModel sharedAppModel].currentGame.gameId)
        groupChannel = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%@-group-channel",@"group"]];
    gameChannel = [self.client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-game-channel",[AppModel sharedAppModel].currentGame.gameId]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePlayerChannelEventNotification:)
                                                 name:PTPusherEventReceivedNotification
                                               object:playerChannel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveGroupChannelEventNotification:)
                                                 name:PTPusherEventReceivedNotification
                                               object:groupChannel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveGameChannelEventNotification:)
                                                 name:PTPusherEventReceivedNotification
                                               object:gameChannel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveWebpageChannelEventNotification:)
                                                 name:PTPusherEventReceivedNotification
                                               object:webpageChannel];
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self
                   selector:@selector(handleOpenURLGamesListReady)
                       name:@"OneGameReady"
                     object:nil];
    
    [[AppServices sharedAppServices] fetchGame:selectedGame.gameId];
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
    
    for(int y = 0; y < [newTabList count];y++)
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
    
    self.gameTabBarController.viewControllers = [NSArray arrayWithArray: newCustomVC];
    [AppModel sharedAppModel].tabsReady = YES;
}

- (void)performLogout:(NSNotification *)notification
{
    NSLog(@"Performing Logout: Clearing NSUserDefaults and Displaying Login Screen");
	
    if(playerChannel) [client unsubscribeFromChannel:(PTPusherChannel *)playerChannel];
    if(gameChannel) [client unsubscribeFromChannel:(PTPusherChannel *)gameChannel];
    if(groupChannel) [client unsubscribeFromChannel:(PTPusherChannel *)groupChannel];
    if(webpageChannel) [client unsubscribeFromChannel:(PTPusherChannel *)webpageChannel];
    
	//Clear any user realated info in AppModel (except server)
	[[AppModel sharedAppModel] clearUserDefaults];
	
	//clear the tutorial popups
	[tutorialViewController dismissAllTutorials];
	
	//(re)load the login view
	self.gameTabBarController.view.hidden = YES;
    self.gameSelectionTabBarController.view.hidden = YES;
    self.playerSettingsNavigationController.view.hidden = YES;
    self.loginNavigationController.view.hidden = NO;
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
        
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(handleOpenURLGamesListReady) name:@"OneGameReady" object:nil];
        [[AppServices sharedAppServices] fetchOneGame:[gameID intValue]];
    }
    return YES;
}

- (void) handleOpenURLGamesListReady
{
    NSLog(@"game opened");
    
    //unregister for notifications //<- Why? Phil 09/19/12 (I commented out the next line to get this to work)
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    if([[[AppModel sharedAppModel] singleGameList] count] <= 0) return;
    Game *selectedGame = [[[AppModel sharedAppModel] singleGameList] objectAtIndex:0];
    GameDetailsViewController *gameDetailsViewController = [[GameDetailsViewController alloc] initWithNibName:@"GameDetails" bundle:nil];
    gameDetailsViewController.game = selectedGame;
    
    [AppModel sharedAppModel].currentGame = selectedGame;
    [AppModel sharedAppModel].fallbackGameId = [AppModel sharedAppModel].currentGame.gameId;
	[[AppModel sharedAppModel] saveUserDefaults];
    
    // show gameSelectionTabBarController
    self.gameTabBarController.view.hidden = YES;
    self.loginNavigationController.view.hidden = YES;
    if([AppModel sharedAppModel].museumMode)
    {
        self.playerSettingsNavigationController.view.hidden = NO;
        [(PlayerSettingsViewController *)self.playerSettingsNavigationController.topViewController manuallyForceViewDidAppear];
        self.gameSelectionTabBarController.view.hidden = NO;
        self.gameSelectionTabBarController.selectedIndex = 0;
    }
    else
    {
        self.playerSettingsNavigationController.view.hidden = YES;
        self.gameSelectionTabBarController.view.hidden = NO;
        self.gameSelectionTabBarController.selectedIndex = 0;
    }
    
    NSLog(@"gameID= %i",selectedGame.gameId);
    NSLog(@"game= %@",selectedGame.name);
    NSLog(@"gameDetailsViewController nib name = %@",gameDetailsViewController.nibName);
    
    // Push Game Detail View Controller
    [(UINavigationController*)self.gameSelectionTabBarController.selectedViewController pushViewController:gameDetailsViewController animated:YES];
    [self.navigationController pushViewController:gameDetailsViewController animated:YES];
    [AppModel sharedAppModel].skipGameDetails = YES;
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
            [self.gameTabBarController presentModalViewController:controller animated:YES];
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
	[gameTabBarController dismissModalViewControllerAnimated:YES];
}

#pragma mark UITabBarControllerDelegate methods

- (void)gameTabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"RootViewController: gameTabBarController didSelectViewController");
    
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
        
        Location *loc = [[AppModel sharedAppModel] locationForLocationId:[data intValue]];
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
        
        Location *loc = [[AppModel sharedAppModel] locationForLocationId:[data intValue]];
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
        
        Location *loc = [[AppModel sharedAppModel] locationForLocationId:[data intValue]];
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
        
        Location *loc = [[AppModel sharedAppModel] locationForLocationId:[data intValue]];
        if(loc != nil)
            [loc.object display];
    }
    
    return;
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
//
//  GamePickersViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/3/13.
//
//

#import "ARISAppDelegate.h"
#import "ARISAlertHandler.h"
#import "GamePickersViewController.h"
#import "GamePickerViewController.h"

#import "GamePickerNearbyViewController.h"
#import "GamePickerPopularViewController.h"
#import "GamePickerRecentViewController.h"
#import "GamePickerSearchViewController.h"
#import "GamePickerMineViewController.h"
#import "GamePickerDownloadedViewController.h"

#import "PKRevealController.h"
#import "AccountSettingsViewController.h"
#import "ARISNavigationController.h"
#import "AppModel.h"

@interface GamePickersViewController () <UITabBarControllerDelegate, GamePickerViewControllerDelegate, AccountSettingsViewControllerDelegate>
{
  PKRevealController *gamePickersRevealController;
  ARISNavigationController *gamePickersNavigationController;
  UITabBarController *online_gamePickersTabBarController;
  UITabBarController *offline_gamePickersTabBarController;
  UITabBarController *cur_gamePickersTabBarController;
  ARISNavigationController *accountSettingsNavigationController;
  BOOL seen_download_notif;

  id<GamePickersViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) PKRevealController *gamePickersRevealController;
@property (nonatomic, strong) ARISNavigationController *gamePickersNavigationController;
@property (nonatomic, strong) UITabBarController *online_gamePickersTabBarController;
@property (nonatomic, strong) UITabBarController *offline_gamePickersTabBarController;
@property (nonatomic, strong) UITabBarController *cur_gamePickersTabBarController;
@property (nonatomic, strong) ARISNavigationController *accountSettingsNavigationController;
@property (nonatomic, assign) BOOL seen_download_notif;

@end

@implementation GamePickersViewController

@synthesize gamePickersRevealController;
@synthesize gamePickersNavigationController;
@synthesize online_gamePickersTabBarController;
@synthesize offline_gamePickersTabBarController;
@synthesize cur_gamePickersTabBarController;
@synthesize accountSettingsNavigationController;
@synthesize seen_download_notif;

- (id) initWithDelegate:(id<GamePickersViewControllerDelegate>)d;
{
  if(self = [super init])
  {
    delegate = d;
    seen_download_notif = NO;
  }
  return self;
}

- (void) loadView
{
  [super loadView];

  //Setup the Game Selection Tab Bar
  self.online_gamePickersTabBarController = [[UITabBarController alloc] init];
  self.online_gamePickersTabBarController.delegate = self;
  self.offline_gamePickersTabBarController = [[UITabBarController alloc] init];
  self.offline_gamePickersTabBarController.delegate = self;

  //init pickervcs
  GamePickerNearbyViewController     *gpnvc = [[GamePickerNearbyViewController     alloc] initWithDelegate:self];
  GamePickerPopularViewController    *gppvc = [[GamePickerPopularViewController    alloc] initWithDelegate:self];
  GamePickerRecentViewController     *gprvc = [[GamePickerRecentViewController     alloc] initWithDelegate:self];
  GamePickerSearchViewController     *gpsvc = [[GamePickerSearchViewController     alloc] initWithDelegate:self];
  GamePickerMineViewController       *gpmvc = [[GamePickerMineViewController       alloc] initWithDelegate:self];
  GamePickerDownloadedViewController *gpdvc = [[GamePickerDownloadedViewController alloc] initWithDelegate:self];

  self.online_gamePickersTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                      gpnvc,
                                                      gppvc,
                                                      gprvc,
                                                      gpsvc,
                                                      gpmvc,
                                                      nil];
  self.offline_gamePickersTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                      gpdvc,
                                                      nil];

  if([_DELEGATE_.reachability currentReachabilityStatus] == NotReachable) //offline
    self.cur_gamePickersTabBarController = self.offline_gamePickersTabBarController;
  else
    self.cur_gamePickersTabBarController = self.online_gamePickersTabBarController;

  self.gamePickersNavigationController = [[ARISNavigationController alloc] initWithRootViewController:self.cur_gamePickersTabBarController];
  self.gamePickersNavigationController.automaticallyAdjustsScrollViewInsets = NO;

  self.accountSettingsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:[[AccountSettingsViewController alloc] initWithDelegate:self]];

  self.gamePickersRevealController = [PKRevealController revealControllerWithFrontViewController:self.gamePickersNavigationController leftViewController:self.accountSettingsNavigationController];

  UIView *logoContainer = [[UIView alloc] initWithFrame:self.cur_gamePickersTabBarController.navigationItem.titleView.frame];
  UIImageView *logoText  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
  logoText.frame = CGRectMake(logoContainer.frame.size.width/2-50, logoContainer.frame.size.height/2-15, 100, 30);
  [logoContainer addSubview:logoText];
  self.cur_gamePickersTabBarController.navigationItem.titleView = logoContainer;

  UIButton *settingsbutton = [UIButton buttonWithType:UIButtonTypeCustom];
  settingsbutton.frame = CGRectMake(0, 0, 27, 27);
  [settingsbutton setImage:[UIImage imageNamed:@"threelines.png"] forState:UIControlStateNormal];
  [settingsbutton addTarget:self action:@selector(accountButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  settingsbutton.accessibilityLabel = @"Settings Button";
  self.cur_gamePickersTabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsbutton];
  // newly required in iOS 11: https://stackoverflow.com/a/44456952
  if ([settingsbutton respondsToSelector:@selector(widthAnchor)] && [settingsbutton respondsToSelector:@selector(heightAnchor)]) {
    [[settingsbutton.widthAnchor constraintEqualToConstant:27.0] setActive:true];
    [[settingsbutton.heightAnchor constraintEqualToConstant:27.0] setActive:true];
  }

  _ARIS_NOTIF_LISTEN_(@"NETWORK_CONNECTED",self,@selector(swapToOnline),nil);
  //_ARIS_NOTIF_LISTEN_(@"NETWORK_DISCONNECTED",self,@selector(swapToOffline),nil);
}

- (void) checkIfStillOffline
{
  if([_DELEGATE_.reachability currentReachabilityStatus] == NotReachable) //offline
  {
    [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:@"Cannot Connect to Internet" message:@"Until we can connect to the internet, you will only be able to play games you have already downloaded."];
    seen_download_notif = YES;
  }
}
- (void) swapToOnline
{
  [self swapToTabController:self.online_gamePickersTabBarController];
}
- (void) swapToOffline
{
  if(!seen_download_notif)
    [self performSelector:@selector(checkIfStillOffline) withObject:nil afterDelay:1];
  [self swapToTabController:self.offline_gamePickersTabBarController];
}
- (void) swapToTabController:(UITabBarController *)tbc
{
  tbc.navigationItem.titleView = self.cur_gamePickersTabBarController.navigationItem.titleView;
  tbc.navigationItem.leftBarButtonItem = self.cur_gamePickersTabBarController.navigationItem.leftBarButtonItem;
  self.cur_gamePickersTabBarController = tbc;
  [self.gamePickersNavigationController setViewControllers:@[self.cur_gamePickersTabBarController] animated:FALSE];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  //if([_DELEGATE_.reachability currentReachabilityStatus] == NotReachable) //[self swapToOffline];
  //else
  [self swapToOnline];
    
  [self displayContentController:self.gamePickersRevealController];
}

- (void) gamePicked:(Game *)g
{
  [delegate gameDetailsRequested:g];
}

- (void) accountButtonTouched
{
  [self.gamePickersRevealController showViewController:self.accountSettingsNavigationController];
}

- (void) profileEditRequested
{
  [delegate profileEditRequested];
}

- (void) passChangeRequested
{
  [delegate passChangeRequested];
}

- (void) logoutWasRequested
{
  [self.gamePickersRevealController showViewController:self.online_gamePickersTabBarController];
  [self.gamePickersRevealController showViewController:self.offline_gamePickersTabBarController];
  [_MODEL_ logOut];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait;
}
- (BOOL) shouldAutorotate
{
  return NO;
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

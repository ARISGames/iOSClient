//
//  GamePickersViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/3/13.
//
//

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
    UITabBarController *gamePickersTabBarController;
    ARISNavigationController *accountSettingsNavigationController;

    id<GamePickersViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) PKRevealController *gamePickersRevealController;
@property (nonatomic, strong) ARISNavigationController *gamePickersNavigationController;
@property (nonatomic, strong) UITabBarController *gamePickersTabBarController;
@property (nonatomic, strong) ARISNavigationController *accountSettingsNavigationController;

@end

@implementation GamePickersViewController

@synthesize gamePickersRevealController;
@synthesize gamePickersNavigationController;
@synthesize gamePickersTabBarController;
@synthesize accountSettingsNavigationController;

- (id) initWithDelegate:(id<GamePickersViewControllerDelegate>)d;
{
    if(self = [super init])
    {
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];

    //Setup the Game Selection Tab Bar
    self.gamePickersTabBarController = [[UITabBarController alloc] init];
    self.gamePickersTabBarController.delegate = self;

    //init pickervcs
    GamePickerNearbyViewController     *gpnvc = [[GamePickerNearbyViewController     alloc] initWithDelegate:self];
    GamePickerPopularViewController    *gppvc = [[GamePickerPopularViewController    alloc] initWithDelegate:self];
    GamePickerRecentViewController     *gprvc = [[GamePickerRecentViewController     alloc] initWithDelegate:self];
    GamePickerSearchViewController     *gpsvc = [[GamePickerSearchViewController     alloc] initWithDelegate:self];
    GamePickerMineViewController       *gpmvc = [[GamePickerMineViewController       alloc] initWithDelegate:self];
    GamePickerDownloadedViewController *gpdvc = [[GamePickerDownloadedViewController alloc] initWithDelegate:self];
  
    self.gamePickersTabBarController.viewControllers = [NSMutableArray arrayWithObjects:gpnvc,gppvc,gprvc,gpsvc,gpmvc,/*gpdvc,*/nil];
    self.gamePickersNavigationController = [[ARISNavigationController alloc] initWithRootViewController:self.gamePickersTabBarController];
    self.gamePickersNavigationController.automaticallyAdjustsScrollViewInsets = NO;

    self.accountSettingsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:[[AccountSettingsViewController alloc] initWithDelegate:self]];

    self.gamePickersRevealController = [PKRevealController revealControllerWithFrontViewController:self.gamePickersNavigationController leftViewController:self.accountSettingsNavigationController options:nil];

    UIView *logoContainer = [[UIView alloc] initWithFrame:self.gamePickersTabBarController.navigationItem.titleView.frame];
    UIImageView *logoText  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
    logoText.frame = CGRectMake(logoContainer.frame.size.width/2-50, logoContainer.frame.size.height/2-15, 100, 30);
    [logoContainer addSubview:logoText];
    self.gamePickersTabBarController.navigationItem.titleView = logoContainer;

    UIButton *settingsbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsbutton.frame = CGRectMake(0, 0, 27, 27);
    [settingsbutton setImage:[UIImage imageNamed:@"threelines.png"] forState:UIControlStateNormal];
    [settingsbutton addTarget:self action:@selector(accountButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    settingsbutton.accessibilityLabel = @"Settings Button";
    self.gamePickersTabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsbutton];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self displayContentController:self.gamePickersRevealController];
}

- (void) gamePicked:(Game *)g downloaded:(BOOL)d
{
    [delegate gameDetailsRequested:g downloaded:d];
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
    [self.gamePickersRevealController showViewController:self.gamePickersTabBarController];
    [_MODEL_ logOut];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

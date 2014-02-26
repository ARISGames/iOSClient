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
#import "GamePickerAnywhereViewController.h"
#import "GamePickerPopularViewController.h"
#import "GamePickerRecentViewController.h"
#import "GamePickerSearchViewController.h"
#import "GameDetailsViewController.h"
#import "PKRevealController.h"
#import "AccountSettingsViewController.h"
#import "ARISNavigationController.h"
#import "ARISTemplate.h"

@interface GamePickersViewController () <UITabBarControllerDelegate, GamePickerViewControllerDelegate, GameDetailsViewControllerDelegate, AccountSettingsViewControllerDelegate>
{
    PKRevealController *gamePickersRevealController;
    ARISNavigationController *gamePickersNavigationController;
    UITabBarController *gamePickersTabBarController;
    GameDetailsViewController *gameDetailsViewController;
    ARISNavigationController *accountSettingsNavigationController;
    
    id<GamePickersViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) PKRevealController *gamePickersRevealController;
@property (nonatomic, strong) ARISNavigationController *gamePickersNavigationController;
@property (nonatomic, strong) UITabBarController *gamePickersTabBarController;
@property (nonatomic, strong) GameDetailsViewController *gameDetailsViewController;
@property (nonatomic, strong) ARISNavigationController *accountSettingsNavigationController;

@end

@implementation GamePickersViewController

@synthesize gamePickersRevealController;
@synthesize gamePickersNavigationController;
@synthesize gamePickersTabBarController;
@synthesize gameDetailsViewController;
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
}

- (void) viewWillLayoutSubviews
{
    //Setup the Game Selection Tab Bar
    self.gamePickersTabBarController = [[UITabBarController alloc] init];
    self.gamePickersTabBarController.delegate = self;
    
    //init pickervcs
    GamePickerNearbyViewController   *gpnvc = [[GamePickerNearbyViewController   alloc] initWithDelegate:self];
    GamePickerAnywhereViewController *gpavc = [[GamePickerAnywhereViewController alloc] initWithDelegate:self];
    GamePickerPopularViewController  *gppvc = [[GamePickerPopularViewController  alloc] initWithDelegate:self];
    GamePickerRecentViewController   *gprvc = [[GamePickerRecentViewController   alloc] initWithDelegate:self];
    GamePickerSearchViewController   *gpsvc = [[GamePickerSearchViewController   alloc] initWithDelegate:self];
    self.gamePickersTabBarController.viewControllers = [NSMutableArray arrayWithObjects:gpnvc,gpavc,gppvc,gprvc,gpsvc,nil];
    self.gamePickersNavigationController = [[ARISNavigationController alloc] initWithRootViewController:self.gamePickersTabBarController];
    self.gamePickersNavigationController.automaticallyAdjustsScrollViewInsets = NO;
    
    AccountSettingsViewController *accountSettingsViewController = [[AccountSettingsViewController alloc] initWithDelegate:self];
    self.accountSettingsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:accountSettingsViewController];
    
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
    
    if(!currentChildViewController)
        [self displayContentController:self.gamePickersRevealController];
}

- (void) gamePicked:(Game *)g
{
    self.gameDetailsViewController = [[GameDetailsViewController alloc] initWithGame:g delegate:self];
    [self.gamePickersNavigationController pushViewController:self.gameDetailsViewController animated:YES];
}

- (void) gameDetailsWereCanceled:(Game *)g
{
    [self.gamePickersNavigationController popToRootViewControllerAnimated:YES];
    self.gameDetailsViewController = nil;
}

- (void) gameDetailsWereConfirmed:(Game *)g
{
    [delegate gamePickedForPlay:g];
}

- (void) accountButtonTouched
{
    [self.gamePickersRevealController showViewController:self.accountSettingsNavigationController];
}

- (void) playerSettingsRequested
{
    [delegate playerSettingsRequested];
}

- (void) logoutWasRequested
{
    [self displayContentController:self.gamePickersRevealController];
    [self.gamePickersRevealController showViewController:self.gamePickersTabBarController];
    [delegate logoutWasRequested];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

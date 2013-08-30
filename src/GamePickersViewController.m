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
#import "UIColor+ARISColors.h"

@interface GamePickersViewController () <UITabBarControllerDelegate, GamePickerViewControllerDelegate, GameDetailsViewControllerDelegate, AccountSettingsViewControllerDelegate>
{
    PKRevealController *gamePickersRevealController;
    ARISNavigationController *gamePickersNavigationController;
    UITabBarController *gamePickersTabBarController;
    ARISNavigationController *gameDetailsNavigationController;
    ARISNavigationController *accountSettingsNavigationController;
    
    id<GamePickersViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) PKRevealController *gamePickersRevealController;
@property (nonatomic, strong) ARISNavigationController *gamePickersNavigationController;
@property (nonatomic, strong) UITabBarController *gamePickersTabBarController;
@property (nonatomic, strong) ARISNavigationController *gameDetailsNavigationController;
@property (nonatomic, strong) ARISNavigationController *accountSettingsNavigationController;

@end

@implementation GamePickersViewController

@synthesize gamePickersRevealController;
@synthesize gamePickersNavigationController;
@synthesize gamePickersTabBarController;
@synthesize gameDetailsNavigationController;
@synthesize accountSettingsNavigationController;

- (id) initWithDelegate:(id<GamePickersViewControllerDelegate>)d
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
    
    //Frame will need to get set in viewWillAppear:
    // http://stackoverflow.com/questions/11305818/create-view-in-load-view-and-set-its-frame-but-frame-auto-changes
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect viewFrame;
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        viewFrame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    else
        viewFrame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    
    //Setup the Game Selection Tab Bar
    self.gamePickersTabBarController = [[UITabBarController alloc] init];
    self.gamePickersTabBarController.delegate = self;
    self.gamePickersTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                        [[GamePickerNearbyViewController   alloc] initWithViewFrame:viewFrame delegate:self],
                        [[GamePickerAnywhereViewController alloc] initWithViewFrame:viewFrame delegate:self],
                        [[GamePickerPopularViewController  alloc] initWithViewFrame:viewFrame delegate:self],
                        [[GamePickerRecentViewController   alloc] initWithViewFrame:viewFrame delegate:self],
                        [[GamePickerSearchViewController   alloc] initWithViewFrame:viewFrame delegate:self],
                        nil];
    
    self.gamePickersNavigationController = [[ARISNavigationController alloc] initWithRootViewController:self.gamePickersTabBarController];
    
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
    [settingsbutton setImage:[UIImage imageNamed:@"idcard.png"] forState:UIControlStateNormal];
    [settingsbutton addTarget:self action:@selector(accountButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.gamePickersTabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsbutton];
    
    if(!currentChildViewController)
        [self displayContentController:self.gamePickersRevealController];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) gamePicked:(Game *)g
{
    GameDetailsViewController *gameDetailsViewController = [[GameDetailsViewController alloc] initWithGame:g delegate:self];
    
    self.gameDetailsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:gameDetailsViewController];
    [self displayContentController:self.gameDetailsNavigationController];
}

- (void) gameDetailsWereCanceled:(Game *)g
{
    [self displayContentController:self.gamePickersRevealController];
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

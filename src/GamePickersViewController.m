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
    UITabBarController *gamePickersTabBarController;
    ARISNavigationController *gameDetailsNavigationController;
    ARISNavigationController *accountSettingsNavigationController;
    
    id<GamePickersViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) PKRevealController *gamePickersRevealController;
@property (nonatomic, strong) UITabBarController *gamePickersTabBarController;
@property (nonatomic, strong) ARISNavigationController *gameDetailsNavigationController;
@property (nonatomic, strong) ARISNavigationController *accountSettingsNavigationController;

@end

@implementation GamePickersViewController

@synthesize gamePickersRevealController;
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
    
    //Nearby Games
    GamePickerNearbyViewController *gamePickerNearbyViewController = [[GamePickerNearbyViewController alloc] initWithDelegate:self];
    ARISNavigationController *gamePickerNearbyNC = [[ARISNavigationController alloc] initWithRootViewController:gamePickerNearbyViewController];
    
    //Anywhere Games
    GamePickerAnywhereViewController *gamePickerAnywhereViewController = [[GamePickerAnywhereViewController alloc] initWithDelegate:self];
    ARISNavigationController *gamePickerAnywhereNC = [[ARISNavigationController alloc] initWithRootViewController:gamePickerAnywhereViewController];
    
    //Popular Games
    GamePickerPopularViewController *gamePickerPopularVC = [[GamePickerPopularViewController alloc] initWithDelegate:self];
    ARISNavigationController *gamePickerPopularNC = [[ARISNavigationController alloc] initWithRootViewController:gamePickerPopularVC];
    
    //Recent Games
    GamePickerRecentViewController *gamePickerRecentVC = [[GamePickerRecentViewController alloc] initWithDelegate:self];
    ARISNavigationController *gamePickerRecentNC = [[ARISNavigationController alloc] initWithRootViewController:gamePickerRecentVC];
    
    //Search Games
    GamePickerSearchViewController *gamePickerSearchVC = [[GamePickerSearchViewController alloc] initWithDelegate:self];
    ARISNavigationController *gamePickerSearchNC = [[ARISNavigationController alloc] initWithRootViewController:gamePickerSearchVC];
    
    //Setup the Game Selection Tab Bar
    self.gamePickersTabBarController = [[UITabBarController alloc] init];
    self.gamePickersTabBarController.delegate = self;
    self.gamePickersTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                       gamePickerNearbyNC,
                                                       gamePickerAnywhereNC,
                                                       gamePickerPopularNC,
                                                       gamePickerRecentNC,
                                                       gamePickerSearchNC,
                                                        nil];
    
    AccountSettingsViewController *accountSettingsViewController = [[AccountSettingsViewController alloc] initWithDelegate:self];
    self.accountSettingsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:accountSettingsViewController];
    
    self.gamePickersRevealController = [PKRevealController revealControllerWithFrontViewController:self.gamePickersTabBarController leftViewController:self.accountSettingsNavigationController options:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!currentChildViewController)
        [self displayContentController:self.gamePickersRevealController];
}

- (void) resetState
{
    [self displayContentController:self.gamePickersRevealController];
    for(int i = 0; i < [[self.gamePickersTabBarController viewControllers] count]; i++)
        [(GamePickerViewController *)([[((ARISNavigationController *)[[self.gamePickersTabBarController viewControllers] objectAtIndex:i]) viewControllers] objectAtIndex:0]) clearList];
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

- (void) accountSettingsRequested
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

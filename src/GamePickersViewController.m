//
//  GamePickersViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/3/13.
//
//

#import "GamePickersViewController.h"
#import "GamePickerViewController.h"
#import "GamePickerSearchViewController.h"
#import "GamePickerNearbyViewController.h"
#import "GamePickerPopularViewController.h"
#import "GamePickerRecentViewController.h"
#import "GameDetailsViewController.h"
#import "AccountSettingsViewController.h"

@interface GamePickersViewController () <UITabBarControllerDelegate, GamePickerViewControllerDelegate, GameDetailsViewControllerDelegate, AccountSettingsViewControllerDelegate>
{
    UITabBarController *gamePickersTabBarController;
    UINavigationController *gameDetailsNavigationController;
    UINavigationController *accountSettingsNavigationController;
    
    id<GamePickersViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) UITabBarController *gamePickersTabBarController;
@property (nonatomic, strong) UINavigationController *gameDetailsNavigationController;
@property (nonatomic, strong) UINavigationController *accountSettingsNavigationController;

@end

@implementation GamePickersViewController

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
    UINavigationController *gamePickerNearbyNC = [[UINavigationController alloc] initWithRootViewController:gamePickerNearbyViewController];
    gamePickerNearbyNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Search Games
    GamePickerSearchViewController *gamePickerSearchVC = [[GamePickerSearchViewController alloc] initWithDelegate:self];
    UINavigationController *gamePickerSearchNC = [[UINavigationController alloc] initWithRootViewController:gamePickerSearchVC];
    gamePickerSearchNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Popular Games
    GamePickerPopularViewController *gamePickerPopularVC = [[GamePickerPopularViewController alloc] initWithDelegate:self];
    UINavigationController *gamePickerPopularNC = [[UINavigationController alloc] initWithRootViewController:gamePickerPopularVC];
    gamePickerPopularNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Recent Games
    GamePickerRecentViewController *gamePickerRecentVC = [[GamePickerRecentViewController alloc] initWithDelegate:self];
    UINavigationController *gamePickerRecentNC = [[UINavigationController alloc] initWithRootViewController:gamePickerRecentVC];
    gamePickerRecentNC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Setup the Game Selection Tab Bar
    self.gamePickersTabBarController = [[UITabBarController alloc] init];
    self.gamePickersTabBarController.delegate = self;
    
    self.gamePickersTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                       gamePickerNearbyNC,
                                                       gamePickerSearchNC,
                                                       gamePickerPopularNC,
                                                       gamePickerRecentNC,
                                                       //accountSettingsNC,
                                                       nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!currentChildViewController)
        [self displayContentController:self.gamePickersTabBarController];
}

- (void) gamePicked:(Game *)g
{
    GameDetailsViewController *gameDetailsViewController = [[GameDetailsViewController alloc] initWithGame:g delegate:self];
    self.gameDetailsNavigationController = [[UINavigationController alloc] initWithRootViewController:gameDetailsViewController];
    self.gameDetailsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self displayContentController:self.gameDetailsNavigationController];
}

- (void) gameDetailsWereCanceled:(Game *)g
{
    [self displayContentController:self.gamePickersTabBarController];
}

- (void) gameDetailsWereConfirmed:(Game *)g
{
    [delegate gamePickedForPlay:g];
}

- (void) accountSettingsRequested
{
    AccountSettingsViewController *accountSettingsViewController = [[AccountSettingsViewController alloc] initWithDelegate:self];
    self.accountSettingsNavigationController = [[UINavigationController alloc] initWithRootViewController:accountSettingsViewController];
    self.accountSettingsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self displayContentController:self.accountSettingsNavigationController];
}

- (void) accountSettingsWereDismissed
{
    [self displayContentController:self.gamePickersTabBarController];
}

- (void) logoutWasRequested
{
    [self displayContentController:self.gamePickersTabBarController];
    [delegate logoutWasRequested];
}

@end

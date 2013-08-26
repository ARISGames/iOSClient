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
#import "ARISNavigationController.h"
#import "UIColor+ARISColors.h"

@interface GamePickersViewController () <UITabBarControllerDelegate, GamePickerViewControllerDelegate, GameDetailsViewControllerDelegate, AccountSettingsViewControllerDelegate>
{
    UITabBarController *gamePickersTabBarController;
    ARISNavigationController *gameDetailsNavigationController;
    ARISNavigationController *accountSettingsNavigationController;
    
    id<GamePickersViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) UITabBarController *gamePickersTabBarController;
@property (nonatomic, strong) ARISNavigationController *gameDetailsNavigationController;
@property (nonatomic, strong) ARISNavigationController *accountSettingsNavigationController;

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
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight);

    
    //Nearby Games
    GamePickerNearbyViewController *gamePickerNearbyViewController = [[GamePickerNearbyViewController alloc] initWithDelegate:self];
    ARISNavigationController *gamePickerNearbyNC = [[ARISNavigationController alloc] initWithRootViewController:gamePickerNearbyViewController];
    
    //Search Games
    GamePickerSearchViewController *gamePickerSearchVC = [[GamePickerSearchViewController alloc] initWithDelegate:self];
    ARISNavigationController *gamePickerSearchNC = [[ARISNavigationController alloc] initWithRootViewController:gamePickerSearchVC];
    
    //Popular Games
    GamePickerPopularViewController *gamePickerPopularVC = [[GamePickerPopularViewController alloc] initWithDelegate:self];
    ARISNavigationController *gamePickerPopularNC = [[ARISNavigationController alloc] initWithRootViewController:gamePickerPopularVC];
    
    //Recent Games
    GamePickerRecentViewController *gamePickerRecentVC = [[GamePickerRecentViewController alloc] initWithDelegate:self];
    ARISNavigationController *gamePickerRecentNC = [[ARISNavigationController alloc] initWithRootViewController:gamePickerRecentVC];
    
    //Setup the Game Selection Tab Bar
    self.gamePickersTabBarController = [[UITabBarController alloc] init];
    self.gamePickersTabBarController.delegate = self;
    self.gamePickersTabBarController.viewControllers = [NSMutableArray arrayWithObjects:
                                                       gamePickerNearbyNC,
                                                       gamePickerSearchNC,
                                                       gamePickerPopularNC,
                                                       gamePickerRecentNC,
                                                       nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!currentChildViewController)
        [self displayContentController:self.gamePickersTabBarController];
}

- (void) resetState
{
    [self displayContentController:self.gamePickersTabBarController];
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
    [self displayContentController:self.gamePickersTabBarController];
}

- (void) gameDetailsWereConfirmed:(Game *)g
{
    [delegate gamePickedForPlay:g];
}

- (void) accountSettingsRequested
{
    AccountSettingsViewController *accountSettingsViewController = [[AccountSettingsViewController alloc] initWithDelegate:self];
    self.accountSettingsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:accountSettingsViewController];
    [self displayContentController:self.accountSettingsNavigationController];
}

- (void) playerSettingsRequested
{
    [delegate playerSettingsRequested];
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

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

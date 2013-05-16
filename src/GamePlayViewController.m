//
//  GamePlayViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/2/13.
//
//

#import "RootViewController.h"
#import "AppServices.h"

#import "WebPageViewController.h"
#import "NoteDetailsViewController.h"

//PHIL APPROVED IMPORTS
#import "GamePlayViewController.h"
#import "StateControllerProtocol.h"
#import "Game.h"

#import "LoadingViewController.h"
#import "TutorialViewController.h"
#import "GameNotificationViewController.h"

#import "QuestsViewController.h"
#import "IconQuestsViewController.h"
#import "InventoryViewController.h"
#import "MapViewController.h"
#import "AttributesViewController.h"
#import "NotebookViewController.h"
#import "DecoderViewController.h"
#import "BogusSelectGameViewController.h"
#import "NearbyObjectsViewController.h"

#import "ARISAlertHandler.h"

#import "ARISNavigationController.h"

@interface GamePlayViewController() <UITabBarControllerDelegate, UINavigationControllerDelegate, StateControllerProtocol, LoadingViewControllerDelegate, GameObjectViewControllerDelegate, GamePlayTabBarViewControllerDelegate, NearbyObjectsViewControllerDelegate, QuestsViewControllerDelegate, MapViewControllerDelegate, InventoryViewControllerDelegate, AttributesViewControllerDelegate, NotebookViewControllerDelegate, DecoderViewControllerDelegate, BogusSelectGameViewControllerDelegate>
{
    Game *game;

    LoadingViewController *loadingViewController;
    UITabBarController *gamePlayTabBarController;
    
    TutorialViewController *tutorialViewController;
    GameNotificationViewController *gameNotificationViewController;
    
    ARISNavigationController *nearbyObjectsNavigationController;
    ARISNavigationController *arNavigationController;
    ARISNavigationController *questsNavigationController;
    ARISNavigationController *mapNavigationController;
    ARISNavigationController *inventoryNavigationController;
    ARISNavigationController *attributesNavigationController;
    ARISNavigationController *notesNavigationController;
    ARISNavigationController *decoderNavigationController;
    BogusSelectGameViewController *bogusSelectGameViewController;

    id<GamePlayViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) Game *game;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, strong) UITabBarController *gamePlayTabBarController;
@property (nonatomic, strong) TutorialViewController *tutorialViewController;
@property (nonatomic, strong) GameNotificationViewController *gameNotificationViewController;
@property (nonatomic, strong) ARISNavigationController *nearbyObjectsNavigationController;
@property (nonatomic, strong) ARISNavigationController *arNavigationController;
@property (nonatomic, strong) ARISNavigationController *questsNavigationController;
@property (nonatomic, strong) ARISNavigationController *mapNavigationController;
@property (nonatomic, strong) ARISNavigationController *inventoryNavigationController;
@property (nonatomic, strong) ARISNavigationController *attributesNavigationController;
@property (nonatomic, strong) ARISNavigationController *notesNavigationController;
@property (nonatomic, strong) ARISNavigationController *decoderNavigationController;
@property (nonatomic, strong) BogusSelectGameViewController *bogusSelectGameViewController;

@end

@implementation GamePlayViewController

@synthesize game;
@synthesize loadingViewController;
@synthesize gamePlayTabBarController;
@synthesize tutorialViewController;
@synthesize gameNotificationViewController;
@synthesize nearbyObjectsNavigationController;
@synthesize arNavigationController;
@synthesize questsNavigationController;
@synthesize mapNavigationController;
@synthesize inventoryNavigationController;
@synthesize attributesNavigationController;
@synthesize notesNavigationController;
@synthesize decoderNavigationController;
@synthesize bogusSelectGameViewController;

- (id) initWithGame:(Game *)g delegate:(id<GamePlayViewControllerDelegate>)d
{
    if(self = [super init])
    {        
        delegate = d;
        self.game = g;
        
        //PHIL HATES THIS CHUNK
        [AppModel sharedAppModel].currentGame = self.game;
        [AppModel sharedAppModel].fallbackGameId = self.game.gameId;
        [[AppModel sharedAppModel] saveUserDefaults];
        //PHIL DONE HATING CHUNK
        
        [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:NSLocalizedString(@"LoadingKey",@"")];

        tutorialViewController         = [[TutorialViewController         alloc] init];
        gameNotificationViewController = [[GameNotificationViewController alloc] init];
        
        //PHIL UNAPPROVED
        [[AppServices sharedAppServices] resetAllPlayerLists];
        [[AppServices sharedAppServices] resetAllGameLists];
        [[AppServices sharedAppServices] resetCurrentlyFetchingVars];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForDisplayCompleteNode) name:@"NewlyCompletedQuestsAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMediaList)           name:@"ReceivedMediaList"             object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameTabListRecieved:)        name:@"ReceivedTabList"               object:nil];
        //END PHIL UNAPPROVED
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    tutorialViewController.view.frame = self.view.frame;
    [self.view addSubview:tutorialViewController.view];
    gameNotificationViewController.view.frame = self.view.frame;
    [self.view addSubview:gameNotificationViewController.view];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!currentChildViewController)
    {
        self.loadingViewController = [[LoadingViewController alloc] initWithDelegate:self];
        [self displayContentController:self.loadingViewController];
        [self startLoadingGame];
    }
}

- (void) startLoadingGame
{
    [self.game getReadyToPlay];
    [[AppServices sharedAppServices] fetchAllGameLists];
    
    //PHIL HATES THIS CHUNK
	[[AppServices sharedAppServices] updateServerGameSelected];
    [AppModel sharedAppModel].hasReceivedMediaList = NO;
    //PHIL DONE HATING CHUNK
}

- (void) loadingViewControllerDidComplete
{    
    [self displayContentController:self.gamePlayTabBarController];
    self.loadingViewController = nil;
    [[ARISAlertHandler sharedAlertHandler] removeWaitingIndicator];
    
    //PHIL UNAPPROVED -
    [self beginGamePlay];
}

- (void) gameDismisallWasRequested
{
    [tutorialViewController dismissTutorials];

    [gameNotificationViewController stopListeningToModel];
    [gameNotificationViewController cutOffGameNotifications];
    [self.game clearLocalModels];
    //PHIL UNAPPROVED - 
    [AppModel sharedAppModel].currentGame = nil;
    [delegate gameplayWasDismissed];
}

- (void) dismissTutorial
{
    [tutorialViewController dismissTutorials];
}

- (void) showTutorialPopupPointingToTabForViewController:(ARISGamePlayTabBarViewController *)vc title:(NSString *)title message:(NSString *)message
{
    [tutorialViewController showTutorialPopupPointingToTabForViewController:vc title:title message:message];
}

//PHIL UNAPPROVED FROM THIS POINT ON

- (void) hideNearbyObjectsTab
{
    NSMutableArray *tabs = [NSMutableArray arrayWithArray:self.gamePlayTabBarController.viewControllers];
    
    if([tabs containsObject:self.nearbyObjectsNavigationController])
        [tabs removeObject:self.nearbyObjectsNavigationController];
    
    [self.gamePlayTabBarController setViewControllers:tabs animated:NO];
    
    NSLog(@"NSNotification: TabBarItemsChanged");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TabBarItemsChanged" object:self userInfo:nil]];
}

- (void) showNearbyObjectsTab
{
    NSMutableArray *tabs = [NSMutableArray arrayWithArray:self.gamePlayTabBarController.viewControllers];
    
    if(![tabs containsObject:self.nearbyObjectsNavigationController])
        [tabs insertObject:self.nearbyObjectsNavigationController atIndex:0];
    
    [self.gamePlayTabBarController setViewControllers:tabs animated:NO];
    
    NSLog(@"NSNotification: TabBarItemsChanged");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TabBarItemsChanged" object:self userInfo:nil]];
}

- (void) gameTabListRecieved:(NSNotification *)n
{
    [self setGamePlayTabBarVCsFromTabList:[n.userInfo objectForKey:@"tabs"]];
}

- (void) setGamePlayTabBarVCsFromTabList:(NSArray *)gamePlayTabs
{
    gamePlayTabs = [gamePlayTabs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"tabIndex" ascending:YES]]];

    self.gamePlayTabBarController = [[UITabBarController alloc] init];
    self.gamePlayTabBarController.delegate = self;
    
    //Special case- always should get inited (yet not added to the gameplay tabbar until specified)
    NearbyObjectsViewController *nearbyObjectsViewController = [[NearbyObjectsViewController alloc] initWithDelegate:self];
    self.nearbyObjectsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:nearbyObjectsViewController];
    self.nearbyObjectsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    NSMutableArray *gamePlayTabVCs  = [[NSMutableArray alloc] initWithCapacity:10];
    Tab *tmpTab;
    for(int i = 0; i < [gamePlayTabs count]; i++)
    {
        tmpTab = [gamePlayTabs objectAtIndex:i];
        if(tmpTab.tabIndex < 1) continue;
        
        if ([tmpTab.tabName isEqualToString:@"QUESTS"])
        {
            //if uses icon quest view
            if((BOOL)tmpTab.tabDetail1)
            {
                IconQuestsViewController *iconQuestsViewController = [[IconQuestsViewController alloc] initWithDelegate:self];
                self.questsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:iconQuestsViewController];
                self.questsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
                [gamePlayTabVCs addObject:self.questsNavigationController];
            }
            else
            {
                QuestsViewController *questsViewController = [[QuestsViewController alloc] initWithDelegate:self];
                self.questsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:questsViewController];
                self.questsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
                [gamePlayTabVCs addObject:self.questsNavigationController];
            }
        }
        else if([tmpTab.tabName isEqualToString:@"GPS"])
        {
            MapViewController *mapViewController = [[MapViewController alloc] initWithDelegate:self];
            self.mapNavigationController = [[ARISNavigationController alloc] initWithRootViewController:mapViewController];
            self.mapNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
            [gamePlayTabVCs addObject:self.mapNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"INVENTORY"])
        {
            InventoryViewController *inventoryListViewController = [[InventoryViewController alloc] initWithDelegate:self];
            self.inventoryNavigationController = [[ARISNavigationController alloc] initWithRootViewController:inventoryListViewController];
            self.inventoryNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
            [gamePlayTabVCs addObject:self.inventoryNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"QR"])
        {
            DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithDelegate:self];
            self.decoderNavigationController = [[ARISNavigationController alloc] initWithRootViewController:decoderViewController];
            self.decoderNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
            [gamePlayTabVCs addObject:self.decoderNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"PLAYER"])
        {
            AttributesViewController *attributesViewController = [[AttributesViewController alloc] initWithDelegate:self];
            self.attributesNavigationController = [[ARISNavigationController alloc] initWithRootViewController:attributesViewController];
            self.attributesNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
            [gamePlayTabVCs addObject:self.attributesNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"NOTE"])
        {
            NotebookViewController *notesViewController = [[NotebookViewController alloc] initWithDelegate:self];
            self.notesNavigationController = [[ARISNavigationController alloc] initWithRootViewController:notesViewController];
            self.notesNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
            [gamePlayTabVCs addObject:self.notesNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"AR"])
        {
            //ARViewViewControler *arViewController = [[[ARViewViewControler alloc] initWithNibName:@"ARView" bundle:nil] autorelease];
            //self.arNavigationController = [[ARISNavigationController alloc] initWithRootViewController: arViewController];
            //self.arNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
            //[gamePlayTabVCs addObject:self.arNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"PICKGAME"] && ![AppModel sharedAppModel].disableLeaveGame)
        {
            self.bogusSelectGameViewController = [[BogusSelectGameViewController alloc] initWithDelegate:self];
            [gamePlayTabVCs addObject:self.bogusSelectGameViewController];
        }
    }
    
    self.gamePlayTabBarController.viewControllers = [NSArray arrayWithArray:gamePlayTabVCs];
    self.gamePlayTabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.gamePlayTabBarController.moreNavigationController.delegate = self;
    self.gamePlayTabBarController.selectedIndex = 0;
}

- (void) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
	ARISNavigationController *nav = [[ARISNavigationController alloc] initWithRootViewController:[g viewControllerForDelegate:self fromSource:s]];
	nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [self presentModalViewController:nav animated:NO];
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [govc.navigationController dismissModalViewControllerAnimated:NO];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[AppModel sharedAppModel].mediaCache clearCache];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//PHIL REALLY UNAPPROVED FROM THIS POINT ON

- (void)beginGamePlay
{
    NSLog(@"GamePlayViewController: beginGamePlay");
    
    [gameNotificationViewController startListeningToModel];
    [[AppServices sharedAppServices] fetchAllPlayerLists];
    
    int nodeId = [AppModel sharedAppModel].currentGame.launchNodeId;
    if(nodeId && nodeId != 0 && [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] < 1)
        [self displayGameObject:[[AppModel sharedAppModel] nodeForNodeId:nodeId] fromSource:self];
}

- (void)checkForDisplayCompleteNode
{
    int nodeId = [AppModel sharedAppModel].currentGame.completeNodeId;
    if (nodeId != 0 &&
        [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] == [AppModel sharedAppModel].currentGame.questsModel.totalQuestsInGame &&
        [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] > 0)
    {
        [self displayGameObject:[[AppModel sharedAppModel] nodeForNodeId:nodeId] fromSource:self];
	}
}

- (void)receivedMediaList
{
    [AppModel sharedAppModel].hasReceivedMediaList = YES;
}

#pragma mark UITabBarControllerDelegate methods

- (void) gamePlayTabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"RootViewController: gamePlayTabBarController didSelectViewController");
    
    [tabBar.moreNavigationController popToRootViewControllerAnimated:NO];
    
	//Hide any popups
	if([viewController respondsToSelector:@selector(visibleViewController)])
    {
		UIViewController *vc = [viewController performSelector:@selector(rootViewController)];
		if([vc respondsToSelector:@selector(dismissTutorial)])
			[vc performSelector:@selector(dismissTutorial)];
	}
}

@end

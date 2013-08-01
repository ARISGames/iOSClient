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

#import "UIColor+ARISColors.h"

#import "ARISAlertHandler.h"

#import "ARISNavigationController.h"

@interface GamePlayViewController() <UITabBarControllerDelegate, UINavigationControllerDelegate, StateControllerProtocol, LoadingViewControllerDelegate, GameObjectViewControllerDelegate, GamePlayTabBarViewControllerDelegate, NearbyObjectsViewControllerDelegate, QuestsViewControllerDelegate, MapViewControllerDelegate, InventoryViewControllerDelegate, AttributesViewControllerDelegate, NotebookViewControllerDelegate, DecoderViewControllerDelegate, BogusSelectGameViewControllerDelegate>
{
    Game *game;

    LoadingViewController *loadingViewController;
    UITabBarController *gamePlayTabBarController;
    
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

        self.gameNotificationViewController = [[GameNotificationViewController alloc] init];
        
        //PHIL UNAPPROVED
        [[AppServices sharedAppServices] resetAllPlayerLists];
        [[AppServices sharedAppServices] resetAllGameLists];
        [[AppServices sharedAppServices] resetCurrentlyFetchingVars];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForDisplayCompleteNode) name:@"NewlyCompletedQuestsAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameTabListRecieved:)        name:@"ReceivedTabList"               object:nil];
        //END PHIL UNAPPROVED
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.gameNotificationViewController.view.frame = self.view.frame;
    [self.view addSubview:self.gameNotificationViewController.view];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight);
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
    //PHIL DONE HATING CHUNK
}

- (void) loadingViewControllerFinishedLoadingGameData
{
    [[AppServices sharedAppServices] fetchAllPlayerLists];
}

- (void) loadingViewControllerFinishedLoadingPlayerData
{
    //Nada
}

- (void) loadingViewControllerFinishedLoadingData
{
    [self displayContentController:self.gamePlayTabBarController];
    self.loadingViewController = nil;
    [[ARISAlertHandler sharedAlertHandler] removeWaitingIndicator];
    
    //PHIL UNAPPROVED -
    [self beginGamePlay];
}

- (void) gameDismisallWasRequested
{
    [self.gameNotificationViewController stopListeningToModel];
    [self.gameNotificationViewController cutOffGameNotifications];
    [self.game clearLocalModels];
    //PHIL UNAPPROVED - 
    [AppModel sharedAppModel].currentGame = nil;
    [delegate gameplayWasDismissed];
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
        
        if([tmpTab.tabName isEqualToString:@"QUESTS"])
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
    self.gamePlayTabBarController.tabBar.selectedImageTintColor = [UIColor ARISColorScarlet];
    
    self.gamePlayTabBarController.selectedIndex = 0;
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    ARISGamePlayTabBarViewController *vc;
    ARISNavigationController *nc;
    for(int i = 0; i < [self.gamePlayTabBarController.viewControllers count]; i++)
    {
        nc = [self.gamePlayTabBarController.viewControllers objectAtIndex:i];
        vc = [[nc childViewControllers] objectAtIndex:0];
        if([vc.tabID isEqualToString:@"QR"])
        {
            self.gamePlayTabBarController.selectedIndex = i;
            [(DecoderViewController *)vc launchScannerWithPrompt:p];
        }
    }
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    if(!self.isViewLoaded || !self.view.window) return NO; //Doesn't currently have the view-heirarchy authority to display. Return that it failed to those who care

	ARISNavigationController *nav = [[ARISNavigationController alloc] initWithRootViewController:[g viewControllerForDelegate:self fromSource:s]];
	nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [self presentViewController:nav animated:NO completion:nil];
    //Phil hates that the frame changes depending on what view you add it to...
    self.gameNotificationViewController.view.frame = CGRectMake(self.gameNotificationViewController.view.frame.origin.x, 
                                                                self.gameNotificationViewController.view.frame.origin.y+20,
                                                                self.gameNotificationViewController.view.frame.size.width,
                                                                self.gameNotificationViewController.view.frame.size.height);
    [nav.view addSubview:self.gameNotificationViewController.view];//always put notifs on top //Phil doesn't LOVE this, but can't think of anything better...
    
    return YES;
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [govc.navigationController dismissViewControllerAnimated:NO completion:nil];
    //Phil hates that the frame changes depending on what view you add it to...
    self.gameNotificationViewController.view.frame = CGRectMake(self.gameNotificationViewController.view.frame.origin.x,
                                                                self.gameNotificationViewController.view.frame.origin.y-20,
                                                                self.gameNotificationViewController.view.frame.size.width,
                                                                self.gameNotificationViewController.view.frame.size.height);
    [self.view addSubview:self.gameNotificationViewController.view];//always put notifs on top //Phil doesn't LOVE this, but can't think of anything better...
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//PHIL REALLY UNAPPROVED FROM THIS POINT ON

- (void) beginGamePlay
{
    NSLog(@"GamePlayViewController: beginGamePlay");
    self.gameNotificationViewController.view.frame = CGRectMake(0,0,0,0);
    [self.view addSubview:self.gameNotificationViewController.view];
    [self.gameNotificationViewController startListeningToModel];
        
    int nodeId = [AppModel sharedAppModel].currentGame.launchNodeId;
    if(nodeId && nodeId != 0 && [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] < 1)
        [self displayGameObject:[[AppModel sharedAppModel] nodeForNodeId:nodeId] fromSource:self];
}

- (void) checkForDisplayCompleteNode
{
    int nodeId = [AppModel sharedAppModel].currentGame.completeNodeId;
    if(nodeId != 0 &&
        [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] == [AppModel sharedAppModel].currentGame.questsModel.totalQuestsInGame &&
        [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] > 0)
    {
        [self displayGameObject:[[AppModel sharedAppModel] nodeForNodeId:nodeId] fromSource:self];
	}
}

- (void) displayTab:(NSString *)t
{
    NSString *localized = [t lowercaseString];
    if([localized isEqualToString:@"map"])       localized = [NSLocalizedString(@"MapViewTitleKey",       @"") lowercaseString];
    if([localized isEqualToString:@"quests"])    localized = [NSLocalizedString(@"QuestViewTitleKey",     @"") lowercaseString];
    if([localized isEqualToString:@"notebook"])  localized = [NSLocalizedString(@"NotebookTitleKey",      @"") lowercaseString];
    if([localized isEqualToString:@"inventory"]) localized = [NSLocalizedString(@"InventoryViewTitleKey", @"") lowercaseString];
    if([localized isEqualToString:@"decoder"])   localized = [NSLocalizedString(@"QRScannerTitleKey",     @"") lowercaseString];
    if([localized isEqualToString:@"player"])    localized = [NSLocalizedString(@"PlayerTitleKey",        @"") lowercaseString];

    for(int i = 0; i < [self.gamePlayTabBarController.viewControllers count]; i++)
    {
        if([[((GamePlayViewController *)[self.gamePlayTabBarController.viewControllers objectAtIndex:i]).title lowercaseString] isEqualToString:localized])
            self.gamePlayTabBarController.selectedIndex = i;
    }
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController 
{
    if(tabBarController.selectedIndex > 3 && [tabBarController.viewControllers count] > 5)
    {
        [tabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
        NSLog(@"GamePlayTabBarController: Selected tab- More");
    }
    else
        NSLog(@"GamePlayTabBarController: Selected tab- %@", ((GamePlayViewController *)[tabBarController.viewControllers objectAtIndex:tabBarController.selectedIndex]).title);
}

- (NSInteger) supportedInterfaceOrientations
{
    if(self.gamePlayTabBarController.selectedIndex > 3 && self.gamePlayTabBarController.selectedIndex < 6)
        return [self.gamePlayTabBarController.moreNavigationController.topViewController supportedInterfaceOrientations];
    else if(self.gamePlayTabBarController.selectedIndex <= 3)
        return [self.gamePlayTabBarController.selectedViewController supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}

@end

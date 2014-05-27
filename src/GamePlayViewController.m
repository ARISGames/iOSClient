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
//#import "NoteDetailsViewController.h"

//#import "Location.h"

//needed for orientation hack
#import "AudioVisualizerViewController.h"

//PHIL APPROVED IMPORTS
#import "GamePlayViewController.h"
#import "StateControllerProtocol.h"
#import "Game.h"

#import "LoadingViewController.h"
#import "GameNotificationViewController.h"

#import "QuestsViewController.h"
#import "IconQuestsViewController.h"
#import "InventoryTagViewController.h"
#import "MapViewController.h"
#import "AttributesViewController.h"
#import "NotebookViewController.h"
#import "DecoderViewController.h"
#import "GamePlayTabSelectorViewController.h"
#import "PKRevealController.h"

#import "ForceDisplayQueue.h"

#import "ARISAlertHandler.h"
#import "ARISNavigationController.h"
#import "ARISTemplate.h"

//dynamic navigation controllers
#import "NpcViewController.h"
#import "Npc.h"
#import "Item.h"
#import "ItemViewController.h"
#import "NodeViewController.h"
#import "WebPage.h"
#import "WebPageViewController.h"

@interface GamePlayViewController() <UINavigationControllerDelegate, GamePlayTabSelectorViewControllerDelegate, StateControllerProtocol, LoadingViewControllerDelegate, GameObjectViewControllerDelegate, GamePlayTabBarViewControllerDelegate, QuestsViewControllerDelegate, MapViewControllerDelegate, InventoryViewControllerDelegate, AttributesViewControllerDelegate, NotebookViewControllerDelegate, DecoderViewControllerDelegate, GameNotificationViewControllerDelegate, ForceDisplayQueueDelegate>
{
    Game *game;

    LoadingViewController *loadingViewController;
    PKRevealController *gamePlayRevealController;
    GamePlayTabSelectorViewController *gamePlayTabSelectorController;
    
    GameNotificationViewController *gameNotificationViewController;
    
    ARISNavigationController *arNavigationController;
    ARISNavigationController *questsNavigationController;
    ARISNavigationController *mapNavigationController;
    ARISNavigationController *inventoryNavigationController;
    ARISNavigationController *attributesNavigationController;
    ARISNavigationController *notesNavigationController;
    ARISNavigationController *decoderNavigationController;
    ARISNavigationController *scannerNavigationController;
    
    //dynamic navigation controllers
    ARISNavigationController *npcNavigationController;
    ARISNavigationController *itemNavigationController;
    ARISNavigationController *nodeNavigationController;
    ARISNavigationController *webPageNavigationController;
    
    NSMutableArray *gamePlayTabVCs;
    
    ForceDisplayQueue *forceDisplayQueue;
    
    NSTimer *timeout;
    NSTimer *refreshTimer;

    id<GamePlayViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation GamePlayViewController

- (id) initWithGame:(Game *)g delegate:(id<GamePlayViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        game = g;
        
        //PHIL HATES THIS CHUNK
        [AppModel sharedAppModel].currentGame = game;
        [AppModel sharedAppModel].fallbackGameId = game.gameId;
        [[AppModel sharedAppModel] saveUserDefaults];
        //PHIL DONE HATING CHUNK
        
        [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:NSLocalizedString(@"LoadingKey",@"")];

        gameNotificationViewController = [[GameNotificationViewController alloc] initWithDelegate:self];
        
        //PHIL UNAPPROVED
        [[AppModel sharedAppModel] resetAllPlayerLists];
        [[AppModel sharedAppModel] resetAllGameLists];
        
        forceDisplayQueue = [[ForceDisplayQueue alloc] initWithDelegate:self];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForDisplayCompleteNode) name:@"NewlyCompletedQuestsAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameTabListRecieved:)        name:@"ReceivedTabList"               object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedTabListReceived:) name:@"ReceivedUpdatedTabList" object:nil];
        //END PHIL UNAPPROVED
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    gameNotificationViewController.view.frame = self.view.frame;
    [self.view addSubview:gameNotificationViewController.view];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!currentChildViewController)
    {
        loadingViewController = [[LoadingViewController alloc] initWithDelegate:self];
        timeout = [NSTimer scheduledTimerWithTimeInterval:15.0
                                         target:self
                                    selector:@selector(timeoutOfGameLoading)
                                       userInfo:nil
                                        repeats:NO];
        [self displayContentController:loadingViewController];
        [self startLoadingGame];
        if(refreshTimer && [refreshTimer isValid]) [refreshTimer invalidate];
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
}

- (void) refresh
{
    [[AppServices sharedAppServices] fetchUpdatedTabBarItems];
}

- (void) startLoadingGame
{
    [game getReadyToPlay];
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
    [timeout invalidate];
    [self displayContentController:gamePlayRevealController];
    loadingViewController = nil;
    [[ARISAlertHandler sharedAlertHandler] removeWaitingIndicator];
    
    //PHIL UNAPPROVED -
    [self beginGamePlay];
}

- (void) gameRequestsDismissal
{
    [gameNotificationViewController stopListeningToModel];
    [gameNotificationViewController cutOffGameNotifications];
    [game clearLocalModels];
    [game endPlay]; 
    //PHIL UNAPPROVED - 
    [AppModel sharedAppModel].currentGame = nil;
    [delegate gameplayWasDismissed];
}

//PHIL UNAPPROVED FROM THIS POINT ON

- (void) gameTabListRecieved:(NSNotification *)n
{
    [self setGamePlayTabBarVCsFromTabList:[n.userInfo objectForKey:@"tabs"]];
}

- (void) updatedTabListReceived:(NSNotification *)n
{
    NSArray *gamePlayTabs = [n.userInfo objectForKey:@"tabs"];
    gamePlayTabVCs = [self parseGameTabControllers:gamePlayTabs];
    gamePlayTabSelectorController.viewControllers = gamePlayTabVCs;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTabTable" object:self];
}

- (void) setGamePlayTabBarVCsFromTabList:(NSArray *)gamePlayTabs
{
    gamePlayTabVCs = [self parseGameTabControllers:gamePlayTabs];
    gamePlayTabSelectorController = [[GamePlayTabSelectorViewController alloc] initWithViewControllers:gamePlayTabVCs delegate:self];
    gamePlayRevealController = [PKRevealController revealControllerWithFrontViewController:[gamePlayTabVCs objectAtIndex:0] leftViewController:gamePlayTabSelectorController options:nil];
}

- (NSMutableArray *) parseGameTabControllers:(NSArray *)gamePlayTabs
{
    gamePlayTabs = [gamePlayTabs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"tabIndex" ascending:YES]]];
    
    NSMutableArray *tempGamePlayTabVCs = [[NSMutableArray alloc] initWithCapacity:10];
    
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
                questsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:iconQuestsViewController];
                [tempGamePlayTabVCs addObject:questsNavigationController];
            }
            else
            {
                QuestsViewController *questsViewController = [[QuestsViewController alloc] initWithDelegate:self];
                questsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:questsViewController];
                [tempGamePlayTabVCs addObject:questsNavigationController];
            }
        }
        else if([tmpTab.tabName isEqualToString:@"GPS"])
        {
            MapViewController *mapViewController = [[MapViewController alloc] initWithDelegate:self];
            mapNavigationController = [[ARISNavigationController alloc] initWithRootViewController:mapViewController];
            [tempGamePlayTabVCs addObject:mapNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"INVENTORY"])
        {
            InventoryTagViewController *inventoryTagViewController = [[InventoryTagViewController alloc] initWithDelegate:self];
            inventoryNavigationController = [[ARISNavigationController alloc] initWithRootViewController:inventoryTagViewController];
            [tempGamePlayTabVCs addObject:inventoryNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"DECODER"]) //text only
        {
            DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithDelegate:self inMode:1];
            decoderNavigationController = [[ARISNavigationController alloc] initWithRootViewController:decoderViewController];
            [tempGamePlayTabVCs addObject:decoderNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"QR"]) //will be scanner only- supports both for legacy
        {
            DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithDelegate:self inMode:tmpTab.tabDetail1];
            scannerNavigationController = [[ARISNavigationController alloc] initWithRootViewController:decoderViewController];
            [tempGamePlayTabVCs addObject:scannerNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"PLAYER"])
        {
            AttributesViewController *attributesViewController = [[AttributesViewController alloc] initWithDelegate:self];
            attributesNavigationController = [[ARISNavigationController alloc] initWithRootViewController:attributesViewController];
            [tempGamePlayTabVCs addObject:attributesNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"NOTE"])
        {
            NotebookViewController *notesViewController = [[NotebookViewController alloc] initWithDelegate:self];
            notesNavigationController = [[ARISNavigationController alloc] initWithRootViewController:notesViewController];
            [tempGamePlayTabVCs addObject:notesNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"AR"])
        {
            //ARViewViewControler *arViewController = [[[ARViewViewControler alloc] initWithNibName:@"ARView" bundle:nil] autorelease];
            //arNavigationController = [[ARISNavigationController alloc] initWithRootViewController: arViewController];
            //[tempGamePlayTabVCs addObject:arNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"NPC"])
        {
            //there is a possible race condition here when the npc is not in the model
            Npc *npc = [[AppModel sharedAppModel].currentGame.npcList objectForKey:[NSNumber numberWithInt:tmpTab.tabDetail1]];
            NpcViewController *npcViewController = [[NpcViewController alloc] initWithNpc:npc delegate:self];
            npcNavigationController = [[ARISNavigationController alloc] initWithRootViewController:npcViewController];
            [tempGamePlayTabVCs addObject:npcNavigationController];
        }
        else if ([tmpTab.tabName isEqualToString:@"ITEM"])
        {
            //there is a possible race condition here when the item is not in the model
            Item *item = [[AppModel sharedAppModel].currentGame.itemList objectForKey:[NSNumber numberWithInt:tmpTab.tabDetail1]];
            ItemViewController *itemViewController = [[ItemViewController alloc] initWithItem:item delegate:self source:nil];
            itemNavigationController = [[ARISNavigationController alloc] initWithRootViewController:itemViewController];
            [tempGamePlayTabVCs addObject:itemNavigationController];
        }
        else if ([tmpTab.tabName isEqualToString:@"NODE"])
        {
            //there is a possible race condition here when the plaque is not in the model
            Node *node = [[AppModel sharedAppModel].currentGame.nodeList objectForKey:[NSNumber numberWithInt:tmpTab.tabDetail1]];
            NodeViewController *nodeViewController = [[NodeViewController alloc] initWithNode:node delegate:self];
            nodeNavigationController = [[ARISNavigationController alloc] initWithRootViewController:nodeViewController];
            [tempGamePlayTabVCs addObject:nodeNavigationController];
        }
        else if ([tmpTab.tabName isEqualToString:@"WEBPAGE"])
        {
            //there is a possible race condition here when the web page is not in the model
            WebPage *webPage = [[AppModel sharedAppModel].currentGame.webpageList objectForKey:[NSNumber numberWithInt:tmpTab.tabDetail1]];
            WebPageViewController *webPageViewController = [[WebPageViewController alloc] initWithWebPage:webPage delegate:self];
            webPageNavigationController = [[ARISNavigationController alloc] initWithRootViewController:webPageViewController];
            [tempGamePlayTabVCs addObject:webPageNavigationController];
        }
    }
    return tempGamePlayTabVCs;
}

- (void) gamePlayTabBarViewControllerRequestsNav
{
    [gamePlayRevealController showViewController:gamePlayTabSelectorController];
}

- (void) viewControllerRequestedDisplay:(ARISNavigationController *)avc
{
    [gamePlayRevealController setFrontViewController:avc];
    [gamePlayRevealController showViewController:avc];
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    if(scannerNavigationController)
    {
        [(DecoderViewController *)[[scannerNavigationController viewControllers] objectAtIndex:0] setPrompt:p]; 
        [self viewControllerRequestedDisplay:scannerNavigationController];
    }
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    if(!self.isViewLoaded || !self.view.window) return NO; //Doesn't currently have the view-heirarchy authority to display. Return that it failed to those who care

	ARISNavigationController *nav = [[ARISNavigationController alloc] initWithRootViewController:[g viewControllerForDelegate:self fromSource:s]];
    [self presentViewController:nav animated:NO completion:nil];
    //Phil hates that the frame changes depending on what view you add it to...
    gameNotificationViewController.view.frame = CGRectMake(gameNotificationViewController.view.frame.origin.x, 
                                                                gameNotificationViewController.view.frame.origin.y+20,
                                                                gameNotificationViewController.view.frame.size.width,
                                                                gameNotificationViewController.view.frame.size.height);
    [nav.view addSubview:gameNotificationViewController.view];//always put notifs on top //Phil doesn't LOVE this, but can't think of anything better...
    
    if([s isKindOfClass:[Location class]])
    {
        [[AppServices sharedAppServices] updateServerLocationViewed:((Location *)s).locationId];
        
        if(((Location *)s).deleteWhenViewed)
            [game.locationsModel removeLocation:s];
    }
    
    return YES;
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    //first check if the navigation controller is part of the tabs
    BOOL dismissTab = NO;
    for (int i = 0; i < [gamePlayTabVCs count]; i++)
    {
        if ([govc.navigationController isEqual:[gamePlayTabVCs objectAtIndex:i]])
        {
            dismissTab = YES;
        }
    }
    
    if (dismissTab)
    {
        //this will need to change to be the proper tab
        [self displayTab:@"MAP"];
    }
    else
    {
        [govc.navigationController dismissViewControllerAnimated:NO completion:nil];
        //Phil hates that the frame changes depending on what view you add it to...
        gameNotificationViewController.view.frame = CGRectMake(gameNotificationViewController.view.frame.origin.x,
                                                               gameNotificationViewController.view.frame.origin.y-20,
                                                               gameNotificationViewController.view.frame.size.width,
                                                               gameNotificationViewController.view.frame.size.height);
        [self.view addSubview:gameNotificationViewController.view];//always put notifs on top //Phil doesn't LOVE this, but can't think of anything better...
        [forceDisplayQueue forceDisplayEligibleLocations];
    }
    

}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//PHIL REALLY UNAPPROVED FROM THIS POINT ON

- (void) beginGamePlay
{
    NSLog(@"GamePlayViewController: beginGamePlay");
    gameNotificationViewController.view.frame = CGRectMake(0,0,0,0);
    [self.view addSubview:gameNotificationViewController.view];
    [gameNotificationViewController startListeningToModel];
        
    int nodeId = [AppModel sharedAppModel].currentGame.launchNodeId;
    if(nodeId && nodeId != 0 && [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] < 1)
        [self displayGameObject:[[AppModel sharedAppModel].currentGame nodeForNodeId:nodeId] fromSource:self];
}

- (void) checkForDisplayCompleteNode
{
    int nodeId = [AppModel sharedAppModel].currentGame.completeNodeId;
    if(nodeId != 0 &&
        [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] == [AppModel sharedAppModel].currentGame.questsModel.totalQuestsInGame &&
        [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests count] > 0)
    {
        [self displayGameObject:[[AppModel sharedAppModel].currentGame nodeForNodeId:nodeId] fromSource:self];
	}
}

- (void) displayTab:(NSString *)t
{
    NSString *localized = [t lowercaseString];
    ARISNavigationController *tab;
         if([localized isEqualToString:@"map"]       || [localized isEqualToString:[NSLocalizedString(@"MapViewTitleKey",       @"") lowercaseString]])
        tab = mapNavigationController;
    else if([localized isEqualToString:@"quests"]    || [localized isEqualToString:[NSLocalizedString(@"QuestViewTitleKey",     @"") lowercaseString]])
        tab = questsNavigationController;
    else if([localized isEqualToString:@"notebook"]  || [localized isEqualToString:[NSLocalizedString(@"NotebookTitleKey",      @"") lowercaseString]])
        tab = notesNavigationController;
    else if([localized isEqualToString:@"inventory"] || [localized isEqualToString:[NSLocalizedString(@"InventoryViewTitleKey", @"") lowercaseString]])
        tab = inventoryNavigationController;
    else if([localized isEqualToString:@"scanner"]   || [localized isEqualToString:[NSLocalizedString(@"QRScannerTitleKey",     @"") lowercaseString]])
        tab = scannerNavigationController;
    else if([localized isEqualToString:@"decoder"]   || [localized isEqualToString:[NSLocalizedString(@"QRScannerTitleKey",     @"") lowercaseString]])
        tab = decoderNavigationController; 
    else if([localized isEqualToString:@"player"]    || [localized isEqualToString:[NSLocalizedString(@"PlayerTitleKey",        @"") lowercaseString]])
        tab = attributesNavigationController;
    if(tab) [self viewControllerRequestedDisplay:tab];
    else
    {
        tab = [gamePlayTabVCs objectAtIndex:0];
        [self viewControllerRequestedDisplay:tab];
    }
    //it is possible the logic of the game dictated what tab was displayed and not the user, so we must tell the tableview to select that particular tab
    NSMutableDictionary *arisNavTab = [[NSMutableDictionary alloc] initWithCapacity:1];
    [arisNavTab setObject:tab forKey:@"tab"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TabWasDisplayed" object:self userInfo:arisNavTab];
}

- (void) timeoutOfGameLoading
{
    [delegate gameplayWasDismissed];
}

- (NSUInteger) supportedInterfaceOrientations
{
    //BAD BAD HACK
    if ([[notesNavigationController topViewController] isKindOfClass:[AudioVisualizerViewController class]]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end

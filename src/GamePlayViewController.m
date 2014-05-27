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

@interface GamePlayViewController() <UINavigationControllerDelegate, GamePlayTabSelectorViewControllerDelegate, StateControllerProtocol, GameObjectViewControllerDelegate, GamePlayTabBarViewControllerDelegate, QuestsViewControllerDelegate, MapViewControllerDelegate, InventoryViewControllerDelegate, AttributesViewControllerDelegate, NotebookViewControllerDelegate, DecoderViewControllerDelegate, GameNotificationViewControllerDelegate, ForceDisplayQueueDelegate>
{
    Game *game;

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
    
    ForceDisplayQueue *forceDisplayQueue;
    
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

        gameNotificationViewController = [[GameNotificationViewController alloc] initWithDelegate:self];
        
        //PHIL UNAPPROVED
        [_MODEL_GAME_ clearModels];
        
        forceDisplayQueue = [[ForceDisplayQueue alloc] initWithDelegate:self];

  _ARIS_NOTIF_LISTEN_(@"NewlyCompletedQuestsAvailable",self,@selector(checkForDisplayCompletePlaque),nil);
  _ARIS_NOTIF_LISTEN_(@"ReceivedTabList",self,@selector(gameTabListRecieved:),nil);
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
        [self displayContentController:gamePlayRevealController];
        [self beginGamePlay]; 
    }
}

- (void) gameRequestsDismissal
{
    [gameNotificationViewController stopListeningToModel];
    [gameNotificationViewController cutOffGameNotifications];
    [game clearModels];
    [game endPlay]; 
    //PHIL UNAPPROVED - 
    _MODEL_GAME_ = nil;
    [delegate gameplayWasDismissed];
}

//PHIL UNAPPROVED FROM THIS POINT ON

- (void) gameTabListRecieved:(NSNotification *)n
{
    [self setGamePlayTabBarVCsFromTabList:[n.userInfo objectForKey:@"tabs"]];
}

- (void) setGamePlayTabBarVCsFromTabList:(NSArray *)gamePlayTabs
{
    /*
    gamePlayTabs = [gamePlayTabs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"tabIndex" ascending:YES]]];

    NSMutableArray *gamePlayTabVCs = [[NSMutableArray alloc] initWithCapacity:10];
    Tab *tmpTab;
    for(int i = 0; i < gamePlayTabs.count; i++)
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
                [gamePlayTabVCs addObject:questsNavigationController];
            }
            else
            {
                QuestsViewController *questsViewController = [[QuestsViewController alloc] initWithDelegate:self];
                questsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:questsViewController];
                [gamePlayTabVCs addObject:questsNavigationController];
            }
        }
        else if([tmpTab.tabName isEqualToString:@"GPS"])
        {
            MapViewController *mapViewController = [[MapViewController alloc] initWithDelegate:self];
            mapNavigationController = [[ARISNavigationController alloc] initWithRootViewController:mapViewController];
            [gamePlayTabVCs addObject:mapNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"INVENTORY"])
        {
            InventoryTagViewController *inventoryTagViewController = [[InventoryTagViewController alloc] initWithDelegate:self];
            inventoryNavigationController = [[ARISNavigationController alloc] initWithRootViewController:inventoryTagViewController];
            [gamePlayTabVCs addObject:inventoryNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"DECODER"]) //text only
        {
            DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithDelegate:self inMode:1];
            decoderNavigationController = [[ARISNavigationController alloc] initWithRootViewController:decoderViewController];
            [gamePlayTabVCs addObject:decoderNavigationController];  
        }
        else if([tmpTab.tabName isEqualToString:@"QR"]) //will be scanner only- supports both for legacy
        {
            DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithDelegate:self inMode:tmpTab.tabDetail1];
            scannerNavigationController = [[ARISNavigationController alloc] initWithRootViewController:decoderViewController];
            [gamePlayTabVCs addObject:scannerNavigationController];  
        } 
        else if([tmpTab.tabName isEqualToString:@"PLAYER"])
        {
            AttributesViewController *attributesViewController = [[AttributesViewController alloc] initWithDelegate:self];
            attributesNavigationController = [[ARISNavigationController alloc] initWithRootViewController:attributesViewController];
            [gamePlayTabVCs addObject:attributesNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"NOTE"])
        {
            NotebookViewController *notesViewController = [[NotebookViewController alloc] initWithDelegate:self];
            notesNavigationController = [[ARISNavigationController alloc] initWithRootViewController:notesViewController];
            [gamePlayTabVCs addObject:notesNavigationController];
        }
        else if([tmpTab.tabName isEqualToString:@"AR"])
        {
            //ARViewViewControler *arViewController = [[[ARViewViewControler alloc] initWithNibName:@"ARView" bundle:nil] autorelease];
            //arNavigationController = [[ARISNavigationController alloc] initWithRootViewController: arViewController];
            //[gamePlayTabVCs addObject:arNavigationController];
        }
    }
    
    gamePlayTabSelectorController = [[GamePlayTabSelectorViewController alloc] initWithViewControllers:gamePlayTabVCs delegate:self];
    gamePlayRevealController = [PKRevealController revealControllerWithFrontViewController:[gamePlayTabVCs objectAtIndex:0] leftViewController:gamePlayTabSelectorController options:nil];
     */
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

- (BOOL) displayGameObject:(id)g fromSource:(id)s
{
    /*
    if(!self.isViewLoaded || !self.view.window) return NO; //Doesn't currently have the view-heirarchy authority to display. Return that it failed to those who care

	ARISNavigationController *nav = [[ARISNavigationController alloc] initWithRootViewController:[(Instance *)g viewControllerForDelegate:self fromSource:s]];
    [self presentViewController:nav animated:NO completion:nil];
    //Phil hates that the frame changes depending on what view you add it to...
    gameNotificationViewController.view.frame = CGRectMake(gameNotificationViewController.view.frame.origin.x, 
                                                                gameNotificationViewController.view.frame.origin.y+20,
                                                                gameNotificationViewController.view.frame.size.width,
                                                                gameNotificationViewController.view.frame.size.height);
    [nav.view addSubview:gameNotificationViewController.view];//always put notifs on top //Phil doesn't LOVE this, but can't think of anything better...
    
    if([s isKindOfClass:[Location class]])
    {
        [_SERVICES_ updateServerLocationViewed:((Location *)s).locationId];
        
        if(((Location *)s).deleteWhenViewed)
            [game.locationsModel removeLocation:s];
    }
     */
    
    return YES;
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
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
        
    /*
    int plaque_id = _MODEL_GAME_.launchPlaqueId;
    if(plaque_id && plaque_id != 0 && _MODEL_GAME_.questsModel.currentCompletedQuests.count < 1)
        [self displayGameObject:[_MODEL_PLAQUES_ plaqueForId:plaque_id] fromSource:self];
     */
}

- (void) checkForDisplayCompletePlaque
{
    /*
    int plaque_id = _MODEL_GAME_.completePlaqueId;
    if(plaque_id != 0 &&
        _MODEL_GAME_.questsModel.currentCompletedQuests.count == _MODEL_GAME_.questsModel.totalQuestsInGame &&
        _MODEL_GAME_.questsModel.currentCompletedQuests.count > 0)
    {
        [self displayGameObject:[_MODEL_PLAQUES_ plaqueForId:plaque_id] fromSource:self];
	}
     */
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

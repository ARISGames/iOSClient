//
//  GamePlayViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/2/13.
//
//

#import "GamePlayViewController.h"

#import "ARISAlertHandler.h"
#import "ARISNavigationController.h"

#import "GameNotificationViewController.h"
#import "DisplayQueueModel.h"
#import "AppModel.h"

#import "StateControllerProtocol.h"

#import "GamePlayTabSelectorViewController.h"
#import "PKRevealController.h"

#import "QuestsViewController.h"
#import "IconQuestsViewController.h"
#import "InventoryViewController.h"
#import "MapViewController.h"
#import "AttributesViewController.h"
#import "NotebookViewController.h"
#import "DecoderViewController.h"

#import "PlaqueViewController.h"
#import "ItemViewController.h"
#import "DialogViewController.h"
#import "WebPageViewController.h"
#import "NoteViewController.h"

<<<<<<< HEAD
//needed for orientation hack
#import "AudioVisualizerViewController.h"
=======
//dynamic navigation controllers
#import "NpcViewController.h"
#import "Npc.h"
#import "Item.h"
#import "ItemViewController.h"
>>>>>>> Items are displaying on the tab bar

@interface GamePlayViewController() <UINavigationControllerDelegate, GamePlayTabSelectorViewControllerDelegate, StateControllerProtocol, InstantiableViewControllerDelegate, GamePlayTabBarViewControllerDelegate, QuestsViewControllerDelegate, MapViewControllerDelegate, InventoryViewControllerDelegate, AttributesViewControllerDelegate, NotebookViewControllerDelegate, DecoderViewControllerDelegate, GameNotificationViewControllerDelegate, DisplayQueueModelDelegate>
{
    PKRevealController *gamePlayRevealController;
    GamePlayTabSelectorViewController *gamePlayTabSelectorController;

    GameNotificationViewController *gameNotificationViewController;
<<<<<<< HEAD
    DisplayQueueModel *displayQueue;
=======
    
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
    
    NSMutableArray *gamePlayTabVCs;
    
    ForceDisplayQueue *forceDisplayQueue;
    
    NSTimer *timeout;
>>>>>>> Items are displaying on the tab bar

    id<GamePlayViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation GamePlayViewController

- (id) initWithDelegate:(id<GamePlayViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;

        //odd that a model is stored here- but it needs to communicate with the state of the display
        //(is the display available for dequeue?)
        //One caveat is that it didn't exist to listen to the initial set of triggers to populate,
        //so on init (now), we need to manually flush the set of all available triggers through the queue
        displayQueue = [[DisplayQueueModel alloc] initWithDelegate:self];
        _ARIS_NOTIF_SEND_(@"MODEL_TRIGGERS_NEW_AVAILABLE",nil,@{@"added":@[]});
        //admittedly a bit hacky, but should be safe

        gameNotificationViewController = [[GameNotificationViewController alloc] initWithDelegate:self];
        gamePlayTabSelectorController = [[GamePlayTabSelectorViewController alloc] initWithDelegate:self];
        gamePlayRevealController = [PKRevealController revealControllerWithFrontViewController:gamePlayTabSelectorController.firstViewController leftViewController:gamePlayTabSelectorController options:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];

    gameNotificationViewController.view.frame = CGRectMake(0,0,0,0);
    [self.view addSubview:gameNotificationViewController.view];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(!currentChildViewController)
        [self displayContentController:gamePlayRevealController];
}

- (void) viewDidAppear:(BOOL)animated
{
    [displayQueue dequeueTrigger];
}

- (void) gamePlayTabBarViewControllerRequestsNav
{
    [self showNav];
}

- (void) showNav
{
    [gamePlayRevealController showViewController:gamePlayTabSelectorController];
}

- (void) viewControllerRequestedDisplay:(ARISNavigationController *)avc
{
    [gamePlayRevealController setFrontViewController:avc];
    [gamePlayRevealController showViewController:avc];
}

- (BOOL) displayTrigger:(Trigger *)t
{
    Instance *i = [_MODEL_INSTANCES_ instanceForId:t.instance_id];
    if(![self displayInstance:i]) return NO;
    [_MODEL_LOGS_ playerTriggeredTriggerId:t.trigger_id];
    return YES;
}

- (BOOL) displayObjectType:(NSString *)type id:(int)type_id
{
    Instance *i = [_MODEL_INSTANCES_ instanceForId:0]; //create hacked instance
    i.object_type = type;
    i.object_id = type_id;
    i.qty = 1;
    return [self displayInstance:i];
}

- (BOOL) displayInstance:(Instance *)i
{
    if(!self.isViewLoaded || !self.view.window) return NO; //Doesn't currently have the view-heirarchy authority to display. Return that it failed to those who care

    ARISViewController *vc;
    if([i.object_type isEqualToString:@"PLAQUE"])
    {
<<<<<<< HEAD
        Plaque *p = [_MODEL_PLAQUES_ plaqueForId:i.object_id];
        [_MODEL_EVENTS_ runEventPackageId:p.event_package_id];
        vc = [[PlaqueViewController alloc] initWithInstance:i delegate:self];
=======
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
        else if([tmpTab.tabName isEqualToString:@"NPC"])
        {
            //there is a possible race condition here when the npc is not in the model
            Npc *npc = [[AppModel sharedAppModel].currentGame.npcList objectForKey:[NSNumber numberWithInt:tmpTab.tabDetail1]];
            NpcViewController *npcViewController = [[NpcViewController alloc] initWithNpc:npc delegate:self];
            npcNavigationController = [[ARISNavigationController alloc] initWithRootViewController:npcViewController];
            [gamePlayTabVCs addObject:npcNavigationController];
        }
        else if ([tmpTab.tabName isEqualToString:@"ITEM"])
        {
            //there is a possible race condition here when the npc is not in the model
            Item *item = [[AppModel sharedAppModel].currentGame.itemList objectForKey:[NSNumber numberWithInt:tmpTab.tabDetail1]];
            ItemViewController *itemViewController = [[ItemViewController alloc] initWithItem:item delegate:self source:nil];
            itemNavigationController = [[ARISNavigationController alloc] initWithRootViewController:itemViewController];
            [gamePlayTabVCs addObject:itemNavigationController];
        }
>>>>>>> Items are displaying on the tab bar
    }
    if([i.object_type isEqualToString:@"ITEM"])
        vc = [[ItemViewController alloc] initWithInstance:i delegate:self];
    if([i.object_type isEqualToString:@"DIALOG"])
        vc = [[DialogViewController alloc] initWithInstance:i delegate:self];
    if([i.object_type isEqualToString:@"WEB_PAGE"])
        vc = [[WebPageViewController alloc] initWithInstance:i delegate:self];
    //if([i.object_type isEqualToString:@"NOTE"])
        //vc = [[NoteViewController alloc] initWithInstance:i delegate:self];

    ARISNavigationController *nav = [[ARISNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:NO completion:nil];

    //Phil hates that the frame changes depending on what view you add it to...
    gameNotificationViewController.view.frame = CGRectMake(gameNotificationViewController.view.frame.origin.x,
                                                           gameNotificationViewController.view.frame.origin.y+20,
                                                           gameNotificationViewController.view.frame.size.width,
                                                           gameNotificationViewController.view.frame.size.height);
    [nav.view addSubview:gameNotificationViewController.view];//always put notifs on top //Phil doesn't LOVE this, but can't think of anything better...

    [_MODEL_LOGS_ playerViewedInstanceId:i.instance_id];
    [_MODEL_LOGS_ playerViewedContent:i.object_type id:i.object_id];
    return YES;
}

- (void) instantiableViewControllerRequestsDismissal:(InstantiableViewController *)govc
{
    [govc.navigationController dismissViewControllerAnimated:NO completion:nil];

    //Phil hates that the frame changes depending on what view you add it to...
    gameNotificationViewController.view.frame = CGRectMake(gameNotificationViewController.view.frame.origin.x,
                                                                gameNotificationViewController.view.frame.origin.y-20,
                                                                gameNotificationViewController.view.frame.size.width,
                                                                gameNotificationViewController.view.frame.size.height);
    [self.view addSubview:gameNotificationViewController.view];//always put notifs on top //Phil doesn't LOVE this, but can't think of anything better...

    [displayQueue dequeueTrigger];
}

- (void) displayTab:(NSString *)t
{
    [gamePlayTabSelectorController requestDisplayTab:t];
}
- (void) displayScannerWithPrompt:(NSString *)p
{
    [gamePlayTabSelectorController requestDisplayScannerWithPrompt:p];
}

- (NSUInteger) supportedInterfaceOrientations
{
    //BAD BAD HACK
    //if ([[notesNavigationController topViewController] isKindOfClass:[AudioVisualizerViewController class]]) {
        //return UIInterfaceOrientationMaskLandscape;
    //}
    //else{
        return UIInterfaceOrientationMaskPortrait;
    //}
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

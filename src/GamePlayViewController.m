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

//needed for orientation hack
#import "AudioVisualizerViewController.h"
#import "WebPage.h"
#import "WebPageViewController.h"

@interface GamePlayViewController() <
    UINavigationControllerDelegate,
    InstantiableViewControllerDelegate,
    GamePlayTabBarViewControllerDelegate,

    QuestsViewControllerDelegate,
    MapViewControllerDelegate,
    InventoryViewControllerDelegate,
    AttributesViewControllerDelegate,
    NotebookViewControllerDelegate,
    DecoderViewControllerDelegate,

    PlaqueViewControllerDelegate,
    ItemViewControllerDelegate,
    DialogViewControllerDelegate,
    WebPageViewControllerDelegate,
    NoteViewControllerDelegate,

    GamePlayTabSelectorViewControllerDelegate,
    GameNotificationViewControllerDelegate
    >
{
    PKRevealController *gamePlayRevealController;
    GamePlayTabSelectorViewController *gamePlayTabSelectorController;

    GameNotificationViewController *gameNotificationViewController;

    BOOL viewingObject; //because apple's heirarchy design is terrible
    id<GamePlayViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation GamePlayViewController

- (id) initWithDelegate:(id<GamePlayViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;

        gameNotificationViewController = [[GameNotificationViewController alloc] initWithDelegate:self];
        gamePlayTabSelectorController = [[GamePlayTabSelectorViewController alloc] initWithDelegate:self];
        gamePlayRevealController = [PKRevealController revealControllerWithFrontViewController:gamePlayTabSelectorController.firstViewController leftViewController:gamePlayTabSelectorController options:nil];
        
        viewingObject = NO;
        _ARIS_NOTIF_LISTEN_(@"MODEL_DISPLAY_NEW_ENQUEUED", self, @selector(tryDequeue), nil);
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
    [self tryDequeue];
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

- (void) tryDequeue
{
    //Doesn't currently have the view-heirarchy authority to display.
    //if(!(self.isViewLoaded && self.view.window)) //should work but apple's timing is terrible
    if(viewingObject) return;
    NSObject *o;
    if((o = [_MODEL_DISPLAY_QUEUE_ dequeue]))
    {
        if     ([o isKindOfClass:[Trigger class]])  [self displayTrigger:(Trigger *)o];
        else if([o isKindOfClass:[Instance class]]) [self displayInstance:(Instance *)o];
        else if([o isKindOfClass:[Tab class]])      [self displayTab:(Tab *)o];
        else if([o conformsToProtocol:@protocol(InstantiableProtocol)]) [self displayObject:(NSObject <InstantiableProtocol>*)o];
    }
}

- (void) displayTrigger:(Trigger *)t
{
    _ARIS_NOTIF_SEND_(@"GAME_PLAY_DISPLAYED_TRIGGER",nil,@{@"trigger":t});
    [self displayInstance:[_MODEL_INSTANCES_ instanceForId:t.instance_id]];
    [_MODEL_LOGS_ playerTriggeredTriggerId:t.trigger_id];
}

- (void) displayInstance:(Instance *)i
{
    ARISViewController *vc;
    if([i.object_type isEqualToString:@"PLAQUE"])
      vc = [[PlaqueViewController alloc] initWithInstance:i delegate:self];
    if([i.object_type isEqualToString:@"ITEM"])
        vc = [[ItemViewController alloc] initWithInstance:i delegate:self];
    if([i.object_type isEqualToString:@"DIALOG"])
        vc = [[DialogViewController alloc] initWithInstance:i delegate:self];
    if([i.object_type isEqualToString:@"WEB_PAGE"])
        vc = [[WebPageViewController alloc] initWithInstance:i delegate:self];
    if([i.object_type isEqualToString:@"NOTE"])
        vc = [[NoteViewController alloc] initWithInstance:i delegate:self];
    if([i.object_type isEqualToString:@"SCENE"]) //Special case (don't actually display anything)
    {
        [_MODEL_SCENES_ setPlayerScene:(Scene *)i.object];
        [_MODEL_LOGS_ playerViewedInstanceId:i.instance_id];
        //Hack 'dequeue' as simulation for normally inevitable request dismissal of VC we didn't put up...
        [self performSelector:@selector(tryDequeue) withObject:nil afterDelay:1];
        return;
    }
    if([i.object_type isEqualToString:@"FACTORY"]) //Special case (don't actually display anything)
    {
        //Hack 'dequeue' as simulation for normally inevitable request dismissal of VC we didn't put up...
        [self performSelector:@selector(tryDequeue) withObject:nil afterDelay:1];
        return;
    }
    [_MODEL_LOGS_ playerViewedInstanceId:i.instance_id];
    _ARIS_NOTIF_SEND_(@"GAME_PLAY_DISPLAYED_INSTANCE",nil,@{@"instance":i});
    if(i.factory_id)
    {
        Factory *f = [_MODEL_FACTORIES_ factoryForId:i.factory_id];
        if(f.produce_expire_on_view)
            [_MODEL_TRIGGERS_ expireTriggersForInstanceId:i.instance_id];
    }

    ARISNavigationController *nav = [[ARISNavigationController alloc] initWithRootViewController:vc];
    [self presentDisplay:nav];
}

- (void) displayObject:(NSObject <InstantiableProtocol>*)o
{
    ARISViewController *vc;
    Instance *i = [_MODEL_INSTANCES_ instanceForId:0];
    if([o isKindOfClass:[Plaque class]])
    {
      Plaque *p = (Plaque *)o;
      i.object_type = @"PLAQUE";
      i.object_id = p.plaque_id;
      vc = [[PlaqueViewController alloc] initWithInstance:i delegate:self];
    }
    if([o isKindOfClass:[Item class]])
    {
      Item *it = (Item *)o;
      i.object_type = @"ITEM";
      i.object_id = it.item_id;
      vc = [[ItemViewController alloc] initWithInstance:i delegate:self];
    }
    if([o isKindOfClass:[Dialog class]])
    {
      Dialog *d = (Dialog *)o;
      i.object_type = @"DIALOG";
      i.object_id = d.dialog_id;
      vc = [[DialogViewController alloc] initWithInstance:i delegate:self];
    }
    if([o isKindOfClass:[WebPage class]])
    {
      WebPage *w = (WebPage *)o;
      i.object_type = @"WEB_PAGE";
      i.object_id = w.web_page_id;
      vc = [[WebPageViewController alloc] initWithInstance:i delegate:self];
    }
    if([o isKindOfClass:[Note class]])
    {
      Note *n = (Note *)o;
      i.object_type = @"NOTE";
      i.object_id = n.note_id;
      vc = [[NoteViewController alloc] initWithInstance:i delegate:self];
    }
    
    ARISNavigationController *nav = [[ARISNavigationController alloc] initWithRootViewController:vc];
    [self presentDisplay:nav];
}

- (void) presentDisplay:(UIViewController *)vc
{
    [self presentViewController:vc animated:NO completion:nil];
    viewingObject = YES;

    //Phil hates that the frame changes depending on what view you add it to...
    gameNotificationViewController.view.frame = CGRectMake(gameNotificationViewController.view.frame.origin.x,
                                                           gameNotificationViewController.view.frame.origin.y+20,
                                                           gameNotificationViewController.view.frame.size.width,
                                                           gameNotificationViewController.view.frame.size.height);
    [vc.view addSubview:gameNotificationViewController.view];//always put notifs on top //Phil doesn't LOVE this, but can't think of anything better...
}

- (void) instantiableViewControllerRequestsDismissal:(id<InstantiableViewControllerProtocol>)ivc
{
    [((ARISViewController *)ivc).navigationController dismissViewControllerAnimated:NO completion:nil];
    viewingObject = NO;

    //Phil hates that the frame changes depending on what view you add it to...
    gameNotificationViewController.view.frame = CGRectMake(gameNotificationViewController.view.frame.origin.x,
                                                                gameNotificationViewController.view.frame.origin.y-20,
                                                                gameNotificationViewController.view.frame.size.width,
                                                                gameNotificationViewController.view.frame.size.height);
    [self.view addSubview:gameNotificationViewController.view];//always put notifs on top //Phil doesn't LOVE this, but can't think of anything better...

    [_MODEL_LOGS_ playerViewedContent:ivc.instance.object_type id:ivc.instance.object_id];
    [self performSelector:@selector(tryDequeue) withObject:nil afterDelay:1];
}

- (void) displayTab:(Tab *)t
{
    [gamePlayTabSelectorController requestDisplayTab:t];
    [self tryDequeue]; //no 'closing event' for tab
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

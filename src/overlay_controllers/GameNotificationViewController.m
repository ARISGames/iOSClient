//
//  GameNotificationViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import "GameNotificationViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "PopOverViewController.h"
#import "MTStatusBarOverlay.h"

@interface GameNotificationViewController() <PopOverViewDelegate, MTStatusBarOverlayDelegate>
{
    PopOverViewController *popOverVC;
    NSString *submitFunction;

    NSMutableArray *notifArray;
    NSMutableArray *popOverArray;
    BOOL showingDropDown;
    BOOL showingPopOver;
    
    id<GameNotificationViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation GameNotificationViewController

- (id) initWithDelegate:(id<GameNotificationViewControllerDelegate>)d
{
    if(self = [super init])
    {
        //Init Notification Arrays
        notifArray   = [[NSMutableArray alloc] initWithCapacity:5];
        popOverArray = [[NSMutableArray alloc] initWithCapacity:5];
        showingDropDown = NO;
        showingPopOver  = NO;
        
        MTStatusBarOverlay *o = [MTStatusBarOverlay sharedInstance];
        o.animation = MTStatusBarOverlayAnimationFallDown;
        o.delegate = self;
        
        delegate = d;
        
        _ARIS_NOTIF_LISTEN_(@"MODEL_QUESTS_ACTIVE_NEW_AVAILABLE",self,@selector(parseActiveQuestsIntoNotifications:),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_QUESTS_COMPLETE_NEW_AVAILABLE",self,@selector(parseCompleteQuestsIntoNotifications:),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_INSTANCES_PLAYER_GAINED",self,@selector(parseReceivedInstancesIntoNotifications:),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_INSTANCES_PLAYER_LOST",self,@selector(parseLostInstancesIntoNotifications:),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_NEW_AVAILABLE",self,@selector(parseAvailableTriggersIntoNotifications:),nil); 
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.userInteractionEnabled = NO;
    
    popOverVC = [[PopOverViewController alloc] initWithDelegate:self];
}

- (void) viewWillAppear:(BOOL)animated //first time view should be 'correct' frame
{
    [super viewWillAppear:animated];
    self.view.frame = CGRectMake(0,0,self.view.superview.frame.size.width,self.view.superview.frame.size.height);
    popOverVC.view.frame = self.view.frame;
}

- (void) dequeuePopOver
{
    showingPopOver = YES;
    
    NSMutableDictionary *poDict = popOverArray[0];
    [popOverVC setHeader:poDict[@"header"] prompt:poDict[@"prompt"] icon_media_id:[poDict[@"icon_media_id"] intValue]];
    submitFunction = poDict[@"submit_function"];
    [self.view addSubview:popOverVC.view];
    [popOverArray removeObjectAtIndex:0];
    self.view.userInteractionEnabled = YES;
    if(self.view.frame.size.height == 0) 
        [self viewWillAppear:NO];//to ensure a non-zero rect. Not sure why necessary- short term fix
}

- (void) popOverRequestsSubmit
{
    if(submitFunction)
    {
        if([submitFunction isEqualToString:@"JAVASCRIPT"]) return;//[webView hookWithParams:@""];
        else if([submitFunction isEqualToString:@"NONE"]) return;
        else [_MODEL_DISPLAY_QUEUE_ enqueueTab:[_MODEL_TABS_ tabForType:submitFunction]];
    }
    [self popOverRequestsDismiss];
}

- (void) popOverRequestsDismiss
{
    submitFunction = nil;
    showingPopOver = NO;
    self.view.userInteractionEnabled = NO;
    
    if(popOverArray.count > 0)
        [self dequeuePopOver];
    else
        [popOverVC.view removeFromSuperview];
}

- (void) enqueueDropDownNotificationWithString:(NSString *)string
{
    [[MTStatusBarOverlay sharedInstance] postMessage:string duration:5.0];
}

- (void) enqueuePopOverNotificationWithHeader:(NSString *)header prompt:(NSString *)prompt icon_media_id:(int)icon_media_id submitFunc:(NSString *)s
{
    [popOverArray addObject:@{
       @"header":header,
       @"prompt":prompt,
       @"icon_media_id":[NSNumber numberWithInt:icon_media_id],
       @"submit_function":s
    }];
    if(!showingPopOver) [self dequeuePopOver];
}

- (void) parseActiveQuestsIntoNotifications:(NSNotification *)notification
{
    NSArray *activeQuests = (NSArray *)notification.userInfo[@"added"];
    
    for(int i = 0; i < activeQuests.count; i++)
    {
        Quest *activeQuest = activeQuests[i];
        
        if([activeQuest.active_notification_type isEqualToString:@"FULL_SCREEN"])
            [self enqueuePopOverNotificationWithHeader:NSLocalizedString(@"QuestViewNewQuestKey", nil) prompt:activeQuest.name icon_media_id:activeQuest.active_icon_media_id submitFunc:activeQuest.active_function];
        else
            [self enqueueDropDownNotificationWithString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestViewNewQuestKey", nil), activeQuest.name]];
    }
}

- (void) parseCompleteQuestsIntoNotifications:(NSNotification *)notification
{
    NSArray *completedQuests = (NSArray *)notification.userInfo[@"added"];

    for(int i = 0; i < completedQuests.count; i++)
    { 
        Quest *completedQuest = completedQuests[i];      
    
        if([completedQuest.complete_notification_type isEqualToString:@"FULL_SCREEN"])
            [self enqueuePopOverNotificationWithHeader:NSLocalizedString(@"QuestsViewQuestCompletedKey", nil) prompt:completedQuest.name icon_media_id:completedQuest.complete_icon_media_id submitFunc:completedQuest.complete_function];
        else
            [self enqueueDropDownNotificationWithString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestsViewQuestCompletedKey", nil), completedQuest.name]];
    }
}

- (void) parseReceivedInstancesIntoNotifications:(NSNotification *)notification
{
    NSArray *deltas = notification.userInfo[@"added"];
    for(int i = 0; i < deltas.count; i++)
    {
        Instance *inst = deltas[i][@"instance"];
        int qty = [deltas[i][@"delta"] intValue];
        
        NSString *notifString;
        if(((Item *)inst.object).max_qty_in_inventory == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", inst.name, NSLocalizedString(@"ReceivedNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"+%d %@ : %d %@",  qty, inst.name, inst.qty, NSLocalizedString(@"TotalNotifKey", nil)];
        
        [self enqueueDropDownNotificationWithString:notifString];
    }
    if(deltas.count > 0)
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        
}

- (void) parseLostInstancesIntoNotifications:(NSNotification *)notification
{
    NSArray *deltas = notification.userInfo[@"added"];
    for(int i = 0; i < deltas.count; i++)
    {
        Instance *inst = deltas[i][@"instance"];
        int qty = [deltas[i][@"delta"] intValue];
        
        NSString *notifString;
        if(((Item *)inst.object).max_qty_in_inventory == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", inst.name, NSLocalizedString(@"LostNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"%d %@ : %d %@",  qty, inst.name, inst.qty, NSLocalizedString(@"LeftNotifKey", nil)];
        
        [self enqueueDropDownNotificationWithString:notifString];
    }
    if(deltas.count > 0)
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
}

- (void) parseAvailableTriggersIntoNotifications:(NSNotification *)notification
{
    //NSArray *newTriggers = (NSArray *)notification.userInfo[@"added"];
    //Doesn't actually do anything
}

- (void) cutOffGameNotifications
{
    [notifArray   removeAllObjects];
    [popOverArray removeAllObjects];
    showingDropDown  = NO;
    showingPopOver   = NO;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);      
}

@end

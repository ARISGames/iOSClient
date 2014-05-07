//
//  GameNotificationViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import "GameNotificationViewController.h"
#import "AppModel.h"
#import "Game.h"
#import "ItemsModel.h"
#import "ARISAppDelegate.h"
#import "PopOverViewController.h"
#import "MTStatusBarOverlay.h"
#import "StateControllerProtocol.h"

#import "Item.h"
#import "Quest.h"

@interface GameNotificationViewController() <PopOverViewDelegate, MTStatusBarOverlayDelegate>
{
    PopOverViewController *popOverVC;

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
    
    NSMutableDictionary *poDict = [popOverArray objectAtIndex:0];
    [popOverVC setHeader:[poDict objectForKey:@"header"] prompt:[poDict objectForKey:@"prompt"] icon_media_id:[[poDict objectForKey:@"icon_media_id"] intValue]];
    [self.view addSubview:popOverVC.view];
    [popOverArray removeObjectAtIndex:0];
    self.view.userInteractionEnabled = YES;
    if(self.view.frame.size.height == 0) 
        [self viewWillAppear:NO];//to ensure a non-zero rect. Not sure why necessary- short term fix
}

- (void) popOverRequestsDismiss
{
    showingPopOver = NO;
    self.view.userInteractionEnabled = NO;
    
    if([popOverArray count] > 0)
        [self dequeuePopOver];
    else
        [popOverVC.view removeFromSuperview];
}

- (void) enqueueDropDownNotificationWithString:(NSString *)string
{
    [[MTStatusBarOverlay sharedInstance] postMessage:string duration:3.0];
}

- (void) enqueuePopOverNotificationWithHeader:(NSString *)header prompt:(NSString *)prompt icon_media_id:(int)icon_media_id
{
    [popOverArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:header,@"header",prompt,@"prompt",[NSNumber numberWithInt:icon_media_id],@"icon_media_id",nil]];
    if(!showingPopOver) [self dequeuePopOver];
}

- (void) parseActiveQuestsIntoNotifications:(NSNotification *)notification
{
    NSArray *activeQuests = (NSArray *)[notification.userInfo objectForKey:@"newlyActiveQuests"];
    
    for(int i = 0; i < [activeQuests count]; i++)
    {
        Quest *activeQuest = [activeQuests objectAtIndex:i];
        
        if(activeQuest.fullScreenNotification)
            [self enqueuePopOverNotificationWithHeader:NSLocalizedString(@"QuestViewNewQuestKey", nil) prompt:activeQuest.name icon_media_id:activeQuest.icon_media_id];
        else
            [self enqueueDropDownNotificationWithString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestViewNewQuestKey", nil), activeQuest.name]];
        
        NSLog(@"NSNotification: NewlyChangedQuestsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedQuestsGameNotificationSent" object:self]];
        NSLog(@"NSNotification: NewlyActiveQuestsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyActiveQuestsGameNotificationSent" object:self]];
    }
}

- (void) parseCompleteQuestsIntoNotifications:(NSNotification *)notification
{
    NSArray *completedQuests = (NSArray *)[notification.userInfo objectForKey:@"newlyCompletedQuests"];

    for(int i = 0; i < [completedQuests count]; i++)
    { 
        Quest *completedQuest = [completedQuests objectAtIndex:i];      
    
        if(completedQuest.fullScreenNotification)
            [self enqueuePopOverNotificationWithHeader:NSLocalizedString(@"QuestsViewQuestCompletedKey", nil) prompt:completedQuest.name icon_media_id:completedQuest.icon_media_id];
        else
            [self enqueueDropDownNotificationWithString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestsViewQuestCompletedKey", nil), completedQuest.name]];
        
        NSLog(@"NSNotification: NewlyChangedQuestsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedQuestsGameNotificationSent" object:self]];
        NSLog(@"NSNotification: NewlyCompletedQuestsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyCompletedQuestsGameNotificationSent" object:self]];
    }
}

- (void) parseReceivedItemsIntoNotifications:(NSNotification *)notification
{
    NSArray *receivedItems = (NSArray *)[notification.userInfo objectForKey:@"newlyAcquiredItems"];
    
    for(int i = 0; i < [receivedItems count]; i++)
    {
        NSDictionary *receivedItemDict = [receivedItems objectAtIndex:i];
        Item *receivedItem = [receivedItemDict objectForKey:@"item"];
        int qty = [((NSNumber *)[receivedItemDict objectForKey:@"delta"]) intValue];
        
        NSString *notifString;
        if(receivedItem.max_qty_in_inventory == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", receivedItem.name, NSLocalizedString(@"ReceivedNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"+%d %@ : %d %@",  qty, receivedItem.name, [_MODEL_ITEMS_ qtyOwnedForItem:receivedItem.item_id], NSLocalizedString(@"TotalNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithString:notifString];
        
        NSLog(@"NSNotification: NewlyChangedItemsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedItemsGameNotificationSent" object:self]];
    }
}

- (void) parseLostItemsIntoNotifications:(NSNotification *)notification
{
    NSArray *lostItems = (NSArray *)[notification.userInfo objectForKey:@"newlyLostItems"];

    for(int i = 0; i < [lostItems count]; i++)
    {
        NSDictionary *lostItemDict = [lostItems objectAtIndex:i];
        Item *lostItem = [lostItemDict objectForKey:@"item"];
        int qty = [((NSNumber *)[lostItemDict objectForKey:@"delta"]) intValue];
        
        NSString *notifString;
        if(lostItem.max_qty_in_inventory == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", lostItem.name, NSLocalizedString(@"LostNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"-%d %@ : %d %@",  qty, lostItem.name, [_MODEL_ITEMS_ qtyOwnedForItem:lostItem.item_id], NSLocalizedString(@"LeftNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithString:notifString];
        
        NSLog(@"NSNotification: NewlyChangedItemsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedItemsGameNotificationSent" object:self]];
    }
}

- (void) parseReceivedAttributesIntoNotifications:(NSNotification *)notification
{
    NSArray *receivedAttributes = (NSArray *)[notification.userInfo objectForKey:@"newlyAcquiredAttributes"];

    for(int i = 0; i < [receivedAttributes count]; i++)
    {
        NSDictionary *receivedAttributeDict = [receivedAttributes objectAtIndex:i];
        Item *receivedAttribute = [receivedAttributeDict objectForKey:@"attribute"];
        int qty = [((NSNumber *)[receivedAttributeDict objectForKey:@"delta"]) intValue];
        
        NSString *notifString;
        if(receivedAttribute.max_qty_in_inventory == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", receivedAttribute.name, NSLocalizedString(@"ReceivedNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"+%d %@ : %d %@",  qty, receivedAttribute.name, [_MODEL_ITEMS_ qtyOwnedForItem:receivedAttribute.item_id], NSLocalizedString(@"TotalNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithString:notifString];

        NSLog(@"NSNotification: NewlyChangedAttributesGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedAttributesGameNotificationSent" object:self]];
    }

}

- (void) parseLostAttributesIntoNotifications:(NSNotification *)notification
{
    NSArray *lostAttributes = (NSArray *)[notification.userInfo objectForKey:@"newlyLostAttributes"];

    for(int i = 0; i < [lostAttributes count]; i++)
    {
        NSDictionary *lostAttributeDict = [lostAttributes objectAtIndex:i];
        Item *lostAttribute = [lostAttributeDict objectForKey:@"attribute"];
        int qty = [((NSNumber *)[lostAttributeDict objectForKey:@"delta"]) intValue];

        NSString *notifString;
        if(lostAttribute.max_qty_in_inventory == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", lostAttribute.name, NSLocalizedString(@"LostNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"-%d %@ : %d %@",  qty, lostAttribute.name, [_MODEL_ITEMS_ qtyOwnedForItem:lostAttribute.item_id], NSLocalizedString(@"LeftNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithString:notifString];
        
        NSLog(@"NSNotification: NewlyChangedAttributesGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedAttributesGameNotificationSent" object:self]];
    }
}

- (void) parseAvailableLocationsIntoNotifications:(NSNotification *)notification
{
    NSArray *newLocations = (NSArray *)[notification.userInfo objectForKey:@"newlyAvailableLocations"];
    
    for(int i = 0; i < [newLocations count]; i++)
    {
        //Doesn't actually show a game notification...
        NSLog(@"NSNotification: NewlyChangedLocationsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedLocationsGameNotificationSent" object:self]];
    }
}

- (void) cutOffGameNotifications
{
    NSLog(@"NSNotification: ClearBadgeRequest");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ClearBadgeRequest" object:self]];
    [notifArray   removeAllObjects];
    [popOverArray removeAllObjects];
    showingDropDown  = NO;
    showingPopOver   = NO;
}

- (void) startListeningToModel
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseActiveQuestsIntoNotifications:)
                                                 name:@"NewlyActiveQuestsAvailable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseCompleteQuestsIntoNotifications:)
                                                 name:@"NewlyCompletedQuestsAvailable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseReceivedItemsIntoNotifications:)
                                                 name:@"NewlyAcquiredItemsAvailable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseLostItemsIntoNotifications:)
                                                 name:@"NewlyLostItemsAvailable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseReceivedAttributesIntoNotifications:)
                                                 name:@"NewlyAcquiredAttributesAvailable"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseLostAttributesIntoNotifications:)
                                                 name:@"NewlyLostAttributesAvailable"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseAvailableLocationsIntoNotifications:)
                                                 name:@"NewlyAvailableLocationsAvailable"
                                               object:nil];
}

- (void)stopListeningToModel
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) dealloc
{
    
}


@end

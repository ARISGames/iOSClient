//
//  GameNotificationViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import "GameNotificationViewController.h"
#import "RootViewController.h"
#import "ARISAppDelegate.h"

#import "Item.h"
#import "Quest.h"

@interface GameNotificationViewController ()

@end

@implementation GameNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //Init Notification Arrays
        notifArray = [[NSMutableArray alloc] initWithCapacity:5];
        popOverArray = [[NSMutableArray alloc] initWithCapacity:5];
        showingPopOver = NO;
    }
    return self;
}

-(void)loadView
{
    popOverVC = [[PopOverViewController alloc] initWithNibName:@"PopOverViewController" bundle:nil delegate:self];
    popOverView = (PopOverContentView *)popOverVC.view;
    
    statusBar = [MTStatusBarOverlay sharedInstance];
    statusBar.animation = MTStatusBarOverlayAnimationFallDown;
    statusBar.detailViewMode = MTDetailViewModeHistory;
    statusBar.delegate = self;
}

-(void)dequeuePopOver
{
    showingPopOver = YES;
    
    NSMutableDictionary *poDict = [popOverArray objectAtIndex:0];
    [popOverVC setTitle:[poDict objectForKey:@"title"]
            description:[poDict objectForKey:@"description"]
            webViewText:[poDict objectForKey:@"text"]
             andMediaId:[[poDict objectForKey:@"mediaId"] intValue]];
    [[RootViewController sharedRootViewController].view addSubview:popOverView];
    [popOverArray removeObjectAtIndex:0];
}

-(void)popOverContinueButtonPressed
{
    showingPopOver = NO;
    if([popOverArray count] > 0)
        [self dequeuePopOver];
    else
        [popOverView removeFromSuperview];
}

-(void)enqueueDropDownNotificationWithString:(NSString *)string
{
    [statusBar postMessage:string duration:4.0 animated:YES];
}

-(void)enqueuePopOverNotificationWithTitle:(NSString *)title description:(NSString *)description webViewText:(NSString *)text andMediaId:(int) mediaId
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",description,@"description",text,@"text",[NSNumber numberWithInt:mediaId],@"mediaId", nil];
    [popOverArray addObject:dict];
    if(!showingPopOver) [self dequeuePopOver];
}

-(void)parseActiveQuestsIntoNotifications:(NSNotification *)notification
{
    NSArray *activeQuests = (NSArray *)[notification.userInfo objectForKey:@"newlyActiveQuests"];
    
    for(int i = 0; i < [activeQuests count]; i++)
    {
        Quest *activeQuest = [activeQuests objectAtIndex:i];
        
        if(activeQuest.fullScreenNotification)
            [self enqueuePopOverNotificationWithTitle:NSLocalizedString(@"QuestViewNewQuestKey", nil) description:activeQuest.name webViewText:activeQuest.qdescription andMediaId:activeQuest.mediaId];
        else
        {
            NSString *notifString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestViewNewQuestKey", nil), activeQuest.name] ;
            [self enqueueDropDownNotificationWithString:notifString];
        }
        
        NSLog(@"NSNotification: NewlyChangedQuestsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedQuestsGameNotificationSent" object:self]];
    }
}

-(void)parseCompleteQuestsIntoNotifications:(NSNotification *)notification
{
    NSArray *completedQuests = (NSArray *)[notification.userInfo objectForKey:@"newlyCompletedQuests"];

    for(int i = 0; i < [completedQuests count]; i++)
    { 
        Quest *completedQuest = [completedQuests objectAtIndex:i];      
    
        if(completedQuest.fullScreenNotification)
            [self enqueuePopOverNotificationWithTitle:NSLocalizedString(@"QuestsViewQuestCompletedKey", nil) description:completedQuest.name webViewText:completedQuest.qdescription andMediaId:completedQuest.mediaId];
        else
        {
            NSString *notifString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestsViewQuestCompletedKey", nil), completedQuest.name] ;
            [self enqueueDropDownNotificationWithString:notifString];
        }
        
        NSLog(@"NSNotification: NewlyChangedQuestsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedQuestsGameNotificationSent" object:self]];
    }
}

-(void)parseReceivedItemsIntoNotifications:(NSNotification *)notification
{
    NSArray *receivedItems = (NSArray *)[notification.userInfo objectForKey:@"newlyAcquiredItems"];
    
    for(int i = 0; i < [receivedItems count]; i++)
    {
        NSDictionary *receivedItemDict = [receivedItems objectAtIndex:i];
        Item *receivedItem = [receivedItemDict objectForKey:@"item"];
        int qty = [((NSNumber *)[receivedItemDict objectForKey:@"delta"]) intValue];
        
        NSString *notifString;
        if(receivedItem.maxQty == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", receivedItem.name, NSLocalizedString(@"ReceivedNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"+%d %@ : %d %@",  qty, receivedItem.name, receivedItem.qty, NSLocalizedString(@"TotalNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithString:notifString];
        
        NSLog(@"NSNotification: NewlyChangedItemsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedItemsGameNotificationSent" object:self]];
    }
}

-(void)parseLostItemsIntoNotifications:(NSNotification *)notification
{
    NSArray *lostItems = (NSArray *)[notification.userInfo objectForKey:@"newlyLostItems"];

    for(int i = 0; i < [lostItems count]; i++)
    {
        NSDictionary *lostItemDict = [lostItems objectAtIndex:i];
        Item *lostItem = [lostItemDict objectForKey:@"item"];
        int qty = [((NSNumber *)[lostItemDict objectForKey:@"delta"]) intValue];
        
        NSString *notifString;
        if(lostItem.maxQty == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", lostItem.name, NSLocalizedString(@"LostNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"-%d %@ : %d %@",  qty, lostItem.name, lostItem.qty, NSLocalizedString(@"LeftNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithString:notifString];
        
        NSLog(@"NSNotification: NewlyChangedItemsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedItemsGameNotificationSent" object:self]];
    }
}

-(void)parseReceivedAttributesIntoNotifications:(NSNotification *)notification
{
    NSArray *receivedAttributes = (NSArray *)[notification.userInfo objectForKey:@"newlyAcquiredAttributes"];

    for(int i = 0; i < [receivedAttributes count]; i++)
    {
        NSDictionary *receivedAttributeDict = [receivedAttributes objectAtIndex:i];
        Item *receivedAttribute = [receivedAttributeDict objectForKey:@"attribute"];
        int qty = [((NSNumber *)[receivedAttributeDict objectForKey:@"delta"]) intValue];
        
        NSString *notifString;
        if(receivedAttribute.maxQty == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", receivedAttribute.name, NSLocalizedString(@"ReceivedNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"+%d %@ : %d %@",  qty, receivedAttribute.name, receivedAttribute.qty, NSLocalizedString(@"TotalNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithString:notifString];

        NSLog(@"NSNotification: NewlyChangedAttributesGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedAttributesGameNotificationSent" object:self]];
    }

}

-(void)parseLostAttributesIntoNotifications:(NSNotification *)notification
{
    NSArray *lostAttributes = (NSArray *)[notification.userInfo objectForKey:@"newlyLostAttributes"];

    for(int i = 0; i < [lostAttributes count]; i++)
    {
        NSDictionary *lostAttributeDict = [lostAttributes objectAtIndex:i];
        Item *lostAttribute = [lostAttributeDict objectForKey:@"attribute"];
        int qty = [((NSNumber *)[lostAttributeDict objectForKey:@"delta"]) intValue];

        NSString *notifString;
        if(lostAttribute.maxQty == 1)
            notifString = [NSString stringWithFormat:@"%@ %@", lostAttribute.name, NSLocalizedString(@"LostNotifKey", nil)];
        else
            notifString = [NSString stringWithFormat:@"-%d %@ : %d %@",  qty, lostAttribute.name, lostAttribute.qty, NSLocalizedString(@"LeftNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithString:notifString];
        
        NSLog(@"NSNotification: NewlyChangedAttributesGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedAttributesGameNotificationSent" object:self]];
    }
}

-(void)parseAvailableLocationsIntoNotifications:(NSNotification *)notification
{
    NSArray *lostAttributes = (NSArray *)[notification.userInfo objectForKey:@"newlyAvailableLocations"];
    
    for(int i = 0; i < [lostAttributes count]; i++)
    {
        //Doesn't actually show a game notification...
        NSLog(@"NSNotification: NewlyChangedLocationsGameNotificationSent");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedLocationsGameNotificationSent" object:self]];
    }
}

-(void)cutOffGameNotifications
{
    NSLog(@"NSNotification: ClearBadgeRequest");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ClearBadgeRequest" object:self]];
    [notifArray removeAllObjects];
    [popOverArray removeAllObjects];
    showingPopOver  = NO;
}

-(void)startListeningToModel
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

-(void)stopListeningToModel
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

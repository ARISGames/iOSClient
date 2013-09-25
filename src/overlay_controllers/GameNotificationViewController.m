//
//  GameNotificationViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 2/12/13.
//
//

#import "GameNotificationViewController.h"
#import "ARISAppDelegate.h"
#import "PopOverViewController.h"
#import "MTStatusBarOverlay.h"

#import "Item.h"
#import "Quest.h"

@interface GameNotificationViewController() <PopOverViewDelegate, MTStatusBarOverlayDelegate>
{
    UIWebView *dropDownView;
    PopOverViewController *popOverVC;

    NSMutableArray *notifArray;
    NSMutableArray *popOverArray;
    BOOL showingDropDown;
    BOOL showingPopOver;
}
@end

@implementation GameNotificationViewController

- (id) init
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
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.userInteractionEnabled = NO;
    NSLog(@"PHIL- PopoverDisabled 1");  
    
    popOverVC = [[PopOverViewController alloc] initWithDelegate:self];
    //dropDownView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -28.0, [UIScreen mainScreen].bounds.size.width, 28)];
}

- (void) viewWillAppear:(BOOL)animated //first time view should be 'correct' frame
{
    [super viewWillAppear:animated];
    self.view.frame = CGRectMake(0,0,self.view.superview.frame.size.width,self.view.superview.frame.size.height);
    popOverVC.view.frame = self.view.frame;
}

- (void) lowerDropDownFrame
{
    /*
    [self.view addSubview:dropDownView];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.5];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    [UIView commitAnimations];
     */
}

- (void) raiseDropDownFrame
{
    /*
    [dropDownView removeFromSuperview];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:.5];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    [UIView commitAnimations];
     */
}

- (void) dequeueDropDown
{
    /*
    showingDropDown = YES;

    dropDownView.alpha = 0.0;
    NSString* str = [notifArray objectAtIndex:0];
     
    NSString* htmlContentString = [NSString stringWithFormat:
        @"<html>"
        "<style type=\"text/css\">"
        "body{background-color:black;vertical-align:text-top;text-align:center;font:16px Arial,Helvetica,sans-serif;color:white;}"
        "</style>"
        "<body>%@</body>"
        "</html>", str];

    [dropDownView loadHTMLString:htmlContentString baseURL:nil];

    [UIView animateWithDuration:3.0 delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{ dropDownView.alpha = 1.0; }
                     completion:^(BOOL finished){
                        [UIView animateWithDuration:3.0
                                              delay:0.0
                                            options:UIViewAnimationCurveEaseIn
                                         animations:^{ dropDownView.alpha = 0.0; }
                                         completion:^(BOOL finished){
                                             showingDropDown = NO;
                                             if([notifArray count] > 0)
                                                 [self dequeueDropDown];
                                             else
                                                 [self raiseDropDownFrame];
                                         }];
                     }];
    [notifArray removeObjectAtIndex:0];
     */
}

- (void) dequeuePopOver
{
    showingPopOver = YES;
    
    NSMutableDictionary *poDict = [popOverArray objectAtIndex:0];
    [popOverVC setTitle:[poDict objectForKey:@"title"]
            description:[poDict objectForKey:@"description"]
            webViewText:[poDict objectForKey:@"text"]
             andMediaId:[[poDict objectForKey:@"mediaId"] intValue]];
    [self.view addSubview:popOverVC.view];
    [popOverArray removeObjectAtIndex:0];
    self.view.userInteractionEnabled = YES;
    NSLog(@"PHIL- PopoverEnabled"); 
}

- (void) popOverContinueButtonPressed
{
    showingPopOver = NO;
    self.view.userInteractionEnabled = NO;
    NSLog(@"PHIL- PopoverDisabled");
    
    if([popOverArray count] > 0)
        [self dequeuePopOver];
    else
        [popOverVC.view removeFromSuperview];
}

- (void) enqueueDropDownNotificationWithString:(NSString *)string
{
    [[MTStatusBarOverlay sharedInstance] postMessage:string duration:3.0];
    /*
    [notifArray addObject:string];
    if(!showingDropDown)
    {
        [self lowerDropDownFrame];
        [self dequeueDropDown];
    }
     */
}

- (void) enqueuePopOverNotificationWithTitle:(NSString *)title description:(NSString *)description webViewText:(NSString *)text andMediaId:(int) mediaId
{
    [popOverArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",description,@"description",text,@"text",[NSNumber numberWithInt:mediaId],@"mediaId", nil]];
    if(!showingPopOver) [self dequeuePopOver];
}

- (void) parseActiveQuestsIntoNotifications:(NSNotification *)notification
{
    NSArray *activeQuests = (NSArray *)[notification.userInfo objectForKey:@"newlyActiveQuests"];
    
    for(int i = 0; i < [activeQuests count]; i++)
    {
        Quest *activeQuest = [activeQuests objectAtIndex:i];
        
        if(activeQuest.fullScreenNotification)
            [self enqueuePopOverNotificationWithTitle:NSLocalizedString(@"QuestViewNewQuestKey", nil) description:activeQuest.name webViewText:activeQuest.qdescriptionNotification andMediaId:activeQuest.notificationMediaId];
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
            [self enqueuePopOverNotificationWithTitle:NSLocalizedString(@"QuestsViewQuestCompletedKey", nil) description:completedQuest.name webViewText:completedQuest.qdescriptionNotification andMediaId:completedQuest.notificationMediaId];
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

- (void) parseLostItemsIntoNotifications:(NSNotification *)notification
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

- (void) parseReceivedAttributesIntoNotifications:(NSNotification *)notification
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

- (void) parseLostAttributesIntoNotifications:(NSNotification *)notification
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
    //[self raiseDropDownFrame];
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

@end

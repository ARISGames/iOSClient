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

UIWebView *dropDownView;
PopOverViewController *popOverVC;
PopOverContentView *popOverView;

NSMutableArray *notifArray;
NSMutableArray *popOverArray;
BOOL showingDropDown;
BOOL showingPopOver;

@implementation GameNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //Init Notification Arrays
        notifArray = [[NSMutableArray alloc] initWithCapacity:5];
        popOverArray = [[NSMutableArray alloc] initWithCapacity:5];
        showingDropDown = NO;
        showingPopOver = NO;
    }
    return self;
}

-(void)loadView
{
    popOverVC = [[PopOverViewController alloc] initWithNibName:@"PopOverViewController" bundle:nil delegate:self];
    popOverView = (PopOverContentView *)popOverVC.view;
    
    dropDownView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -28, [UIScreen mainScreen].bounds.size.width, 28)];
    dropDownView.backgroundColor = [UIColor whiteColor];
}

-(void)lowerDropDownFrame
{
    [[RootViewController sharedRootViewController].view addSubview:dropDownView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.5];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [UIView commitAnimations];
}

-(void)raiseDropDownFrame
{
    [UIView animateWithDuration:.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn animations:^{
                            [[UIApplication sharedApplication] setStatusBarHidden:NO];
                        }
                     completion:^(BOOL finished){}];
    [dropDownView removeFromSuperview];
}

-(void)dequeueDropDown
{
    NSLog(@"RootViewController: dequeueNotification");
    showingDropDown = YES;
    
    dropDownView.alpha = 0.0;
    NSString* fullString = [[notifArray objectAtIndex:0] objectForKey:@"fullString"];
    NSString* boldString = [[notifArray objectAtIndex:0] objectForKey:@"boldedString"];
    NSString* part1;
    NSString* part2;
    NSString* part3;
    
    NSRange boldRange = [fullString rangeOfString:boldString];
    if (boldRange.location == NSNotFound)
    {
        part1 = fullString;
        part2 = @"";
        part3 = @"";
    }
    else
    {
        part1 = [fullString substringToIndex:boldRange.location];
        part2 = [fullString substringWithRange:boldRange];
        part3 = [fullString substringFromIndex:(boldRange.location + boldRange.length)];
    }
    
    NSString* htmlContentString = [NSString stringWithFormat:
                                   @"<html>"
                                   "<style type=\"text/css\">"
                                   "body { vertical-align:text-top; text-align:center; font-family:Arial; font-size:16; }"
                                   ".different { font:16px Arial,Helvetica,sans-serif; font-weight:bold; color:DarkBlue }"
                                   "</style>"
                                   "<body>%@<span class='different'>%@</span>%@</body>"
                                   "</html>", part1, part2, part3];
    
    [dropDownView loadHTMLString:htmlContentString baseURL:nil];
    
    [UIView animateWithDuration:3.0 delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{ dropDownView.alpha = 1.0; }
                     completion:^(BOOL finished){
                         if(finished)
                         {
                             [UIView animateWithDuration:3.0
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{ dropDownView.alpha = 0.0; }
                                              completion:^(BOOL finished){
                                                  if(finished)
                                                  {
                                                      if([popOverArray count] > 0)
                                                      {
                                                          [self raiseDropDownFrame];
                                                          showingDropDown = NO;
                                                          [self dequeuePopOver];
                                                      }
                                                      else if([notifArray count] > 0)
                                                          [self dequeueDropDown];
                                                      else
                                                      {
                                                          [self raiseDropDownFrame];
                                                          showingDropDown = NO;
                                                      }
                                                  }
                                              }];
                         }
                     }];
    [notifArray removeObjectAtIndex:0];
}

-(void)dequeuePopOver
{
    NSLog(@"RootViewController: dequeuePopOver");
    
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
    if([popOverArray count] > 0)
        [self dequeuePopOver];
    else
    {
        [popOverView removeFromSuperview];
        showingPopOver = NO;
        if([notifArray count] > 0)
            [self dequeueDropDown];
    }
}

-(void)enqueueDropDownNotificationWithFullString:(NSString *)fullString andBoldedString:(NSString *)boldedString
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:fullString,@"fullString",boldedString,@"boldedString", nil];
    [notifArray addObject:dict];
    if(!showingDropDown && !showingPopOver)
    {
        [self lowerDropDownFrame];
        [self dequeueDropDown];
    }
}

-(void)enqueuePopOverNotificationWithTitle:(NSString *)title description:(NSString *)description webViewText:(NSString *)text andMediaId:(int) mediaId
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",description,@"description",text,@"text",[NSNumber numberWithInt:mediaId],@"mediaId", nil];
    [popOverArray addObject:dict];
    if(!showingDropDown && !showingPopOver) [self dequeuePopOver];
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
            [self enqueueDropDownNotificationWithFullString:notifString andBoldedString:activeQuest.name];
        }
        
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
            [self enqueueDropDownNotificationWithFullString: notifString andBoldedString:completedQuest.name];
        }
        
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
        [self enqueueDropDownNotificationWithFullString:notifString andBoldedString:receivedItem.name];
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
            notifString = [NSString stringWithFormat:@"+%d %@ : %d %@",  qty, lostItem.name, lostItem.qty, NSLocalizedString(@"LeftNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithFullString:notifString andBoldedString:lostItem.name];
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
        [self enqueueDropDownNotificationWithFullString:notifString andBoldedString:receivedAttribute.name];
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
            notifString = [NSString stringWithFormat:@"+%d %@ : %d %@",  qty, lostAttribute.name, lostAttribute.qty, NSLocalizedString(@"LeftNotifKey", nil)];
        
        [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        [self enqueueDropDownNotificationWithFullString:notifString andBoldedString:lostAttribute.name];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedAttributesGameNotificationSent" object:self]];
    }
}

-(void)parseAvailableLocationsIntoNotifications:(NSNotification *)notification
{
    NSArray *lostAttributes = (NSArray *)[notification.userInfo objectForKey:@"newlyAvailableLocations"];
    
    for(int i = 0; i < [lostAttributes count]; i++)
    {
        //Don't actually show a notification... 
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyChangedLocationsGameNotificationSent" object:self]];
    }
}

-(void)cutOffGameNotifications
{
    [notifArray removeAllObjects];
    [popOverArray removeAllObjects];
    showingDropDown = NO;
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

//
//  QuestsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import "QuestsModel.h"
#import "Quest.h"

@implementation QuestsModel

@synthesize currentActiveQuests;
@synthesize currentCompletedQuests;
@synthesize totalQuestsInGame;

-(id)init
{
    self = [super init];
    if(self)
    {
        [self clearData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestPlayerQuestListsReceived:) name:@"LatestPlayerQuestListsReceived" object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)clearData
{
    [self updateQuestListsActive:[[NSArray alloc] init] complete:[[NSArray alloc] init]];
}

-(void)latestPlayerQuestListsReceived:(NSNotification *)notification
{
    [self updateQuestListsActive:[notification.userInfo objectForKey:@"active"] complete:[notification.userInfo objectForKey:@"complete"]];
}

-(void)updateQuestListsActive:(NSArray *)activeQuests complete:(NSArray *)completedQuests;
{
    //Active Quests
    NSMutableArray *newlyActiveQuests = [[NSMutableArray alloc] initWithCapacity:5];
    for (Quest *newQuest in activeQuests)
    {
        BOOL match = NO;
        for (Quest *existingQuest in self.currentActiveQuests)
            if (newQuest.questId == existingQuest.questId) match = YES;
        
        if (!match)
            [newlyActiveQuests addObject:newQuest];
    }
    self.currentActiveQuests = activeQuests;
    if([newlyActiveQuests count] > 0)
    {
        NSDictionary *qDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyActiveQuests,@"newlyActiveQuests",
                               activeQuests,     @"allActiveQuests",
                               nil];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyActiveQuestsAvailable" object:self userInfo:qDict]];
    }
    
    //Completed Quests
    NSMutableArray *newlyCompletedQuests = [[NSMutableArray alloc] initWithCapacity:5];
    for (Quest *newQuest in completedQuests)
    {
        BOOL match = NO;
        for (Quest *existingQuest in self.currentCompletedQuests)
            if (newQuest.questId == existingQuest.questId) match = YES;
        
        if (!match)
            [newlyCompletedQuests addObject:newQuest];
    }
    self.currentCompletedQuests = completedQuests;
    if([newlyCompletedQuests count] > 0)
    {
        NSDictionary *qDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyCompletedQuests,@"newlyCompletedQuests",
                               completedQuests,     @"allCompletedQuests",
                               nil];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyCompletedQuestsAvailable" object:self userInfo:qDict]];
    }
}

@end

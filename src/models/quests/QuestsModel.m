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

- (id) init
{
    if(self = [super init])
    {
        [self clearData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestPlayerQuestListsReceived:) name:@"LatestPlayerQuestListsReceived" object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) clearData
{
    [self updateQuestListsActive:[[NSArray alloc] init] complete:[[NSArray alloc] init]];
}

- (void) latestPlayerQuestListsReceived:(NSNotification *)notification
{
    [self updateQuestListsActive:[notification.userInfo objectForKey:@"active"] complete:[notification.userInfo objectForKey:@"completed"]];
}

- (void) updateQuestListsActive:(NSArray *)activeQuests complete:(NSArray *)completedQuests;
{
    //Completed Quests
    NSMutableArray *newlyCompletedQuests = [[NSMutableArray alloc] initWithCapacity:5];
    for(Quest *newQuest in completedQuests)
    {
        BOOL match = NO;
        for(Quest *existingQuest in self.currentCompletedQuests)
            if(newQuest.questId == existingQuest.questId) match = YES;
        
        if(!match)
            [newlyCompletedQuests addObject:newQuest];
    }
    BOOL questLost = NO; //Detect newly 'invisible' quest (no notification, but quests screen will change)
    for(Quest *existingQuest in self.currentCompletedQuests)
    {
        BOOL match = NO;
        for(Quest *newQuest in completedQuests)
            if(newQuest.questId == existingQuest.questId) match = YES;
        
        if(!match)
            questLost = YES;
    }
    self.currentCompletedQuests = [NSArray arrayWithArray:completedQuests];
    if([newlyCompletedQuests count] > 0 || questLost)
    {
        NSDictionary *qDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyCompletedQuests,@"newlyCompletedQuests",
                               completedQuests,     @"allCompletedQuests",
                               nil];
        _ARIS_NOTIF_SEND_(@"NewlyCompletedQuestsAvailable",self,qDict);
    }
    
    //Active Quests
    NSMutableArray *newlyActiveQuests = [[NSMutableArray alloc] initWithCapacity:5];
    for(Quest *newQuest in activeQuests)
    {
        BOOL match = NO;
        for(Quest *existingQuest in self.currentActiveQuests)
            if(newQuest.questId == existingQuest.questId) match = YES;
        
        if(!match)
            [newlyActiveQuests addObject:newQuest];
    }
    questLost = NO; //Detect newly 'invisible' quest (no notification, but quests screen will change)
    for(Quest *existingQuest in self.currentActiveQuests)
    {
        BOOL match = NO;
        for(Quest *newQuest in activeQuests) 
            if(newQuest.questId == existingQuest.questId) match = YES;
        
        if(!match)
            questLost = YES;
    }
    self.currentActiveQuests = [NSArray arrayWithArray:activeQuests]; 
    if([newlyActiveQuests count] > 0 || questLost)
    {
        NSDictionary *qDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyActiveQuests,@"newlyActiveQuests",
                               activeQuests,     @"allActiveQuests",
                               nil];
        _ARIS_NOTIF_SEND_(@"NewlyActiveQuestsAvailable",self,qDict);
    }
}

@end

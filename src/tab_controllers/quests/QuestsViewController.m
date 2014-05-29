//
//  QuestsViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "QuestsViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Quest.h"
#import "QuestCell.h"
#import "QuestDetailsViewController.h"
#import "Media.h"
#import "WebPage.h"
#import "WebPageViewController.h"
#import "ARISWebView.h"
#import "ARISTemplate.h"

static int const ACTIVE_SECTION = 0;
static int const COMPLETED_SECTION = 1;

@interface QuestsViewController() <UITableViewDataSource, UITableViewDelegate, ARISWebViewDelegate, StateControllerProtocol, QuestCellDelegate, QuestDetailsViewControllerDelegate>
{
    NSArray *sortedActiveQuests;
    NSArray *sortedCompletedQuests;
    NSMutableDictionary *activeQuestCellHeights;
    NSMutableDictionary *completedQuestCellHeights; 
    
	UITableView *questsTable;
    UIButton *activeButton;
    UIButton *completeButton; 
    
    int questTypeShown;
    
    id<QuestsViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@end

@implementation QuestsViewController

- (id) initWithDelegate:(id<QuestsViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"QUESTS";
        self.tabIconName = @"todo";
        self.title = NSLocalizedString(@"QuestViewTitleKey",@""); 
        
        questTypeShown = ACTIVE_SECTION;
        sortedActiveQuests = [[NSArray alloc] init];
        sortedCompletedQuests = [[NSArray alloc] init];
        activeQuestCellHeights = [[NSMutableDictionary alloc] initWithCapacity:10];
        completedQuestCellHeights = [[NSMutableDictionary alloc] initWithCapacity:10];  
        
        delegate = d;
        
  _ARIS_NOTIF_LISTEN_(@"ConnectionLost",self,@selector(removeLoadingIndicator),nil);
  _ARIS_NOTIF_LISTEN_(@"LatestPlayerQuestListsReceived",self,@selector(removeLoadingIndicator),nil);  
  _ARIS_NOTIF_LISTEN_(@"NewlyActiveQuestsAvailable",self,@selector(refreshViewFromModel),nil);
  _ARIS_NOTIF_LISTEN_(@"NewlyCompletedQuestsAvailable",self,@selector(refreshViewFromModel),nil);
  _ARIS_NOTIF_LISTEN_(@"NewlyActiveQuestsGameNotificationSent",self,@selector(incrementBadge),nil);
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    questsTable = [[UITableView alloc]  init];
    questsTable.dataSource = self;
    questsTable.delegate = self; 
    
    activeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [activeButton setTitle:NSLocalizedString(@"QuestsActiveTitleKey", @"") forState:UIControlStateNormal];
    [activeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
    activeButton.backgroundColor = [UIColor ARISColorDarkBlue];
    activeButton.titleLabel.font = [ARISTemplate ARISButtonFont];
    [activeButton addTarget:self action:@selector(activeButtonTouched) forControlEvents:UIControlEventTouchUpInside];
       
    completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [completeButton setTitle:NSLocalizedString(@"QuestsCompleteTitleKey", @"") forState:UIControlStateNormal];
    [completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
    completeButton.backgroundColor = [UIColor ARISColorLightBlue]; 
    completeButton.titleLabel.font = [ARISTemplate ARISButtonFont];
    [completeButton addTarget:self action:@selector(completeButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    [self.view addSubview:questsTable];
    [self.view addSubview:activeButton]; 
    [self.view addSubview:completeButton]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    activeButton.frame   = CGRectMake(0, 64, self.view.bounds.size.width/2, 40);
    completeButton.frame = CGRectMake(self.view.bounds.size.width/2, 64, self.view.bounds.size.width/2, 40);  
    
    //apple. so dumb.
    questsTable.frame = self.view.bounds;
    questsTable.contentInset = UIEdgeInsetsMake(104,0,40,0);
    [questsTable setContentOffset:CGPointMake(0,-104)]; 
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[[AppServices sharedAppServices] updateServerQuestsViewed];
    [self refreshViewFromModel];
	[self refresh];
}

- (void) refresh
{
	[[AppServices sharedAppServices] fetchPlayerQuestList];
	[self showLoadingIndicator];
}

-(void) refreshViewFromModel
{
    /*
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortNum" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    sortedActiveQuests    = [_MODEL_GAME_.questsModel.currentActiveQuests    sortedArrayUsingDescriptors:sortDescriptors];
    sortedCompletedQuests = [_MODEL_GAME_.questsModel.currentCompletedQuests sortedArrayUsingDescriptors:sortDescriptors];
    
    if(sortedActiveQuests.count == 0)   
    {
        Quest *nullQuest = [[Quest alloc] init];
        nullQuest.questId = -1;
        //nullQuest.name = @"<span style='color:#555555;'>Empty</span>";
        nullQuest.name = NSLocalizedString(@"EmptyKey", @"");
        nullQuest.desc = [NSString stringWithFormat:@"<span style='color:#555555;'>(%@)</span>", NSLocalizedString(@"QuestViewNoQuestsAvailableKey", @"")];
        sortedActiveQuests = [NSArray arrayWithObjects:nullQuest, nil]; 
    }
    if(sortedCompletedQuests.count == 0)  
    {
        Quest *nullQuest = [[Quest alloc] init];
        nullQuest.questId = -1;
        //nullQuest.name = @"<span style='color:#555555;'>Empty</span>";
        nullQuest.name = NSLocalizedString(@"EmptyKey", @"");
        nullQuest.desc = [NSString stringWithFormat:@"<span style='color:#555555;'>(%@)</span>", NSLocalizedString(@"QuestViewNoCompletedQuestsKey", @"")];
        sortedCompletedQuests = [NSArray arrayWithObjects:nullQuest, nil];
    }
    
    [questsTable reloadData];
     */
}

-(void)showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator
{
	[[self navigationItem] setRightBarButtonItem:nil];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(questTypeShown == ACTIVE_SECTION)    return sortedActiveQuests.count;
    if(questTypeShown == COMPLETED_SECTION) return sortedCompletedQuests.count;
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestCell *cell = [questsTable dequeueReusableCellWithIdentifier:@"QuestCell"];
    if(!cell) cell = [[QuestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QuestCell"];
    
    if(questTypeShown == ACTIVE_SECTION)
        [cell setQuest:[sortedActiveQuests objectAtIndex:indexPath.row]]; 
    if(questTypeShown == COMPLETED_SECTION)
        [cell setQuest:[sortedCompletedQuests objectAtIndex:indexPath.row]]; 
    
    [cell setDelegate:self];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Quest *q;
    NSArray *quests;
    NSDictionary *heights;
    if(questTypeShown == ACTIVE_SECTION) 
    {
        quests = sortedActiveQuests;
        heights = activeQuestCellHeights;
    }
    if(questTypeShown == COMPLETED_SECTION) 
    {
        quests = sortedCompletedQuests;
        heights = completedQuestCellHeights; 
    }
    
    q = [quests objectAtIndex:indexPath.row];
    if([heights objectForKey:[q description]])
        return [((NSNumber *)[heights objectForKey:[q description]])intValue];  
    
	CGSize calcSize = [q.desc sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(self.view.bounds.size.width, 2000000) lineBreakMode:NSLineBreakByWordWrapping];
	return calcSize.height+30; 
}

- (void) heightCalculated:(int)h forQuest:(Quest *)q inCell:(QuestCell *)qc
{
    NSDictionary *heights; 
    if(questTypeShown == ACTIVE_SECTION)    heights = activeQuestCellHeights;
    if(questTypeShown == COMPLETED_SECTION) heights = completedQuestCellHeights; 
    
    if(![heights objectForKey:[q description]])
    {
        [heights setValue:[NSNumber numberWithInt:h] forKey:[q description]]; 
        [questsTable reloadData];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Quest *q;
    if(questTypeShown == ACTIVE_SECTION)
        q = [sortedActiveQuests objectAtIndex:indexPath.row];
    if(questTypeShown == COMPLETED_SECTION)
        q = [sortedCompletedQuests objectAtIndex:indexPath.row]; 
    
    [[self navigationController] pushViewController:[[QuestDetailsViewController alloc] initWithQuest:q delegate:self] animated:YES]; 
}

- (void) questDetailsRequestsDismissal
{
    [[self navigationController] popToViewController:self animated:YES];
}

- (void) activeButtonTouched
{
    questTypeShown = ACTIVE_SECTION;
    [activeButton setBackgroundColor:[UIColor ARISColorDarkBlue]];
    [completeButton setBackgroundColor:[UIColor ARISColorLightBlue]];   
    [questsTable reloadData];
}

- (void) completeButtonTouched
{
    questTypeShown = COMPLETED_SECTION;
    [completeButton setBackgroundColor:[UIColor ARISColorDarkBlue]];
    [activeButton setBackgroundColor:[UIColor ARISColorLightBlue]];  
    [questsTable reloadData];
}

- (void) displayTab:(NSString *)t
{
    [delegate displayTab:t];
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [delegate displayScannerWithPrompt:p];
}

- (BOOL) displayGameObject:(id)g fromSource:(id)s
{
    return [delegate displayGameObject:g fromSource:s]; 
}

- (void)dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);                               
}

@end

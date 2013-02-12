//
//  QuestsViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "QuestsViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "Quest.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "WebPage.h"
#import "webpageViewController.h"

static NSString * const OPTION_CELL = @"quest";
static int const ACTIVE_SECTION = 0;
static int const COMPLETED_SECTION = 1;

NSString *const kQuestsHtmlTemplate =
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: #E9E9E9;"
@"		color: #000000;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0;"
@"	}"
@"	h1 {"
@"		color: #000000;"
@"		font-size: 18px;"
@"		font-style: bold;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0 0 10 0;"
@"	}"
@"  ul,ol"
@"  {"
@"      text-align:left;"
@"  }"
@"	--></style>"
@"</head>"
@"<body></div><div style=\"position:relative; top:0px; background-color:#DDDDDD; border-style:ridge; border-width:3px; border-radius:11px; border-color:#888888; padding:15px; text-align:center;\"><h1 style=\"display:block; margin:0px auto;\">%@</h1>%@</div></body>"
@"</html>";

int cellsLoaded;
BOOL isLink;

@implementation QuestsViewController

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self)
    {
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"117-todo"];
        
        sortedActiveQuests =    [[NSArray alloc] init];
        sortedCompletedQuests = [[NSArray alloc] init];
        
		cellsLoaded = 0;
		isLink = NO;
        
        //register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"    object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedQuestList" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewQuestListReady" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(silenceNextUpdate)      name:@"SilentNextUpdate"  object:nil];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"QuestsViewController: viewDidAppear");
    
    if (![AppModel sharedAppModel].loggedIn || [AppModel sharedAppModel].currentGame.gameId==0)
    {
        NSLog(@"QuestsVC: Player is not logged in, don't refresh");
        return;
    }
    
	[[AppServices sharedAppServices] updateServerQuestsViewed];
	
	[self refresh];
	
	self.tabBarItem.badgeValue = nil;
	newItemsSinceLastView = 0;
	silenceNextServerUpdateCount = 0;
}

- (IBAction)sortQuestsButtonTouched
{
    NSLog(@"%d", activeQuestsSwitch.selectedSegmentIndex);
    [self refreshViewFromModel];
}

- (void)silenceNextUpdate
{
	silenceNextServerUpdateCount++;
	NSLog(@"QuestsViewController: silenceNextUpdate. Count is %d",silenceNextServerUpdateCount );
}

-(void)dismissTutorial
{
	[[RootViewController sharedRootViewController].tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindQuestsTab];
}

- (void)refresh
{
	NSLog(@"QuestsViewController: refresh requested");
	if ([AppModel sharedAppModel].loggedIn) [[AppServices sharedAppServices] fetchQuestList];
	[self showLoadingIndicator];
}

-(void)refreshViewFromModel
{
    if(![RootViewController sharedRootViewController].usesIconQuestView){
        NSLog(@"QuestsViewController: Refreshing view from model");
        
        ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
        progressLabel.text = [NSString stringWithFormat:@"%d %@ %d %@", [AppModel sharedAppModel].currentGame.completedQuests, NSLocalizedString(@"OfKey", @"Number of Number"), [AppModel sharedAppModel].currentGame.totalQuests, NSLocalizedString(@"QuestsCompleteKey", @"")];
        progressView.progress = (float)[AppModel sharedAppModel].currentGame.completedQuests / (float)[AppModel sharedAppModel].currentGame.totalQuests;
        
        NSLog(@"QuestsViewController: refreshViewFromModel: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
        
        //Update the badge
        if (silenceNextServerUpdateCount < 1)
        {
            NSArray *newCompletedQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"completed"];
            
            for (Quest *quest in newCompletedQuestsArray)
            {
                BOOL match = NO;
                for (Quest *existingQuest in [quests objectAtIndex:COMPLETED_SECTION])
                {
                    if (existingQuest.questId == quest.questId) match = YES;
                }
                if (match == NO)
                {
                    [appDelegate playAudioAlert:@"inventoryChange" shouldVibrate:YES];
                    
                    if(quest.fullScreenNotification)
                        [[RootViewController sharedRootViewController] enqueuePopOverWithTitle:NSLocalizedString(@"QuestsViewQuestCompletedKey", nil) description:quest.name webViewText:quest.description andMediaId:quest.mediaId];
                    else
                    {
                        NSString *notifString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestsViewQuestCompletedKey", nil), quest.name] ;
                        [[RootViewController sharedRootViewController] enqueueNotificationWithFullString: notifString andBoldedString:quest.name];
                    }
                    
                }
            }
            
            //Check if anything is new since last time
            int newItems = 0;
            NSArray *newActiveQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"active"];
            for (Quest *quest in newActiveQuestsArray)
            {
                BOOL match = NO;
                for (Quest *existingQuest in [quests objectAtIndex:ACTIVE_SECTION])
                {
                    if (existingQuest.questId == quest.questId) match = YES;
                }
                if (match == NO)
                {
                    newItems ++;;
                    
                    if(quest.fullScreenNotification)
                        [[RootViewController sharedRootViewController] enqueuePopOverWithTitle:NSLocalizedString(@"QuestViewNewQuestKey", nil) description:quest.name webViewText:quest.description andMediaId:quest.mediaId];
                    else
                    {
                        NSString *notifString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestViewNewQuestKey", nil), quest.name] ;
                        [[RootViewController sharedRootViewController] enqueueNotificationWithFullString: notifString andBoldedString:quest.name];
                    }
                }
            }
            
            if (newItems > 0)
            {
                newItemsSinceLastView += newItems;
                self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newItemsSinceLastView];
                
                if (![AppModel sharedAppModel].hasSeenQuestsTabTutorial)
                {
                    //Put up the tutorial tab
                    [[RootViewController sharedRootViewController].tutorialViewController showTutorialPopupPointingToTabForViewController:self.navigationController
                                                                                                                                     type:tutorialPopupKindQuestsTab
                                                                                                                                    title:NSLocalizedString(@"QuestViewNewQuestKey", @"")
                                                                                                                                  message:NSLocalizedString(@"QuestViewNewQuestMessageKey", @"")];
                    [AppModel sharedAppModel].hasSeenQuestsTabTutorial = YES;
                    [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
                }
            }
            else if (newItemsSinceLastView < 1)
                self.tabBarItem.badgeValue = nil;
        }
        else
        {
            newItemsSinceLastView = 0;
            self.tabBarItem.badgeValue = nil;
        }
        
        //rebuild the list
        NSArray *activeQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"active"];
        NSArray *completedQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"completed"];
        
        quests = [NSArray arrayWithObjects:activeQuestsArray, completedQuestsArray, nil];
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortNum"
                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        sortedActiveQuests = [[quests objectAtIndex:ACTIVE_SECTION] sortedArrayUsingDescriptors:sortDescriptors];
        sortedCompletedQuests = [[quests objectAtIndex:COMPLETED_SECTION] sortedArrayUsingDescriptors:sortDescriptors];
        
        [self constructCells];
	}
	if(silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
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
	NSLog(@"QuestsViewController: removeLoadingIndicator");
}

-(void)constructCells{
	NSLog(@"QuestsVC: Constructing Cells");
	//Iterate through each element in quests and save the cell into questCells
	NSMutableArray *activeQuestCells = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray *completedQuestCells = [NSMutableArray arrayWithCapacity:10];
	
	NSEnumerator *e;
	Quest *quest;
    
    NSLog(@"QuestsVC: Active Quests Selected");
    e = [sortedActiveQuests objectEnumerator];
    while ((quest = (Quest*)[e nextObject]))
        [activeQuestCells addObject: [self getCellContentViewForQuest:quest inSection:ACTIVE_SECTION]];
    
    /*
     This adds a "No new quests" quest to the quest list. Commented out for sizing issues to be dealt with later.
     if([activeQuestCells count] == 0){
     activeQuestsEmpty = YES;
     Quest *nullQuest = [[Quest alloc] init];
     nullQuest.isNullQuest = true;
     nullQuest.questId = -1;
     nullQuest.name = @"Empty";
     nullQuest.description = @"(there are no quests available at this time)";
     NSMutableArray *activeQuestsMutable = [[NSMutableArray alloc] initWithArray: activeQuests];
     [activeQuestsMutable addObject: nullQuest];
     activeQuests = (NSArray *)activeQuestsMutable;
     [activeQuestCells addObject: [self getCellContentViewForQuest:nullQuest inSection:ACTIVE_SECTION]];
     //[self updateCellSize: [activeQuestCells objectAtIndex:0]];
     }
     */
    
    e = [sortedCompletedQuests objectEnumerator];
    NSLog(@"QuestsVC: Completed Quests Selected");
    while ((quest = (Quest*)[e nextObject]))
        [completedQuestCells addObject:[self getCellContentViewForQuest:quest inSection:COMPLETED_SECTION]];
    
    /*
     This adds a "No new quests" quest to the quest list. Commented out for sizing issues to be dealt with later.
     if([completedQuestCells count] == 0){
     completedQuestsEmpty = YES;
     
     Quest *nullQuest = [[Quest alloc] init];
     nullQuest.isNullQuest = true;
     nullQuest.questId = -1;
     nullQuest.name = @"Empty";
     nullQuest.description = @"(you have not completed any quests)";
     NSMutableArray *activeQuestsMutable = [[NSMutableArray alloc] initWithArray: activeQuests];
     [activeQuestsMutable addObject: nullQuest];
     activeQuests = (NSArray *)activeQuestsMutable;
     [completedQuestCells addObject: [self getCellContentViewForQuest:nullQuest inSection:COMPLETED_SECTION]];
     // [self updateCellSize: [completedQuestCells objectAtIndex:0]];
     }
     */
    
	questCells = [NSArray arrayWithObjects:activeQuestCells,completedQuestCells, nil];
	
	//if (activeQuestsEmpty && completedQuestsEmpty)
    [tableView reloadData];
	
	NSLog(@"QuestsVC: Cells created and stored in questCells");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
    if(isLink && ![[[request URL] absoluteString] isEqualToString:@"about:blank"])
    {
        webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle:[NSBundle mainBundle]];
        WebPage *temp = [[WebPage alloc] init];
        temp.url = [[request URL] absoluteString];
        webPageViewController.webPage = temp;
        webPageViewController.delegate = self;
        [self.navigationController pushViewController:webPageViewController animated:NO];
        return NO;
    }
    else
    {
        isLink = YES;
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	cellsLoaded++;
	int cellTotal = [[quests objectAtIndex:ACTIVE_SECTION] count] + [[quests objectAtIndex:COMPLETED_SECTION] count];
	
	NSLog(@"QuestsViewController: VebView loaded: Cell Total:%d Current Cell Count:%d",cellTotal,cellsLoaded);
    
	if(cellsLoaded == cellTotal)
	{
		cellsLoaded = 0;
		[self performSelector:@selector(updateCellSizes) withObject:nil afterDelay:0.1];
	}
}

-(void)updateCellSizes
{
	//Loop through each object in quests and calculate the heights
	NSArray *activeQuestCells = [questCells objectAtIndex:ACTIVE_SECTION];
	NSArray *completedQuestCells = [questCells objectAtIndex:COMPLETED_SECTION];
	NSEnumerator *e;
	UITableViewCell *cell;
	
	e = [activeQuestCells objectEnumerator];
	while ((cell = (UITableViewCell*)[e nextObject]))
		[self updateCellSize:cell];
	
	e = [completedQuestCells objectEnumerator];
	while ((cell = (UITableViewCell*)[e nextObject]))
		[self updateCellSize:cell];
	
	[tableView reloadData];
}

-(void)updateCellSize:(UITableViewCell*)cell
{
	NSLog(@"QuestViewController: Updating Cell Sizes");
	UIWebView *descriptionView = (UIWebView *)[cell viewWithTag:1];
	float newHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];// = 3;

	CGRect descriptionFrame = [descriptionView frame];
	descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight);
	[descriptionView setFrame:descriptionFrame];
	[[[descriptionView subviews] lastObject] setScrollEnabled:NO];

	CGRect cellFrame = [cell frame];
	cellFrame.size = CGSizeMake(cell.frame.size.width,newHeight + 25);
	[cell setFrame:cellFrame];
}

#pragma mark PickerViewDelegate selectors

- (UITableViewCell *) getCellContentViewForQuest:(Quest *)quest inSection:(int)section
{
	CGRect cellFrame = CGRectMake(0, 0, 320, 100);
	CGRect descriptionFrame = CGRectMake(5, 10, 310, 50);
	
	UIWebView *descriptionView;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:cellFrame];
	
	//Setup Cell
	UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.backgroundView = transparentBackground;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	//Initialize Description with Tag 1
	descriptionView = [[UIWebView alloc] initWithFrame:descriptionFrame];
	descriptionView.delegate = self;
	descriptionView.tag = 1;
	[descriptionView setBackgroundColor:[UIColor clearColor]];
	NSString *htmlDescription = [NSString stringWithFormat:kQuestsHtmlTemplate, quest.name, quest.description];
	[descriptionView loadHTMLString:htmlDescription baseURL:nil];
	[cell.contentView addSubview:descriptionView];
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int num = 0;
    if(activeQuestsSwitch.selectedSegmentIndex == 0){
        NSMutableArray *array = [questCells objectAtIndex:ACTIVE_SECTION];
        num = [array count];
        NSLog(@"QuestsVC: %d rows ",num);
    }
    else {
        NSMutableArray *array = [questCells objectAtIndex:COMPLETED_SECTION];
        num = [array count];
        NSLog(@"QuestsVC: %d rows ",num);
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(activeQuestsSwitch.selectedSegmentIndex == 0){
        NSArray *sectionArray = [questCells objectAtIndex:ACTIVE_SECTION];
        UITableViewCell *cell = [sectionArray objectAtIndex:indexPath.row];
        NSLog(@"QuestsVC: Returning a cell for row: %d",indexPath.row);
        
        return cell;
    }
    else {
        NSArray *sectionArray = [questCells objectAtIndex:COMPLETED_SECTION];
        UITableViewCell *cell = [sectionArray objectAtIndex:indexPath.row];
        NSLog(@"QuestsVC: Returning a cell for row: %d",indexPath.row);
        
        return cell;
    }
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(activeQuestsSwitch.selectedSegmentIndex == 0){
        UITableViewCell *cell = [[questCells objectAtIndex:ACTIVE_SECTION] objectAtIndex:indexPath.row];
        int height = cell.frame.size.height;
        NSLog(@"QuestsVC: Height for Cell: %d",height);
        return height;
    }
    else {
        UITableViewCell *cell = [[questCells objectAtIndex:COMPLETED_SECTION] objectAtIndex:indexPath.row];
        int height = cell.frame.size.height;
        NSLog(@"QuestsVC: Height for Cell: %d",height);
        return height;
    }
	
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
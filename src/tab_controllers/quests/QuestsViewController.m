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
#import "WebPageViewController.h"

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
@"  #cell {"
@"      position:relative;"
@"      top:0px;"
@"      background-color:#DDDDDD;"
@"      border-style:ridge;"
@"      border-width:3px;"
@"      border-radius:11px;"
@"      border-color:#888888;"
@"      padding:15px;"
@"      text-align:center;"
@"  }"
@"	#title {"
@"		display:block;"
@"		margin:0px auto;"
@"	}"
@"	--></style>"
@"</head>"
@"<body>"
@"<div id=\"cell\">"
@"<h1 id=\"title\">"
@"%@"
@"</h1>"
@"%@"
@"</div>"
@"</body>"
@"</html>";

@interface QuestsViewController()
{
    id<QuestsViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation QuestsViewController

- (id)initWithDelegate:(id<QuestsViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"QuestsViewController" bundle:nil])
    {
        delegate = d;
        
		cellsLoaded = 0;
        
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"117-todo"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"                object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedQuestList"             object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyActiveQuestsAvailable"    object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyCompletedQuestsAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge)         name:@"NewlyChangedQuestsGameNotificationSent" object:nil];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[[AppServices sharedAppServices] updateServerQuestsViewed];
    [self refreshViewFromModel];
	[self refresh];
}

- (IBAction) sortQuestsButtonTouched
{
    [self refreshViewFromModel];
}

-(void) dismissTutorial
{
    if(delegate) [delegate dismissTutorial];
}

- (void) refresh
{
	[[AppServices sharedAppServices] fetchPlayerQuestList];
	[self showLoadingIndicator];
}

-(void) refreshViewFromModel
{
    if(![AppModel sharedAppModel].hasSeenQuestsTabTutorial)
    {
        [delegate showTutorialPopupPointingToTabForViewController:self title:NSLocalizedString(@"QuestViewNewQuestKey", @"") message:NSLocalizedString(@"QuestViewNewQuestMessageKey", @"")];
        
        [AppModel sharedAppModel].hasSeenQuestsTabTutorial = YES;
        [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortNum" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    sortedActiveQuests    = [[AppModel sharedAppModel].currentGame.questsModel.currentActiveQuests    sortedArrayUsingDescriptors:sortDescriptors];
    sortedCompletedQuests = [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests sortedArrayUsingDescriptors:sortDescriptors];
    
    [self constructCells];
    
    progressLabel.text = [NSString stringWithFormat:@"%d %@ %d %@", [sortedCompletedQuests count], NSLocalizedString(@"OfKey", @"Number of Number"), [AppModel sharedAppModel].currentGame.questsModel.totalQuestsInGame, NSLocalizedString(@"QuestsCompleteKey", @"")];
    progressView.progress = (float)[sortedCompletedQuests count] / (float)[AppModel sharedAppModel].currentGame.questsModel.totalQuestsInGame;
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

-(void)constructCells
{	
	NSEnumerator *e;
	Quest *quest;
    
    //Active
    activeQuestCells = [NSMutableArray arrayWithCapacity:10];
    e = [sortedActiveQuests objectEnumerator];
    while ((quest = (Quest*)[e nextObject]))
        [activeQuestCells addObject:[self getCellContentViewForQuest:quest]];
    if([activeQuestCells count] == 0)
    {
        Quest *nullQuest = [[Quest alloc] init];
        nullQuest.questId = -1;
        nullQuest.name = @"<span style='color:#555555;'>Empty</span>";
        nullQuest.qdescription = @"<span style='color:#555555;'>(there are no quests available at this time)</span>";
        [activeQuestCells addObject:[self getCellContentViewForQuest:nullQuest]];
    }
    
    //Completed
    completedQuestCells = [NSMutableArray arrayWithCapacity:10];
    e = [sortedCompletedQuests objectEnumerator];
    while((quest = (Quest*)[e nextObject]))
        [completedQuestCells addObject:[self getCellContentViewForQuest:quest]];
    if([completedQuestCells count] == 0)
    {
        Quest *nullQuest = [[Quest alloc] init];
        nullQuest.questId = -1;
        nullQuest.name = @"<span style='color:#555555;'>Empty</span>";
        nullQuest.qdescription = @"<span style='color:#555555;'>(you have not completed any quests)</span>";
        [completedQuestCells addObject:[self getCellContentViewForQuest:nullQuest]];
    }
	
    [tableView reloadData];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(![[[request URL] absoluteString] isEqualToString:@"about:blank"])
    {
        WebPage *tempWebPage = [[WebPage alloc] init];
        tempWebPage.url = [[request URL] absoluteString];
        //PHIL [[RootViewController sharedRootViewController] displayGameObject:tempWebPage];
        return NO;
    }
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
	cellsLoaded++;
	int cellTotal = [sortedActiveQuests count]+[sortedCompletedQuests count];
    if([sortedActiveQuests    count] == 0) cellTotal++; //For 'null quest'
    if([sortedCompletedQuests count] == 0) cellTotal++; //For 'null quest'
	    
	if(cellsLoaded >= cellTotal)
	{
		cellsLoaded = 0;
		[self performSelector:@selector(updateCellSizes) withObject:nil afterDelay:0.1];
	}
}

-(void)updateCellSizes
{
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
	UIWebView *descriptionView = (UIWebView *)[cell viewWithTag:1];
	float newHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];

	CGRect descriptionFrame = [descriptionView frame];
	descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight);
	descriptionView.frame = descriptionFrame;

	CGRect cellFrame = [cell frame];
	cellFrame.size = CGSizeMake(cell.frame.size.width,newHeight + 25);
	[cell setFrame:cellFrame];
}

#pragma mark PickerViewDelegate selectors

- (UITableViewCell *) getCellContentViewForQuest:(Quest *)quest
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UIWebView *descriptionView = [[UIWebView alloc] initWithFrame:CGRectMake(5, 10, 310, 50)];
	descriptionView.delegate = self;
	descriptionView.tag = 1;
	descriptionView.backgroundColor = [UIColor clearColor];
	[descriptionView loadHTMLString:[NSString stringWithFormat:kQuestsHtmlTemplate, quest.name, quest.qdescription] baseURL:nil];
    
	[cell.contentView addSubview:descriptionView];
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(activeQuestsSwitch.selectedSegmentIndex == 0)
        return [activeQuestCells count];
    else
        return [completedQuestCells count];
}

- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(activeQuestsSwitch.selectedSegmentIndex == 0)
        return [activeQuestCells objectAtIndex:indexPath.row];
    else
        return [completedQuestCells objectAtIndex:indexPath.row];
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(activeQuestsSwitch.selectedSegmentIndex == 0)
        return ((UITableViewCell *)[activeQuestCells objectAtIndex:indexPath.row]).frame.size.height;
    else
        return ((UITableViewCell *)[completedQuestCells objectAtIndex:indexPath.row]).frame.size.height;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

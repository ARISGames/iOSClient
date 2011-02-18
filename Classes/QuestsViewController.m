//
//  TODOViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "QuestsViewController.h"
#import "ARISAppDelegate.h"
#import "Quest.h"
#import "Media.h"
#import "AsyncImageView.h"


static NSString * const OPTION_CELL = @"quest";
static int const ACTIVE_SECTION = 0;
static int const COMPLETED_SECTION = 1;

NSString *const kQuestsHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: #000000;"
@"		color: #FFFFFF;"
@"		font-size: 14px;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0;"
@"	}"
@"	h1 {"
@"		background-color: #000000;"
@"		color: #CCCCCC;"
@"		font-size: 18px;"
@"		font-style: bold;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0 0 10 0;"
@"	}"
@"	a {color: #FFFFFF; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body><h1>%@</h1>%@</body>"
@"</html>";


@implementation QuestsViewController

@synthesize quests,questCells;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"quest.png"];
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
		silenceNextServerUpdateCount = 1;
		newItemsSinceLastView = 0;

		cellsLoaded = 0;
		
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedQuestList" object:nil];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewQuestListReady" object:nil];
		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];

    }
    return self;
}

- (void)silenceNextUpdate {
	silenceNextServerUpdateCount++;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self refresh];		
	NSLog(@"QuestsViewController: Quests View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	[appModel updateServerQuestsViewed];
	
	[self refresh];
	
	//remove any existing badge
	self.tabBarItem.badgeValue = nil;
	newItemsSinceLastView = 0;
	
	NSLog(@"QuestsViewController: Quests View Did Appear");
}

- (void)refresh {
	NSLog(@"QuestsViewController: refresh requested");
	if (appModel.loggedIn) [appModel fetchQuestList];
	[self showLoadingIndicator];
}


-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
		[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[barButton release];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator{
	[[self navigationItem] setRightBarButtonItem:nil];
}

-(void)refreshViewFromModel {
	NSLog(@"QuestsViewController: Refreshing view from model");
	
	//Update the badge
	if (silenceNextServerUpdateCount < 1) {
		//Check if anything is new since last time
		int newItems = 0;
		NSArray *newActiveQuestsArray = [appModel.questList objectForKey:@"active"];
		for (Quest *quest in newActiveQuestsArray) {		
			BOOL match = NO;
			for (Quest *existingQuest in [self.quests objectAtIndex:ACTIVE_SECTION]) {
				if (existingQuest.questId == quest.questId) match = YES;	
			}
			if (match == NO) {
				newItems ++;;
			}
		}
		if (newItems > 0) {
			newItemsSinceLastView += newItems;
			self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newItemsSinceLastView];
			
			if (!appModel.hasSeenQuestsTabTutorial){
			//Put up the tutorial tab
				ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
				int myTabIndex = [self.tabBarController.viewControllers indexOfObject:self.navigationController];
				CGFloat myTabCenterXPos = 22.0 + myTabIndex * self.view.frame.size.width / 5;						
				[appDelegate showTutorialPopupPointingTo:myTabCenterXPos
											   withTitle:@"New Quest" 
											  andMessage:@"You have a new Quest! Touch here to see the current and completed quests."];
				appModel.hasSeenQuestsTabTutorial = YES;
			}
		}
		else self.tabBarItem.badgeValue = nil;
				
	}
	else if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
	
	//rebuild the list
	NSArray *activeQuestsArray = [appModel.questList objectForKey:@"active"];
	NSArray *completedQuestsArray = [appModel.questList objectForKey:@"completed"];
	
	if (self.quests) [self.quests release];
	self.quests = [NSArray arrayWithObjects:activeQuestsArray, completedQuestsArray, nil];
	[self.quests retain];

	[self constructCells];
}

-(void)constructCells{
	NSLog(@"QuestsVC: Constructing Cells");
	//Iterate through each element in quests and save the cell into questCells
	NSMutableArray *activeQuestCells = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray *completedQuestCells = [NSMutableArray arrayWithCapacity:10];
	
	NSArray *activeQuests = [self.quests objectAtIndex:ACTIVE_SECTION];
	NSArray *completedQuests = [self.quests objectAtIndex:COMPLETED_SECTION];
	NSEnumerator *e;
	Quest *quest;
	
	e = [activeQuests objectEnumerator];
	while ( (quest = (Quest*)[e nextObject]) ) {
		[activeQuestCells addObject: [self getCellContentViewForQuest:quest inSection:ACTIVE_SECTION]];
	}
	
	e = [completedQuests objectEnumerator];
	while ( (quest = (Quest*)[e nextObject]) ) {
		[completedQuestCells addObject:[self getCellContentViewForQuest:quest inSection:COMPLETED_SECTION]];
	}
	
	self.questCells = [NSArray arrayWithObjects:activeQuestCells,completedQuestCells, nil];
	[self.questCells retain];
	
	if ([activeQuestCells count] == 0 && [completedQuestCells count] == 0) [tableView reloadData];
	
	NSLog(@"QuestsVC: Cells created and stored in questCells");

}

- (BOOL)webView:(UIWebView *)webView  
shouldStartLoadWithRequest:(NSURLRequest *)request  
 navigationType:(UIWebViewNavigationType)navigationType; {  
	
    NSURL *requestURL = [ [ request URL ] retain ];  
	// Check to see what protocol/scheme the requested URL is.  
	if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ]  
		  || [ [ requestURL scheme ] isEqualToString: @"https" ] )  
		&& ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {  
		return ![ [ UIApplication sharedApplication ] openURL: [ requestURL autorelease ] ];  
	}  
	// Auto release  
	[ requestURL release ];  
	// If request url is something other than http or https it will open  
	// in UIWebView. You could also check for the other following  
	// protocols: tel, mailto and sms  
	return YES;  
} 



- (void)webViewDidFinishLoad:(UIWebView *)webView {
	cellsLoaded++;
	int cellTotal = [[self.quests objectAtIndex:ACTIVE_SECTION] count] + [[self.quests objectAtIndex:COMPLETED_SECTION] count];
	
	NSLog(@"QuestsViewController: VebView loaded: Cell Total:%d Current Cell Count:%d",cellTotal,cellsLoaded);

	
	if(cellsLoaded == cellTotal)
	
	{
		cellsLoaded = 0;
		[self performSelector:@selector(updateCellSizes) withObject:nil afterDelay:0.1];
	}
}

-(void)updateCellSizes{
	//Loop through each object in quests and calculate the heights

	NSArray *activeQuestCells = [questCells objectAtIndex:ACTIVE_SECTION];
	NSArray *completedQuestCells = [questCells objectAtIndex:COMPLETED_SECTION];
	NSEnumerator *e;
	UITableViewCell *cell;
	
	e = [activeQuestCells objectEnumerator];
	while ( (cell = (UITableViewCell*)[e nextObject]) ) {
		[self updateCellSize:cell];
	}
	
	e = [completedQuestCells objectEnumerator];
	while ( (cell = (UITableViewCell*)[e nextObject]) ) {
		[self updateCellSize:cell];
	}
	
	[tableView reloadData];
}

-(void)updateCellSize:(UITableViewCell*)cell {
	NSLog(@"QuestViewController: Updating Cell Sizes");

	UIWebView *descriptionView = (UIWebView *)[cell viewWithTag:1];
	float newHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
	
	NSLog(@"QuestViewController: Description View Calculated Height is: %f",newHeight);

	
	CGRect descriptionFrame = [descriptionView frame];	
	descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight);
	[descriptionView setFrame:descriptionFrame];
	[[[descriptionView subviews] lastObject] setScrollEnabled:NO];
	NSLog(@"QuestViewController: description UIWebView frame set to {%f, %f, %f, %f}", 
		  descriptionFrame.origin.x, 
		  descriptionFrame.origin.y, 
		  descriptionFrame.size.width,
		  descriptionFrame.size.height);
	
	CGRect cellFrame = [cell frame];
	cellFrame.size = CGSizeMake(cell.frame.size.width,newHeight + 25);
	[cell setFrame:cellFrame];

	NSLog(@"QuestViewController: cell frame set to {%f, %f, %f, %f}", 
		  cell.frame.origin.x, 
		  cell.frame.origin.y, 
		  cell.frame.size.width,
		  cell.frame.size.height);
}
	


#pragma mark PickerViewDelegate selectors

- (UITableViewCell *) getCellContentViewForQuest:(Quest *)quest inSection:(int)section {
	CGRect cellFrame = CGRectMake(0, 0, 300, 100);
	CGRect iconFrame = CGRectMake(5, 5, 50, 50);
	//CGRect nameFrame = CGRectMake(70, 10, 230, 25);
	CGRect descriptionFrame = CGRectMake(70, 10, 230, 50);
	
	//UILabel *nameView;
	UIWebView *descriptionView;
	AsyncImageView *iconView;
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:cellFrame] autorelease];
	
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
	[descriptionView release];
	
	//Init Icon
	iconView = [[AsyncImageView alloc] initWithFrame:iconFrame];
	//nameView.backgroundColor = [UIColor blackColor];
	
	//Set the icon
	if (quest.iconMediaId > 0) {
		Media *iconMedia = [appModel mediaForMediaId:quest.iconMediaId];
		[iconView loadImageFromMedia:iconMedia];
	}
	else {
		if (section == ACTIVE_SECTION) iconView.image = [UIImage imageNamed:@"QuestActiveIcon.png"];
		if (section == COMPLETED_SECTION) iconView.image = [UIImage imageNamed:@"QuestCompleteIcon.png"];
		
	}
	[cell.contentView addSubview:iconView];
	[iconView release];
	
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int num = [questCells count]; 
	NSLog(@"QuestsVC: %d sections in table", num);
	return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *array = [questCells objectAtIndex:section];
	int num = [array count];
	NSLog(@"QuestsVC: %d rows in section %d",num,section);
	return num;
}

- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	NSArray *sectionArray = [questCells objectAtIndex:indexPath.section];
	UITableViewCell *cell = [sectionArray objectAtIndex:indexPath.row];
	NSLog(@"QuestsVC: Returning a cell for section: %d row: %d",indexPath.section,indexPath.row);

	return cell;
}


// Customize the height of each row
-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[questCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	int height = cell.frame.size.height;
	NSLog(@"QuestsVC: Height for Cell: %d",height);
	return height;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Don't do anything just yet
	//We could add a long description area here
}
*/

- (NSString *)tableView:(UITableView *)view titleForHeaderInSection:(NSInteger)section {
	if (section == ACTIVE_SECTION) return NSLocalizedString(@"QuestsActiveTitleKey",@"");	
	else if (section == COMPLETED_SECTION) return NSLocalizedString(@"QuestsCompleteTitleKey",@"");
	return @"Quests";
}






















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}

@end

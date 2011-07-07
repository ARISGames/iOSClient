//
//  TODOViewController.m
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
@"		background-color: #E9E9E9;"
@"		color: #000000;"
@"		font-size: 14px;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0;"
@"	}"
@"	h1 {"
@"		background-color: #E9E9E9;"
@"		color: #000000;"
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
@synthesize activeQuestsSwitch;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"quest.png"];

		cellsLoaded = 0;
		
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedQuestList" object:nil];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewQuestListReady" object:nil];
		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
    }
	
    return self;
}

- (IBAction)filterQuests {
    NSLog([NSString stringWithFormat:@"%d", activeQuestsSwitch.selectedSegmentIndex]);
    [self refreshViewFromModel];
}

- (void)silenceNextUpdate {
	silenceNextServerUpdateCount++;
	NSLog(@"QuestsViewController: silenceNextUpdate. Count is %d",silenceNextServerUpdateCount );

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"QuestsViewController: Quests View Loaded");
	
}

- (void)viewDidAppear:(BOOL)animated {
	[[AppServices sharedAppServices] updateServerQuestsViewed];
	
	[self refresh];
	
	self.tabBarItem.badgeValue = nil;
	newItemsSinceLastView = 0;
	silenceNextServerUpdateCount = 0;
		
	NSLog(@"QuestsViewController: Quests View Did Appear");
	
}

-(void)dismissTutorial{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindQuestsTab];
}

- (void)refresh {
	NSLog(@"QuestsViewController: refresh requested");
	if ([AppModel sharedAppModel].loggedIn) [[AppServices sharedAppServices] fetchQuestList];
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
	NSLog(@"QuestsViewController: removeLoadingIndicator");
}

-(void)refreshViewFromModel {
	NSLog(@"QuestsViewController: Refreshing view from model");
	
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	progressLabel.text = [NSString stringWithFormat:@"%d of %d Quests Complete", [AppModel sharedAppModel].currentGame.completedQuests, [AppModel sharedAppModel].currentGame.totalQuests];
	progressView.progress = (float)[AppModel sharedAppModel].currentGame.completedQuests / (float)[AppModel sharedAppModel].currentGame.totalQuests;
		
	NSLog(@"QuestsViewController: refreshViewFromModel: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
	
	//Update the badge
	if (silenceNextServerUpdateCount < 1) {
		//Check if anything is new since last time
		int newItems = 0;
		NSArray *newActiveQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"active"];
		for (Quest *quest in newActiveQuestsArray) {		
			BOOL match = NO;
			for (Quest *existingQuest in [self.quests objectAtIndex:ACTIVE_SECTION]) {
				if (existingQuest.questId == quest.questId) match = YES;	
			}
			if (match == NO) {
				newItems ++;;
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"New Quest Available",@"title",quest.name,@"prompt", nil];
                
                [appDelegate performSelector:@selector(displayNotificationTitle:) withObject:dict afterDelay:.1];
                
			}
		}
        
        NSArray *newCompletedQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"completed"];

        for (Quest *quest in newCompletedQuestsArray) {		
			BOOL match = NO;
			for (Quest *existingQuest in [self.quests objectAtIndex:COMPLETED_SECTION]) {
				if (existingQuest.questId == quest.questId) match = YES;	
			}
			if (match == NO) {
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Quest Completed",@"title",quest.name,@"prompt", nil];
                
                [appDelegate performSelector:@selector(displayNotificationTitle:) withObject:dict afterDelay:.1];

			}
		}

        
        
		if (newItems > 0) {
			newItemsSinceLastView += newItems;
			self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newItemsSinceLastView];
			
			if (![AppModel sharedAppModel].hasSeenQuestsTabTutorial){
			//Put up the tutorial tab
				ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
				[appDelegate.tutorialViewController showTutorialPopupPointingToTabForViewController:self.navigationController 
																							   type:tutorialPopupKindQuestsTab 
																							  title:@"New Quest" 
																							message:@"You have a new Quest! Touch here to see the current and completed quests."];						
				[AppModel sharedAppModel].hasSeenQuestsTabTutorial = YES;
                [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
			}
		}
		else if (newItemsSinceLastView < 1) self.tabBarItem.badgeValue = nil;
	
	}
	else {
		newItemsSinceLastView = 0;
		self.tabBarItem.badgeValue = nil;
	}
	
	
	//rebuild the list
	NSArray *activeQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"active"];
	NSArray *completedQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"completed"];
	
	if (self.quests) [self.quests release];
	self.quests = [NSArray arrayWithObjects:activeQuestsArray, completedQuestsArray, nil];
	[self.quests retain];

	[self constructCells];
	
	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;

}

-(void)constructCells{
	NSLog(@"QuestsVC: Constructing Cells");
	//Iterate through each element in quests and save the cell into questCells
    BOOL activeQuestsEmpty = NO;
    BOOL completedQuestsEmpty = NO;
	NSMutableArray *activeQuestCells = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray *completedQuestCells = [NSMutableArray arrayWithCapacity:10];
	
	NSArray *activeQuests = [self.quests objectAtIndex:ACTIVE_SECTION];
	NSArray *completedQuests = [self.quests objectAtIndex:COMPLETED_SECTION];
	NSEnumerator *e;
	Quest *quest;
	
    NSLog(@"QuestsVC: Active Quests Selected");
    e = [activeQuests objectEnumerator];
    while ( (quest = (Quest*)[e nextObject]) ) {
        [activeQuestCells addObject: [self getCellContentViewForQuest:quest inSection:ACTIVE_SECTION]];
    }
    
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
    
    e = [completedQuests objectEnumerator];
    NSLog(@"QuestsVC: Completed Quests Selected");
    while ( (quest = (Quest*)[e nextObject]) ) {
        [completedQuestCells addObject:[self getCellContentViewForQuest:quest inSection:COMPLETED_SECTION]];
    }
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
    
	self.questCells = [NSArray arrayWithObjects:activeQuestCells,completedQuestCells, nil];
	[self.questCells retain];
	
	//if (activeQuestsEmpty && completedQuestsEmpty) 
    [tableView reloadData];
	
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
		Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId:quest.iconMediaId];
		[iconView loadImageFromMedia:iconMedia];
	}
	else {
        if(!quest.isNullQuest){
            if(activeQuestsSwitch.selectedSegmentIndex == 0) iconView.image = [UIImage imageNamed:@"QuestActiveIcon.png"];
            if(activeQuestsSwitch.selectedSegmentIndex == 1) iconView.image = [UIImage imageNamed:@"QuestCompleteIcon.png"];
        }
		
	}
	[cell.contentView addSubview:iconView];
	[iconView release];
	
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
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
-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Don't do anything just yet
	//We could add a long description area here
}
*/



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

@end

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
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"	}"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";


@implementation QuestsViewController

@synthesize tableView;
@synthesize quests;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Quests";
        self.tabBarItem.image = [UIImage imageNamed:@"quest.png"];
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
		silenceNextServerUpdate = YES;

		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"ReceivedQuestList" object:nil];
		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];

    }
    return self;
}

- (void)silenceNextUpdate {
	silenceNextServerUpdate = YES;
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
	
	NSLog(@"QuestsViewController: Quests View Did Appear");
}

- (void)refresh {
	NSLog(@"QuestsViewController: refresh requested");
	if (appModel.loggedIn) [appModel fetchQuestList];
}

-(void)refreshViewFromModel {
	NSLog(@"QuestsViewController: Refreshing view from model");

	//Add a badge if this is NOT the first time data has been loaded
	if (silenceNextServerUpdate == NO) {
		self.tabBarItem.badgeValue = @"!";
		
		ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate playAudioAlert:@"questChange" shouldVibrate:YES];
				
	}
	else silenceNextServerUpdate = NO;
	
	//rebuild the list
	NSArray *activeQuestsArray = [appModel.questList objectForKey:@"active"];
	NSArray *completedQuestsArray = [appModel.questList objectForKey:@"completed"];
	
	self.quests = [NSArray arrayWithObjects:activeQuestsArray, completedQuestsArray, nil];

	[tableView reloadData];
}


#pragma mark PickerViewDelegate selectors

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	CGRect cellFrame = CGRectMake(0, 0, 300, 60);
	CGRect iconFrame = CGRectMake(5, 5, 50, 50);
	CGRect label1Frame = CGRectMake(70, 10, 230, 25);
	CGRect descriptionFrame = CGRectMake(70, 35, 230, 30);
	UILabel *lblTemp;
	UIWebView *descriptionView;
	AsyncImageView *iconViewTemp;
	
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:cellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
	//Setup Cell
	UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.backgroundView = transparentBackground;
	
	//Initialize Label with tag 1.
	lblTemp = [[UILabel alloc] initWithFrame:label1Frame];
	lblTemp.tag = 1;
	lblTemp.textColor = [UIColor whiteColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Initialize Description with tag 2.
	descriptionView = [[UIWebView alloc] initWithFrame:descriptionFrame];
	descriptionView.tag = 2;
	[descriptionView setBackgroundColor:[UIColor clearColor]];
//	lblTemp.font = [UIFont boldSystemFontOfSize:12];
//	lblTemp.textColor = [UIColor lightGrayColor];
//	lblTemp.backgroundColor = [UIColor clearColor];
//	lblTemp.numberOfLines = 2;
	[cell.contentView addSubview:descriptionView];
	[descriptionView release];
	
	//Init Icon with tag 3
	iconViewTemp = [[AsyncImageView alloc] initWithFrame:iconFrame];
	iconViewTemp.tag = 3;
	iconViewTemp.backgroundColor = [UIColor blackColor];
	[cell.contentView addSubview:iconViewTemp];
	[iconViewTemp release];
	[cell sizeToFit];
	return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [quests count];
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *array = [quests objectAtIndex:section];
	return [array count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	//Get the cell definition
	UITableViewCell *cell = [nibTableView dequeueReusableCellWithIdentifier:OPTION_CELL];	
	if(cell == nil) cell = [self getCellContentView:OPTION_CELL];
	
	//Get the quest object
	int section = indexPath.section;
	int indexWithinSection = indexPath.row;
	
	NSArray *array = [quests objectAtIndex:section];	
	Quest *quest = (Quest*)[array objectAtIndex:indexWithinSection];
	
	//Get the reference to the cell's properties
	UILabel *cellName = (UILabel *)[cell viewWithTag:1];
	UIWebView *cellDescription = (UIWebView *)[cell viewWithTag:2];
	AsyncImageView *cellIconView = (AsyncImageView *)[cell viewWithTag:3];

	//Set the name and description, those are easy
	cellName.text = quest.name;
	NSString *htmlDescription = [NSString stringWithFormat:kQuestsHtmlTemplate, quest.description];
	NSLog(@"cellForRowAtIndex setting description to %@", htmlDescription);
	[cellDescription loadHTMLString:htmlDescription baseURL:nil];
	while (cellDescription.loading) {
		NSLog(@"Loading...");
	}
	CGRect descriptionFrame = [cellDescription frame];
	NSLog(@"Description Frame is {%f, %f, %f, %f}", 
		  descriptionFrame.origin.x, 
		  descriptionFrame.origin.y, 
		  descriptionFrame.size.width,
		  descriptionFrame.size.height);
	NSString *newHeight = [cellDescription stringByEvaluatingJavaScriptFromString:@"document.body.clientHeight;"];
	NSLog(@"New height should be %@", newHeight);
	descriptionFrame.size = [cellDescription sizeThatFits:CGSizeMake(descriptionFrame.size.width,[[cellDescription stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight + document.body.offsetTop;"] floatValue])];
	NSLog(@"New Description Frame should be {%f, %f, %f, %f}", 
		  descriptionFrame.origin.x, 
		  descriptionFrame.origin.y, 
		  descriptionFrame.size.width,
		  descriptionFrame.size.height);
	[cellDescription setFrame:descriptionFrame];
	
	//Set the icon
	if (quest.iconMediaId > 0) {
		Media *iconMedia = [appModel.mediaList objectForKey:[NSNumber numberWithInt:quest.iconMediaId]];
		[cellIconView loadImageFromMedia:iconMedia];
	}
	else {
		if (section == ACTIVE_SECTION) cellIconView.image = [UIImage imageNamed:@"QuestActiveIcon.png"];
		if (section == COMPLETED_SECTION) cellIconView.image = [UIImage imageNamed:@"QuestCompleteIcon.png"];

	}
	[cell sizeToFit];
	return cell;
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self tableView:aTableView cellForRowAtIndexPath:indexPath];
	return cell.frame.size.height ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Don't do anything just yet
	//We should add a long description area here
}

- (NSString *)tableView:(UITableView *)view titleForHeaderInSection:(NSInteger)section {
	if (section == ACTIVE_SECTION) return @"Active Quests";	
	else if (section == COMPLETED_SECTION) return @"Completed Quests";
	return @"Quests";
}






















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[appModel release];
    [super dealloc];
}

@end

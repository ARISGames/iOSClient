//
//  GamePickerViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GamePickerViewController.h"
#import "AppServices.h"
#import "Game.h"
#import "ARISAppDelegate.h"
#import "GameDetails.h"
#import "GamePickerCell.h"

@implementation GamePickerViewController

@synthesize gameTable;
@synthesize gameList;
@synthesize filteredGameList;
@synthesize refreshButton;
@synthesize locationalControl, distanceControl;


//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"GamePickerTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"game.png"];
		self.filteredGameList = [[NSMutableArray alloc]initWithCapacity:1];
		
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewGameListReady" object:nil];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"RecievedGameList" object:nil];
		
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
	NSLog(@"GamePickerViewController: View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"GamePickerViewController: View Appeared");	
	
	self.gameList = [NSMutableArray arrayWithCapacity:1];

	[gameTable reloadData];
	[self refresh];
		
	NSLog(@"GamePickerViewController: view did appear");

}


-(void)refresh {
	NSLog(@"GamePickerViewController: Refresh Requested");
	[[AppServices sharedAppServices] fetchGameListWithDistanceFilter:10000.0];
	[self showLoadingIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark custom methods, logic
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
	[[self navigationItem] setRightBarButtonItem:self.refreshButton];
}

- (void)refreshViewFromModel {
	NSLog(@"GamePickerViewController: Refresh View from Model");
	
	//Sort the game list
	NSArray* sortedGameList = [[AppModel sharedAppModel].gameList sortedArrayUsingSelector:@selector(compareDistanceFromPlayer:)];

	self.gameList = sortedGameList;

	[gameTable reloadData];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.searchDisplayController.searchResultsTableView)
		return [self.filteredGameList count];
	else return [self.gameList count];

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"GamePickerVC: Cell requested for section: %d row: %d",indexPath.section,indexPath.row);

	
	static NSString *CellIdentifier = @"Cell";
    GamePickerCell *cell = (GamePickerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		// Create a temporary UIViewController to instantiate the custom cell.
		UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"GamePickerCell" bundle:nil];
		// Grab a pointer to the custom cell.
		cell = (GamePickerCell *)temporaryController.view;
		// Release the temporary UIViewController.
		[temporaryController release];
    }
	
	Game *currentGame;
	if (tableView == self.searchDisplayController.searchResultsTableView) 
		currentGame = [self.filteredGameList objectAtIndex:indexPath.row];
	else currentGame = [self.gameList objectAtIndex:indexPath.row];

	cell.titleLabel.text = currentGame.name;
	double dist = currentGame.distanceFromPlayer;
	cell.distanceLabel.text = [NSString stringWithFormat:@"%1.1f %@",  dist/1000, NSLocalizedString(@"KilometersKey", @"") ];
	cell.authorLabel.text = currentGame.authors;
	cell.progressView.progress = (float)currentGame.completedQuests / (float)currentGame.totalQuests;
    cell.percentCompleteLabel.text = NSLocalizedString(@"PercentCompleteKey", @"");

	
	if ([currentGame.iconMediaUrl length] > 0) {
		Media *iconMedia = [[Media alloc] initWithId:1 andUrlString:currentGame.iconMediaUrl ofType:@"Icon"];
		[cell.iconView loadImageFromMedia:iconMedia];
	}
	else cell.iconView.image = [UIImage imageNamed:@"Icon.png"];

	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //do select game notification;
	Game *selectedGame;
	if (tableView == self.searchDisplayController.searchResultsTableView)
		selectedGame = [self.filteredGameList objectAtIndex:indexPath.row];
	else selectedGame = [self.gameList objectAtIndex:indexPath.row];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:selectedGame forKey:@"game"];
	
	[[AppServices sharedAppServices] silenceNextServerUpdate];
	NSNotification *gameSelectNotification = [NSNotification notificationWithName:@"SelectGame" object:self userInfo:dictionary];
	[[NSNotificationCenter defaultCenter] postNotification:gameSelectNotification];
	
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	Game *selectedGame;
	selectedGame = [self.gameList objectAtIndex:indexPath.row];
	
	GameDetails *gameDetailsVC = [[GameDetails alloc]initWithNibName:@"GameDetails" bundle:nil];
	gameDetailsVC.game = selectedGame;
	[self.navigationController pushViewController:gameDetailsVC animated:YES];
	[gameDetailsVC release];	
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText{
	[self.filteredGameList removeAllObjects]; // First clear the filtered array.
	
	for (Game *g in self.gameList) {
		if ([[g.name lowercaseString] rangeOfString:[searchText lowercaseString]].location != NSNotFound) [self.filteredGameList addObject:g];
		else if ([[g.authors lowercaseString] rangeOfString:[searchText lowercaseString]].location != NSNotFound) [self.filteredGameList addObject:g]; 
		else if ([[g.description lowercaseString] rangeOfString:[searchText lowercaseString]].location != NSNotFound) [self.filteredGameList addObject:g]; 
	}
	NSLog(@"filting Complete");
}




#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


- (void)dealloc {
	[gameList release];
    [refreshButton release];
    [super dealloc];
}


@end

//
//  GamePickerRecentViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "GamePickerSearchViewController.h"
#import "AppServices.h"
#import "Game.h"
#import "ARISAppDelegate.h"
#import "GameDetails.h"
#import "GamePickerCell.h"
#include <QuartzCore/QuartzCore.h>

@implementation GamePickerSearchViewController

@synthesize gameTable;
@synthesize gameList;
@synthesize refreshButton,theSearchBar;
@synthesize disableViewOverlay,searchText;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Search";
		self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [gameList release];
    [refreshButton release];
    [super dealloc];
}



#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    [self refresh];
     [self.theSearchBar becomeFirstResponder]; //Bring up the keyboard right away
	NSLog(@"SearchVC: View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"SearchVC: View Appeared");	
    
    //Clear the List
    //self.gameList = [NSArray array];
    [gameTable reloadData];

   
        
    [super viewDidAppear:animated];
}


-(void)refresh {
	NSLog(@"SearchVC: Refresh Requested");
    
    //register for notifications
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"RecievedGameList" object:nil];
    [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewGameListReady" object:nil];
    [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost" object:nil];

    
    [[AppServices sharedAppServices] fetchGameListBySearch: [self.searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"URL encoded search string: %@", [self.searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]);
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
	NSLog(@"SearchVC: Refresh View from Model");
	
    //unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
       
	self.gameList = [AppModel sharedAppModel].gameList;
    
	[gameTable reloadData];
}


#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.gameList count];
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
        cell.starView.backgroundColor = [UIColor clearColor];
        
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-halfselected.png"]
                           forState:kSCRatingViewHalfSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]
                           forState:kSCRatingViewHighlighted];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]
                           forState:kSCRatingViewHot];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]
                           forState:kSCRatingViewNonSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]
                           forState:kSCRatingViewSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]
                           forState:kSCRatingViewUserSelected];
        
        

		[temporaryController release];
    }
	
	Game *currentGame = [self.gameList objectAtIndex:indexPath.row];
    
	cell.titleLabel.text = currentGame.name;
	double dist = currentGame.distanceFromPlayer;
	cell.distanceLabel.text = [NSString stringWithFormat:@"%1.1f %@",  dist/1000, NSLocalizedString(@"km", @"") ];
	cell.authorLabel.text = currentGame.authors;
	cell.numReviewsLabel.text = [NSString stringWithFormat:@"%@%@", [[NSNumber numberWithInt:currentGame.numReviews] stringValue], @" reviews"];
    cell.starView.rating = currentGame.rating;
        //Set up the Icon
    //Create a new iconView for each cell instead of reusing the same one
    AsyncMediaImageView *iconView = [[AsyncMediaImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    
    if(currentGame.iconMedia.image){
        iconView.image = [UIImage imageWithData: currentGame.iconMedia.image];
    }
    else {
        if(!currentGame.iconMedia) iconView.image = [UIImage imageNamed:@"Icon.png"];
        else{
            [iconView loadImageFromMedia:currentGame.iconMedia];
        }
    }
    
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 10.0;
    
    //clear out icon view
    if([cell.iconView.subviews count]>0)
        [[cell.iconView.subviews objectAtIndex:0] removeFromSuperview];
    
    
    [cell.iconView addSubview: iconView];
    
    [iconView release];    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Color the backgrounds
    if (indexPath.row % 2 == 0){  
        cell.backgroundColor = [UIColor colorWithRed:233.0/255.0  
                                               green:233.0/255.0  
                                                blue:233.0/255.0  
                                               alpha:1.0];  
    } else {  
        cell.backgroundColor = [UIColor colorWithRed:200.0/255.0  
                                               green:200.0/255.0  
                                                blue:200.0/255.0  
                                               alpha:1.0];  
    } 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //do select game notification;
    Game *selectedGame;
	selectedGame = [self.gameList objectAtIndex:indexPath.row];
	
	GameDetails *gameDetailsVC = [[GameDetails alloc]initWithNibName:@"GameDetails" bundle:nil];
	gameDetailsVC.game = selectedGame;
	[self.navigationController pushViewController:gameDetailsVC animated:YES];
	[gameDetailsVC release];	
    
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



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    [self searchBar:searchBar activate:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Clear the search text
    // Deactivate the UISearchBar
    searchBar.text=@"";
    [self searchBar:searchBar activate:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
	
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    self.searchText = searchBar.text;
	
    [self searchBar:searchBar activate:NO];
	[self refresh];
    }

// We call this when we want to activate/deactivate the UISearchBar
// Depending on active (YES/NO) we disable/enable selection and 
// scrolling on the UITableView
// Show/Hide the UISearchBar Cancel button
// Fade the screen In/Out with the disableViewOverlay and 
// simple Animations
- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active{	
    self.gameTable.allowsSelection = !active;
    self.gameTable.scrollEnabled = !active;
    if (!active) {
        [disableViewOverlay removeFromSuperview];
        [searchBar resignFirstResponder];
    } else {
        self.disableViewOverlay.alpha = 0;
        [self.view addSubview:self.disableViewOverlay];
		
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        self.disableViewOverlay.alpha = 0.6;
        [UIView commitAnimations];
		
        // probably not needed if you have a details view since you 
        // will go there on selection
        NSIndexPath *selected = [self.gameTable 
                                 indexPathForSelectedRow];
        if (selected) {
            [self.gameTable deselectRowAtIndexPath:selected 
                                             animated:NO];
        }
    }
    [searchBar setShowsCancelButton:active animated:YES];
}




@end

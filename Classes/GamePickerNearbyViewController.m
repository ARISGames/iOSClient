//
//  GamePickerNearbyViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GamePickerNearbyViewController.h"
#import "AppServices.h"
#import "Game.h"
#import "ARISAppDelegate.h"
#import "GameDetails.h"
#import "GamePickerCell.h"
#include <QuartzCore/QuartzCore.h>

@implementation GamePickerNearbyViewController

@synthesize gameTable;
@synthesize gameList;
@synthesize refreshButton,count;


//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Nearby";
<<<<<<< .mine
        self.tabBarItem.image = [UIImage imageNamed:@"game.png"];
		self.count = 0;
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewGameListReady" object:nil];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"RecievedGameList" object:nil];
		
=======
        self.tabBarItem.image = [UIImage imageNamed:@"game.png"];		
>>>>>>> .r1772
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
	
	//self.gameList = [NSMutableArray arrayWithCapacity:1];
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[gameTable reloadData];
	[self refresh];
    if(self.count == 0){
    
        appDelegate.tabBarController.tabBar.hidden = YES;
        appDelegate.gameSelectionTabBarController.view.hidden = NO;
        appDelegate.gameSelectionTabBarController.tabBar.hidden = NO;
        self.count++;
    }
    else {count--;
        appDelegate.tabBarController.view.hidden = NO;
        appDelegate.tabBarController.tabBar.hidden = NO;
        appDelegate.gameSelectionTabBarController.tabBar.hidden = YES;}
	NSLog(@"GamePickerViewController: view did appear");

}


-(void)refresh {
	NSLog(@"GamePickerViewController: Refresh Requested");
        //Calculate locational control value
    BOOL locational;
    if (locationalControl.selectedSegmentIndex == 0) {
     locational = YES;  
        distanceControl.enabled = YES;
        distanceControl.alpha = 1;
    }
    else
    {
      locational = NO;
        distanceControl.alpha = .2;
        distanceControl.enabled = NO;
    }
	
    //Calculate distance filer controll value
    int distanceFilter;
    switch (distanceControl.selectedSegmentIndex) {
        case 0:
            distanceFilter = 100;
            break;
        case 1:
            distanceFilter = 1000;
            break;
        case 2:
            distanceFilter = 50000;
            break;
    
    }
    
    //register for notifications
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewGameListReady" object:nil];
    [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"RecievedGameList" object:nil];
    
    [[AppServices sharedAppServices] fetchGameListWithDistanceFilter:distanceFilter locational:locational];
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
-(void) viewWillAppear:(BOOL)animated{
    

    
    
}
-(void)removeLoadingIndicator{
	[[self navigationItem] setRightBarButtonItem:self.refreshButton];
}

- (void)refreshViewFromModel {
	NSLog(@"GamePickerViewController: Refresh View from Model");

    //unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	//Sort the game list
	NSArray* sortedGameList = [[AppModel sharedAppModel].gameList sortedArrayUsingSelector:@selector(compareCalculatedScore:)];
	self.gameList = sortedGameList;

	[gameTable reloadData];
}

#pragma mark Control Callbacks
-(IBAction)controlChanged:(id)sender{
        
    if (sender == locationalControl || 
        locationalControl.selectedSegmentIndex == 0) 
    [self refresh];

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
		[temporaryController release];
    }
	
	Game *currentGame = [self.gameList objectAtIndex:indexPath.row];

	cell.titleLabel.text = currentGame.name;
	double dist = currentGame.distanceFromPlayer;
	cell.distanceLabel.text = [NSString stringWithFormat:@"%1.1f %@",  dist/1000, NSLocalizedString(@"km", @"") ];
	cell.authorLabel.text = currentGame.authors;
	cell.numReviewsLabel.text = [NSString stringWithFormat:@"%@%@", [[NSNumber numberWithInt:currentGame.numReviews] stringValue], @" reviews"];
    cell.starView.rating = currentGame.rating;
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
    
    //Set up the Icon
	if ([currentGame.iconMediaUrl length] > 0) {
		Media *iconMedia = [[Media alloc] initWithId:1 andUrlString:currentGame.iconMediaUrl ofType:@"Icon"];
		[cell.iconView loadImageFromMedia:iconMedia];
	}
	else cell.iconView.image = [UIImage imageNamed:@"Icon.png"];
    cell.iconView.layer.masksToBounds = YES;
    cell.iconView.layer.cornerRadius = 10.0;
    
    return cell;
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

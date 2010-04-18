//
//  GamePickerViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GamePickerViewController.h"
#import "model/Game.h"
#import "ARISAppDelegate.h"

@implementation GamePickerViewController

@synthesize gameTable;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Select Game";
        self.tabBarItem.image = [UIImage imageNamed:@"game.png"];
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
		
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"ReceivedGameList" object:nil];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"PlayerMoved" object:nil];
		
		//create game lists
		nearGameList = [NSMutableArray array];
		[nearGameList retain];
		
		farGameList = [NSMutableArray array];
		[farGameList retain];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"GamePickerViewController: View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"GamePickerViewController: View Appeared, reloading data");	
	[appModel fetchGameList];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark custom methods, logic

- (void)refreshViewFromModel {
	NSLog(@"GamePickerViewController: Refresh View from Model");
	
	//Sort the game list
	NSArray* sortedGameList = [appModel.gameList sortedArrayUsingSelector:@selector(compareDistanceFromPlayer:)];
	NSMutableArray* nearArray = [[NSMutableArray alloc] initWithCapacity:10];
	NSMutableArray* farArray = [[NSMutableArray alloc] initWithCapacity:10];
	
	//Divide into two arrays
	double maxDistanceForNearby = 10000; //in Meters

	for (int i=0; i<[sortedGameList count]; i++) {
		if ([[sortedGameList objectAtIndex:i] distanceFromPlayer] <= maxDistanceForNearby)  
			[nearArray addObject:[sortedGameList objectAtIndex:i]];
		else [farArray addObject:[sortedGameList objectAtIndex:i]];

	}

	if (nearGameList) [nearGameList release];
	nearGameList = nearArray;
	[nearGameList retain];
	
	if (farGameList) [farGameList release];
	farGameList = farArray;
	[farGameList retain];

	[gameTable reloadData];
}

- (void)slideIn {	
	[UIView beginAnimations:nil context:nil];
	self.view.frame = CGRectMake(0.0f, 64.0f, 320.0f, 416.0f);
	[UIView commitAnimations];
}

- (void)slideOut {	
	[UIView beginAnimations:nil context:nil];
	self.view.frame = CGRectMake(0.0f, 485.0f, 320.0f, 416.0f);
	[UIView commitAnimations];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section = 0) return [nearGameList count];
	else return [farGameList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	Game *currentGame;
	if (indexPath.section == 0) currentGame = [nearGameList objectAtIndex:indexPath.row];
	else currentGame = [farGameList objectAtIndex:indexPath.row];

	cell.textLabel.text = currentGame.name;
	double dist = currentGame.distanceFromPlayer;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.1f Kilometers",  dist/1000];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //do select game notification;
	Game *selectedGame;
	if (indexPath.section == 0) selectedGame = [nearGameList objectAtIndex:indexPath.row];
	else selectedGame = [farGameList objectAtIndex:indexPath.row];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:selectedGame forKey:@"game"];
	
	NSNotification *loginNotification = [NSNotification notificationWithName:@"SelectGame" object:self userInfo:dictionary];
	[[NSNotificationCenter defaultCenter] postNotification:loginNotification];
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

- (NSString *)tableView:(UITableView *)view titleForHeaderInSection:(NSInteger)section {
	if (section == 0) return @"Nearby Games";	
	else if (section == 1) return @"Other Games";
	return @"Quests";
}


- (void)dealloc {
	[nearGameList release];
	[farGameList release];

    [super dealloc];
}


@end

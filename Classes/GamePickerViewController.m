//
//  GamePickerViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GamePickerViewController.h"
#import "model/Game.h"

@implementation GamePickerViewController

@synthesize gameTable;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"GamePickerViewController: View Loaded");
	
	//create game list
	gameList = [NSMutableArray array];
	[gameList retain];
		
}

- (void)viewDidAppear:(BOOL)animated {
	[gameTable reloadData];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark custom methods, logic

- (void)setGameList:(NSMutableArray *)list {
	NSLog(@"GamePickerViewController: Game List Set");
	[gameList release];
	gameList = list;
	[gameList retain];
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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [gameList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.text = [[gameList objectAtIndex:[indexPath row]] name];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //do select game notification;
	Game *selectedGame = [gameList objectAtIndex:[indexPath row]];
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


- (void)dealloc {
	[gameList release];
    [super dealloc];
}


@end

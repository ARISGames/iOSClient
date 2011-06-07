//
//  MyClass.m
//  ARIS
//
//  Created by Brian Thiel on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameDetails.h"
#import "AppServices.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "commentsViewController.h"
#import "CommentsFormCell.h"

@implementation commentsViewController
@synthesize tableView;
@synthesize game;


//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    NSLog(@"commentsViewController Initialized");
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Comments";
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
   	NSLog(@"commentsPickerViewController: View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"commentsViewController: View Appeared");	
	[tableView reloadData];
	NSLog(@"commentsViewController: view did appear");
    
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
	
}

- (void)refreshViewFromModel {
	[tableView reloadData];
}



#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [game.comments count] + 1;

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"GamePickerVC: Cell requested for section: %d row: %d",indexPath.section,indexPath.row);
    
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		// Create a temporary UIViewController to instantiate the custom cell.
		UITableViewCell *tempCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                                            reuseIdentifier:CellIdentifier] autorelease];
        cell = tempCell;
    }
    cell.textLabel.backgroundColor = [UIColor clearColor]; 
    cell.detailTextLabel.backgroundColor = [UIColor clearColor]; 
    
    if (indexPath.row % 2 == 0){  
        cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0  
                                                           green:233.0/255.0  
                                                            blue:233.0/255.0  
                                                           alpha:1.0];  
    } else {  
        cell.contentView.backgroundColor = [UIColor colorWithRed:200.0/255.0  
                                                           green:200.0/255.0  
                                                            blue:200.0/255.0  
                                                           alpha:1.0];  
    } 
	
    if (indexPath.row == 0) {
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"CommentsFormCell" bundle:nil];
		// Grab a pointer to the custom cell
		cell = (CommentsFormCell *)temporaryController.view;
		// Release the temporary UIViewController.
		[temporaryController release];
        
        CommentsFormCell *commentsFormCell = (CommentsFormCell *)cell;
                
        [commentsFormCell.ratingView setStarImage:[UIImage imageNamed:@"star-halfselected.png"]
                                   forState:kSCRatingViewHalfSelected];
        [commentsFormCell.ratingView setStarImage:[UIImage imageNamed:@"star-highlighted.png"]
                                   forState:kSCRatingViewHighlighted];
        [commentsFormCell.ratingView setStarImage:[UIImage imageNamed:@"star-hot.png"]
                                   forState:kSCRatingViewHot];
        [commentsFormCell.ratingView setStarImage:[UIImage imageNamed:@"star-highlighted.png"]
                                   forState:kSCRatingViewNonSelected];
        [commentsFormCell.ratingView setStarImage:[UIImage imageNamed:@"star-selected.png"]
                                   forState:kSCRatingViewSelected];
        [commentsFormCell.ratingView setStarImage:[UIImage imageNamed:@"star-hot.png"]
                                   forState:kSCRatingViewUserSelected];
    }
    else {
        cell.textLabel.text = ((Comment *)[game.comments objectAtIndex:indexPath.row-1]).text;
        cell.detailTextLabel.text = @"Desc"; //Make this the author
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) return 160;
    else return 60;
}




- (void)dealloc {
    [super dealloc];
}

@end

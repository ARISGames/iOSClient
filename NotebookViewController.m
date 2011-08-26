//
//  NotebookViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotebookViewController.h"
#import "NoteViewController.h"
#import "AppServices.h"
#import "Note.h"
#import "ARISAppDelegate.h"

@implementation NotebookViewController
@synthesize noteList,noteTable;
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Notebook";
        self.tabBarItem.image = [UIImage imageNamed:@"notebook2.png"]; 
        self.noteList = [[NSMutableArray alloc] initWithCapacity:10];
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(refresh) name:@"NoteDeleted" object:nil];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	

  	[noteTable reloadData];
    
    [self refresh];
    
	NSLog(@"NotebookViewController: View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"NotebookViewController: View Appeared");	
	
    
	[self refresh];
    
	NSLog(@"NotebookViewController: view did appear");
    
}


-(void)refresh {
	NSLog(@"NotebookViewController: Refresh Requested");
    
        //register for notifications
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNoteListReady" object:nil];
        [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"RecievedNoteList" object:nil];
        
    [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:NO];
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
    [[self navigationItem] setRightBarButtonItem:nil];
    [noteTable reloadData];
}

- (void)refreshViewFromModel {
	NSLog(@"NotebookViewController: Refresh View from Model");
    
        
	self.noteList = [AppModel sharedAppModel].playerNoteList;
    [noteTable reloadData];
    //unregister for notifications
                     [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.noteList count] == 0) return 2;
	return [self.noteList count]+1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"GamePickerVC: Cell requested for section: %d row: %d",indexPath.section,indexPath.row);
    
	static NSString *CellIdentifier = @"Cell";
UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    if([self.noteList count] == 0 && indexPath.row == 0){
        cell.textLabel.text = @"No Notes";
        cell.detailTextLabel.text = @"Press Button Below To Add One!";
        cell.userInteractionEnabled = NO;
    }
    else{
        if(indexPath.row == [self.noteList count] || (indexPath.row == 1 && [self.noteList count]==0)){
            cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"plusCellButton.png"]];}
        else
        cell.textLabel.text = [(Note *)[self.noteList objectAtIndex:indexPath.row] title];
    }
    
   
       
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
    if([indexPath row] < [self.noteList count]){
    NoteViewController *noteVC = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil];
    noteVC.note = [self.noteList objectAtIndex:indexPath.row];
    noteVC.delegate = self;
    [self.navigationController pushViewController:noteVC animated:YES];
    [noteVC release];
    }
    else{
        NoteViewController *noteVC = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil];
        noteVC.delegate = self;
        [self.navigationController pushViewController:noteVC animated:YES];
        [noteVC release];
    }

}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.noteList count] == 0 ||(indexPath.row == [self.noteList count])) return UITableViewCellEditingStyleNone;

    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[AppServices sharedAppServices]deleteNoteWithNoteId:[(Note *)[self.noteList objectAtIndex:indexPath.row] noteId]];
    [self.noteList removeObjectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView 

didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [noteTable reloadData];
    
}




- (void)dealloc {    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [noteList release];
    [super dealloc];
}
@end

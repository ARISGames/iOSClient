//
//  NotebookViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotebookViewController.h"
#import "NoteViewController.h"
#import "DataCollectionViewController.h"
#import "AppServices.h"
#import "NoteCell.h"
#import "Note.h"
#import "ARISAppDelegate.h"

@implementation NotebookViewController
@synthesize noteList,noteTable, noteControl,gameNoteList,textIconUsed,videoIconUsed,photoIconUsed,audioIconUsed;
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Notebook";
        self.tabBarItem.image = [UIImage imageNamed:@"notebook2.png"]; 
        self.noteList = [[NSMutableArray alloc] initWithCapacity:10];
        self.gameNoteList = [[NSMutableArray alloc] initWithCapacity:10];

        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(refresh) name:@"NoteDeleted" object:nil];
        [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNoteListReady" object:nil];
        [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"RecievedNoteList" object:nil];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)];
    self.navigationItem.rightBarButtonItem = barButton;

  	[noteTable reloadData];
    
    
	NSLog(@"NotebookViewController: View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"NotebookViewController: View Appeared");	
	
    
	[self refresh];
    
	NSLog(@"NotebookViewController: view did appear");
    
}


-(void)refresh {
	NSLog(@"NotebookViewController: Refresh Requested");
            
        if(self.noteControl.selectedSegmentIndex == 0)
    [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];
    else
        [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];

    //[self showLoadingIndicator];
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
    //[[self navigationItem] setRightBarButtonItem:nil];

    [noteTable reloadData];
}
-(void)addNote{
    NoteViewController *noteVC = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil];
    noteVC.delegate = self;
    [self.navigationController pushViewController:noteVC animated:YES];
    [noteVC release];
    }
- (void)refreshViewFromModel {
	NSLog(@"NotebookViewController: Refresh View from Model");
    NSMutableArray *nList = [[NSMutableArray alloc] initWithCapacity:10];
        
	self.noteList = [AppModel sharedAppModel].playerNoteList;
    for(int x = 0; x < [[AppModel sharedAppModel].gameNoteList count]; x ++){
        if([(Note *)[[AppModel sharedAppModel].gameNoteList objectAtIndex:x] shared]){
            [nList addObject:[[AppModel sharedAppModel].gameNoteList objectAtIndex:x]];
        }
    }
    self.gameNoteList = nList;
    [nList release];

    [noteTable reloadData];
    //unregister for notifications
                   //  [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

     if(self.noteControl.selectedSegmentIndex == 0){ 
        if([self.noteList count] == 0) return 1;
        return [self.noteList count];}
    else {
        if([self.gameNoteList count] == 0) return 1;
        return [self.gameNoteList count];
    }

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.videoIconUsed = NO;
    self.photoIconUsed = NO;
    self.audioIconUsed = NO;
    self.textIconUsed = NO;
    NSMutableArray *currentNoteList;
    if(self.noteControl.selectedSegmentIndex == 0) currentNoteList = self.noteList;
    else currentNoteList = self.gameNoteList;
	static NSString *CellIdentifier = @"Cell";
    if([currentNoteList count] == 0 && indexPath.row == 0){
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

        cell.textLabel.text = @"No Notes";
        cell.detailTextLabel.text = @"Press Plus Button Above To Add One!";
        cell.userInteractionEnabled = NO;
        return cell;
    }
   
    UITableViewCell *tempCell = (NoteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (![tempCell respondsToSelector:@selector(mediaIcon1)]){
        //[tempCell release];
        tempCell = nil;
    }
    NoteCell *cell = (NoteCell *)tempCell;
   
           
            if (cell == nil) {
                // Create a temporary UIViewController to instantiate the custom cell.
                UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"NoteCell" bundle:nil];
                // Grab a pointer to the custom cell.
                cell = (NoteCell *)temporaryController.view;
                // Release the temporary UIViewController.
                [temporaryController release];
            }
    
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
    
            Note *currNote = (Note *)[currentNoteList objectAtIndex:indexPath.row];
    
    
        cell.titleLabel.text = currNote.title;
    cell.starView.rating = currNote.averageRating;
        if([currNote.contents count] == 0 && (currNote.creatorId != [AppModel sharedAppModel].playerId))cell.userInteractionEnabled = NO;
            for(int x = 0; x < [currNote.contents count];x++){
                if([[[currNote.contents objectAtIndex:x] type] isEqualToString:@"TEXT"]&& !self.textIconUsed){
                    self.textIconUsed = YES;
                    if (cell.mediaIcon1.image == nil) {
                        cell.mediaIcon1.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 

                    }
                    else if(cell.mediaIcon2.image == nil) {
                        cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon3.image == nil) {
                        cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon4.image == nil) {
                        cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
                        
                    }


                }
                else if ([[[currNote.contents objectAtIndex:x] type] isEqualToString:@"PHOTO"]&& !self.photoIconUsed){
                    self.photoIconUsed = YES;
                    if (cell.mediaIcon1.image == nil) {
                        cell.mediaIcon1.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon2.image == nil) {
                        cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon3.image == nil) {
                        cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon4.image == nil) {
                        cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
                        
                    }

                }
                else if([[[currNote.contents objectAtIndex:x] type] isEqualToString:@"AUDIO"] && !self.audioIconUsed){
                    self.audioIconUsed = YES;
                    if (cell.mediaIcon1.image == nil) {
                        cell.mediaIcon1.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon2.image == nil) {
                        cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon3.image == nil) {
                        cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon4.image == nil) {
                        cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
                        
                    }

                }
                else if([[[currNote.contents objectAtIndex:x] type] isEqualToString:@"VIDEO"] && !self.videoIconUsed){
                    self.videoIconUsed = YES;
                    if (cell.mediaIcon1.image == nil) {
                        cell.mediaIcon1.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon2.image == nil) {
                        cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon3.image == nil) {
                        cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
                        
                    }
                    else if(cell.mediaIcon4.image == nil) {
                        cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
                        
                    }

                }
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
    NSMutableArray *currentNoteList;
    if(self.noteControl.selectedSegmentIndex == 0) currentNoteList = self.noteList;
    else currentNoteList = self.gameNoteList;
 

    if([(Note *)[currentNoteList objectAtIndex:indexPath.row] creatorId] == [AppModel sharedAppModel].playerId){
  
    NoteViewController *noteVC = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil];
    noteVC.note = [currentNoteList objectAtIndex:indexPath.row];
    noteVC.delegate = self;
    [self.navigationController pushViewController:noteVC animated:YES];
    //[noteVC release];
    
    
    
    }
    else{
            //open up note viewer
        DataCollectionViewController *dataVC = [[[DataCollectionViewController alloc] initWithNibName:@"DataCollectionViewController" bundle:nil]autorelease];
        dataVC.note = (Note *)[currentNoteList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:dataVC animated:YES];
        //[dataVC release];
        }
    
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.noteList count] == 0 ||self.noteControl.selectedSegmentIndex==1) return UITableViewCellEditingStyleNone;

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

-(void)controlChanged:(id)sender{
    if (self.noteControl.selectedSegmentIndex ==0){
        [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];

    }
    else {
        [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];

    }
}


- (void)dealloc {    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [noteList release];
    [gameNoteList release];
    [noteTable release];
    [noteControl release];
    [super dealloc];
}
@end

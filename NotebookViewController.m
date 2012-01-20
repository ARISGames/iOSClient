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
BOOL menuDown;
int filSelected;
int sortSelected;
BOOL tagFilter;
@implementation NotebookViewController
@synthesize noteList,noteTable, noteControl,gameNoteList,textIconUsed,videoIconUsed,photoIconUsed,audioIconUsed,menuView,sharedButton,mineButton,popularButton,tagButton,mineLbl,sharedLbl,popularLbl,tagLbl,dateLbl,dateButton,abcLbl,abcButton,toolBar,textButton,photoButton,audioButton,isGameList,tagList,tagNoteList,tagGameNoteList,headerTitleList,headerTitleGameList;
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Notebook";
        self.tabBarItem.image = [UIImage imageNamed:@"notebook2.png"]; 
        self.noteList = [[NSMutableArray alloc] initWithCapacity:10];
        self.gameNoteList = [[NSMutableArray alloc] initWithCapacity:10];
        self.tagList = [[NSMutableArray alloc] initWithCapacity:10];
        self.tagNoteList = [[NSMutableArray alloc] initWithCapacity:10];
        self.tagGameNoteList = [[NSMutableArray alloc] initWithCapacity:10];
        self.headerTitleList = [[NSMutableArray alloc] initWithCapacity:10];
        self.headerTitleGameList = [[NSMutableArray alloc] initWithCapacity:10];



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
	
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(displayMenu)];
    self.navigationItem.rightBarButtonItem = barButton;
    [self.menuView setFrame:CGRectMake(0, -80, 320, 80)];
    [self.toolBar setFrame:CGRectMake(0, 0, 320, 44)];

    [self.noteTable setFrame:CGRectMake(0, 44, 320, 324)];
    self.mineButton.selected = YES;
    self.mineLbl.textColor = [UIColor lightGrayColor];
    self.dateButton.selected = YES;
    self.dateLbl.textColor = [UIColor lightGrayColor];

  	//[noteTable reloadData];
    filSelected = 0;
    sortSelected = 0;
    [self refresh];

	NSLog(@"NotebookViewController: View Loaded");
}
-(void)displayMenu{
    menuDown = !menuDown;
    if(menuDown){
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.5];
    [self.menuView setFrame:CGRectMake(0, 0, 320, 80)];
        [self.toolBar setFrame:CGRectMake(0, 80, 320, 44)];
        [self.noteTable setFrame:CGRectMake(0, 124, 320, 244)];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
    [UIView commitAnimations];
    }
    else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.5];
        [self.menuView setFrame:CGRectMake(0, -80, 320, 80)];
        [self.toolBar setFrame:CGRectMake(0, 0, 320, 44)];
        [self.noteTable setFrame:CGRectMake(0, 44, 320, 324)];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];

        [UIView commitAnimations];        
    }
}
-(void)filterButtonTouchAction:(id)sender{
    
    switch ([sender tag]) {
        case 0:
            mineButton.selected = YES;
            mineLbl.textColor = [UIColor lightGrayColor];
            sharedButton.selected = NO;
            sharedLbl.textColor = [UIColor blackColor];
            //[[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];
            break;
        case 1:
            sharedButton.selected = YES;
            sharedLbl.textColor = [UIColor lightGrayColor];
            mineButton.selected = NO;
            mineLbl.textColor = [UIColor blackColor];
           // [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];
            break;        
            default:
            break;
    }
    [noteTable reloadData];
}

-(void)sortButtonTouchAction:(id)sender{
    switch ([sender tag]) {
        case 0:
        {
            dateButton.selected = YES;
            dateLbl.textColor = [UIColor lightGrayColor];
            popularButton.selected = NO;
            abcButton.selected = NO;
            tagButton.selected = NO;
            popularLbl.textColor = [UIColor blackColor];
            abcLbl.textColor = [UIColor blackColor];
            tagLbl.textColor = [UIColor blackColor];  
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"noteId"
                                                          ascending:NO] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            self.noteList = [[[self.noteList sortedArrayUsingDescriptors:sortDescriptors] copy]autorelease];
            self.gameNoteList = [[[self.gameNoteList sortedArrayUsingDescriptors:sortDescriptors] copy]autorelease];
            tagFilter = NO;

            break;
        }
        case 1:
        {
            abcButton.selected = YES;
            abcLbl.textColor = [UIColor lightGrayColor];
            dateButton.selected = NO;
            popularButton.selected = NO;
            tagButton.selected = NO;
            dateLbl.textColor = [UIColor blackColor];
            popularLbl.textColor = [UIColor blackColor];
            tagLbl.textColor = [UIColor blackColor];
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"title"
                                                          ascending:YES] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            self.noteList = [[[self.noteList sortedArrayUsingDescriptors:sortDescriptors] copy]autorelease];
            self.gameNoteList = [[[self.gameNoteList sortedArrayUsingDescriptors:sortDescriptors] copy]autorelease];
            tagFilter = NO;

            break;  
        }
        case 2:
        {
            popularButton.selected = YES;
            popularLbl.textColor = [UIColor lightGrayColor];
            dateButton.selected = NO;
            abcButton.selected = NO;
            tagButton.selected = NO;
            dateLbl.textColor = [UIColor blackColor];
            abcLbl.textColor = [UIColor blackColor];
            tagLbl.textColor = [UIColor blackColor];
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"numRatings"
                                                          ascending:NO] autorelease];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            self.noteList = [[[self.noteList sortedArrayUsingDescriptors:sortDescriptors] copy]autorelease];
            self.gameNoteList = [[[self.gameNoteList sortedArrayUsingDescriptors:sortDescriptors] copy]autorelease];
            tagFilter = NO;

            break; 
        }
        case 3:
        {
            tagButton.selected = YES;
            tagLbl.textColor = [UIColor lightGrayColor];
            dateButton.selected = NO;
            popularButton.selected = NO;
            abcButton.selected = NO;
            dateLbl.textColor = [UIColor blackColor];
            popularLbl.textColor = [UIColor blackColor];
            abcLbl.textColor = [UIColor blackColor];
            tagFilter = YES;
            break; 
        }
        default:
            break;
    }
    [noteTable reloadData];

}
- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"NotebookViewController: View Appeared");	
	
    
    
	NSLog(@"NotebookViewController: view did appear");
    [self refresh];
}


-(void)refresh {
	NSLog(@"NotebookViewController: Refresh Requested");
            
   [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];
    
   [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];

   [[AppServices sharedAppServices]fetchGameTags];
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
-(void)barButtonTouchAction:(id)sender{
    NoteViewController *noteVC = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil];
    noteVC.startWithView = [sender tag] + 1;
    noteVC.delegate = self;
    [self.navigationController pushViewController:noteVC animated:NO];
    [noteVC release];
    }
- (void)refreshViewFromModel {
	NSLog(@"NotebookViewController: Refresh View from Model");
        
	self.noteList = [AppModel sharedAppModel].playerNoteList;
    self.gameNoteList = [AppModel sharedAppModel].gameNoteList;
    
    if([AppModel sharedAppModel].gameTagList){
    self.tagList = [AppModel sharedAppModel].gameTagList;
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"tagName"
                                                  ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    self.tagList = [[[self.tagList sortedArrayUsingDescriptors:sortDescriptors] copy]autorelease];
        [tagGameNoteList removeAllObjects];
        [headerTitleGameList removeAllObjects];
    
    for(int i = 0; i < [self.tagList count];i++){
        NSString *tagName = [[self.tagList objectAtIndex:i] tagName];
                    NSMutableArray *tempTagList = [[NSMutableArray alloc]initWithCapacity:5];
        for(int x = 0; x < [self.gameNoteList count]; x++){

            for(int y = 0; y < [[[self.gameNoteList objectAtIndex:x] tags] count]; y ++){
                if ([[[[[self.gameNoteList objectAtIndex:x] tags] objectAtIndex:y] tagName] isEqualToString:tagName]) {
                    Note *tempNote = [[Note alloc]init];
                    tempNote = [self.gameNoteList objectAtIndex:x];
                    [tempNote setTagName:tagName];
                    NSLog(@"TAGNAME: %@",tagName);
                    [tempTagList addObject:tempNote];
                   // [tempNote release];
                }
            }
           

            }
        if([tempTagList count] >0){
            [self.tagGameNoteList addObject:tempTagList];
            [self.headerTitleGameList addObject:tagName];
        }
        [tempTagList release];
        }
        
        [tagNoteList removeAllObjects];
        [headerTitleList removeAllObjects];
        
        for(int i = 0; i < [self.tagList count];i++){
            NSString *tagName = [[self.tagList objectAtIndex:i] tagName];
            NSMutableArray *tempTagList = [[NSMutableArray alloc]initWithCapacity:5];
            for(int x = 0; x < [self.noteList count]; x++){
                
                for(int y = 0; y < [[[self.noteList objectAtIndex:x] tags] count]; y ++){
                    if ([[[[[self.noteList objectAtIndex:x] tags] objectAtIndex:y] tagName] isEqualToString:tagName]) {
                        Note *tempNote = [[Note alloc]init];
                        tempNote = [self.noteList objectAtIndex:x];
                        [tempNote setTagName:tagName];
                        NSLog(@"TAGNAME: %@",tagName);
                        [tempTagList addObject:tempNote];
                        //[tempNote release];
                    }
                }
                
                
            }
            if([tempTagList count] >0){
                [self.tagNoteList addObject:tempTagList];
                [self.headerTitleList addObject:tagName];
            }
            [tempTagList release];
        }

        UIButton *b = [[[UIButton alloc]init]autorelease];
        b.tag = filSelected;
        [self sortButtonTouchAction:b];
        UIButton *c = [[[UIButton alloc]init]autorelease];
        c.tag = sortSelected;
        //[noteTable reloadData];
        }
 /*
    for(int i = 0; i < [self.tagList count];i++){
        NSString *tagName = [[self.tagList objectAtIndex:i] tagName];
        for(int x = 0; x < [self.noteList count]; x++){
            for(int y = 0; y < [[[self.noteList objectAtIndex:x] tags] count]; y ++){
                if ([[[[[self.noteList objectAtIndex:x] tags] objectAtIndex:y] tagName] isEqualToString:tagName]) {
                    Note *tempNote = [self.noteList objectAtIndex:x];
                    [tempNote setTagSection:i];
                    [self.tagNoteList addObject:tempNote];
                }
            }
        }
    }
*/
    
    //unregister for notifications
                   //  [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tagFilter){
        if(!self.sharedButton.selected)
            return [self.tagNoteList count];
        else
        return [self.tagGameNoteList count];
        
    }
    else
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(!tagFilter){
     if(self.sharedButton.selected == NO){ 
        if([self.noteList count] == 0) return 1;
        return [self.noteList count];}
    else {
        if([self.gameNoteList count] == 0) return 1;
        return [self.gameNoteList count];
    }
    }
    else{
        if(!sharedButton.selected)
            return [[self.tagNoteList objectAtIndex:section] count]; 
        else
            return [[self.tagGameNoteList objectAtIndex:section] count]; 
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.videoIconUsed = NO;
    self.photoIconUsed = NO;
    self.audioIconUsed = NO;
    self.textIconUsed = NO;
    NSMutableArray *currentNoteList;
    if(!self.sharedButton.selected){ 
        currentNoteList = self.noteList;
        isGameList = NO;
    }
    else {
      currentNoteList = self.gameNoteList;  
        isGameList = YES;
    }
    
    if(tagFilter){
        if(!self.sharedButton.selected)
            currentNoteList = self.tagNoteList;
        else 
        currentNoteList = self.tagGameNoteList;
    }
    
	static NSString *CellIdentifier = @"Cell";
    if([currentNoteList count] == 0 && indexPath.row == 0){
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

        cell.textLabel.text = @"No Notes";
        cell.detailTextLabel.text = @"Press A Red Button Above To Add One!";
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
        
    Note *currNote;
    if(!tagFilter){
            currNote = (Note *)[currentNoteList objectAtIndex:indexPath.row];
    }
    else{
    //tag stuff  
        
        currNote = (Note *)[[currentNoteList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    cell.note = currNote;
    cell.delegate = self;
    cell.index = indexPath.row;
    cell.commentsLbl.text = [NSString stringWithFormat:@"%d comments",[currNote.comments count]];
    cell.likesLbl.text = [NSString stringWithFormat:@"+%d",currNote.numRatings];
        cell.titleLabel.text = currNote.title;
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
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(tagFilter){
        if(!self.sharedButton.selected){
            if([self.headerTitleList count] > section)
                return [self.headerTitleList objectAtIndex:section];
            else return @"";

        }
        else{
            if([self.headerTitleGameList count] > section)
                return [self.headerTitleGameList objectAtIndex:section];
            else return @"";
        }
        
    }
    else return @"";
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
    if(self.sharedButton.selected == NO) {
        if(!tagFilter)
        currentNoteList = self.noteList;
        else
            currentNoteList = [self.tagNoteList objectAtIndex:indexPath.section];
        
    }
    else{ 
        if(!tagFilter)
        currentNoteList = self.gameNoteList;
        else
            currentNoteList = [self.tagGameNoteList objectAtIndex:indexPath.section];
    }
 


            //open up note viewer
        DataCollectionViewController *dataVC = [[[DataCollectionViewController alloc] initWithNibName:@"DataCollectionViewController" bundle:nil]autorelease];
    dataVC.delegate = self;
        dataVC.note = (Note *)[currentNoteList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:dataVC animated:YES];
        //[dataVC release];
        
    
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tagFilter) return UITableViewCellEditingStyleNone;
    if([self.noteList count] == 0 ||self.noteControl.selectedSegmentIndex==1) return UITableViewCellEditingStyleNone;

    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[AppServices sharedAppServices]deleteNoteWithNoteId:[(Note *)[self.noteList objectAtIndex:indexPath.row] noteId]];
    self.noteList = [self.noteList mutableCopy];
    [self.noteList removeObjectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView 

didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {

    [noteTable reloadData];
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  @"Delete Note";
}
/*
-(void)controlChanged:(id)sender{
    if (self.noteControl.selectedSegmentIndex ==0){
        [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];

    }
    else {
        [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];

    }
    [noteTable reloadData];
}
*/

- (void)dealloc {    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [noteList release];
    [gameNoteList release];
    [noteTable release];
    [noteControl release];
    [super dealloc];
}
@end

//
//  NotebookViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotebookViewController.h"
#import "NoteEditorViewController.h"
#import "NoteDetailsViewController.h"
#import "AppServices.h"
#import "NoteCell.h"
#import "Note.h"
#import "ARISAppDelegate.h"

BOOL menuDown;
int filSelected;
int sortSelected;
BOOL tagFilter;
@implementation NotebookViewController
@synthesize noteList,noteTable, filterControl,sortControl,gameNoteList,textIconUsed,videoIconUsed,photoIconUsed,audioIconUsed,isGameList,tagList,tagNoteList,tagGameNoteList,headerTitleList,headerTitleGameList,toolBar,filterToolBar,sortToolBar;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self)
    {
        self.title = NSLocalizedString(@"NotebookTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"96-book"]; 
        noteList            = [[NSMutableArray alloc] initWithCapacity:10];
        gameNoteList        = [[NSMutableArray alloc] initWithCapacity:10];
        tagList             = [[NSMutableArray alloc] initWithCapacity:10];
        tagNoteList         = [[NSMutableArray alloc] initWithCapacity:10];
        tagGameNoteList     = [[NSMutableArray alloc] initWithCapacity:10];
        headerTitleList     = [[NSMutableArray alloc] initWithCapacity:10];
        headerTitleGameList = [[NSMutableArray alloc] initWithCapacity:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh)                name:@"NoteDeleted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewNoteListReady" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedNoteList" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *barButtonImage = [UIImage imageNamed:@"14-gear"];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithImage:barButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(displayMenu)];

    self.navigationItem.rightBarButtonItem = barButton;
    [self.filterToolBar setFrame:CGRectMake(0, -44, 320, 44)];
    [self.sortToolBar setFrame:CGRectMake(0, 416, 320, 44)];
    [self.toolBar setFrame:CGRectMake(0, 0, 320, 44)];
    
    [self.noteTable setFrame:CGRectMake(0, 44, 320, 324)];
    filSelected = 0;
    sortSelected = 0;
}

-(void)displayMenu
{
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
    
    menuDown = !menuDown;
    if(menuDown)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.2];
        [self.filterToolBar setFrame:CGRectMake(0, 0, 320, 44)];
        [self.sortToolBar setFrame:CGRectMake(0, 323, 320, 44)];
        [self.toolBar setFrame:CGRectMake(0, 44, 320, 44)];
        [self.noteTable setFrame:CGRectMake(0, 88, 320, 235)];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.2];
        [self.filterToolBar setFrame:CGRectMake(0, -44, 320, 44)];
        [self.sortToolBar setFrame:CGRectMake(0, 367, 320, 44)];
        [self.toolBar setFrame:CGRectMake(0, 0, 320, 44)];
        [self.noteTable setFrame:CGRectMake(0, 44, 320, 323)];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
        [UIView commitAnimations];       
    }
}

-(void)filterButtonTouchAction:(id)sender
{    
    [self refresh];
}

-(void)sortButtonTouchAction:(id)sender
{
    if([sender isKindOfClass:[UISegmentedControl class]])
        [sender setTag:[(UISegmentedControl *)sender selectedSegmentIndex]];
    
    switch ([sender tag])
    {
        case 0:
        {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"noteId" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            tagFilter = NO;   
            
            self.noteList = [NSMutableArray arrayWithArray:[self.noteList sortedArrayUsingDescriptors:sortDescriptors]];
            self.gameNoteList = [NSMutableArray arrayWithArray:[self.gameNoteList sortedArrayUsingDescriptors:sortDescriptors]];

            break;
        }
        case 1:
        {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            tagFilter = NO;       
            
            self.noteList = [NSMutableArray arrayWithArray:[self.noteList sortedArrayUsingDescriptors:sortDescriptors]];
            self.gameNoteList = [NSMutableArray arrayWithArray:[self.gameNoteList sortedArrayUsingDescriptors:sortDescriptors]];
            
            break;  
        }
        case 2:
        {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"numRatings" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            tagFilter = NO;  
            
            self.noteList = [NSMutableArray arrayWithArray:[self.noteList sortedArrayUsingDescriptors:sortDescriptors]];
            self.gameNoteList = [NSMutableArray arrayWithArray:[self.gameNoteList sortedArrayUsingDescriptors:sortDescriptors]];

            break; 
        }
        case 3:
        {
            tagFilter = YES;
            break; 
        }
        default:
            break;
    }
    [noteTable reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refresh];
}

-(void)refresh
{
    if(filterControl.selectedSegmentIndex == 0)
        [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];
    else
        [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];
    
    [[AppServices sharedAppServices] fetchGameNoteTagsAsynchronously:YES];
    [self refreshViewFromModel];
    [noteTable reloadData];
}

#pragma mark custom methods, logic
-(void)showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[activityIndicator startAnimating];    
}

-(void)removeLoadingIndicator
{
    [noteTable reloadData];
}

-(void)barButtonTouchAction:(id)sender
{
    NoteEditorViewController *noteVC = [[NoteEditorViewController alloc] initWithNibName:@"NoteEditorViewController" bundle:nil];
    noteVC.startWithView = [sender tag] + 1;
    noteVC.delegate = self;
    [self.navigationController pushViewController:noteVC animated:NO];
}

- (void)refreshViewFromModel
{    
	noteList = [[[AppModel sharedAppModel].playerNoteList allValues] mutableCopy];
    if([AppModel sharedAppModel].currentGame.allowShareNoteToList)
        gameNoteList = [[[AppModel sharedAppModel].gameNoteList allValues] mutableCopy];
    else
        gameNoteList = [[NSMutableArray alloc] initWithCapacity:10];
    
    for(int i = 0; i < [gameNoteList count]; i++)
    {
        if(!((Note *)[gameNoteList objectAtIndex:i]).showOnList)
        {
            [gameNoteList removeObjectAtIndex:i];
            i--;
        }
    }
    
    if([AppModel sharedAppModel].gameTagList)
    {
        self.tagList = [AppModel sharedAppModel].gameTagList;
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tagName" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        tagList = [[tagList sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        [tagGameNoteList     removeAllObjects];
        [headerTitleGameList removeAllObjects];
        
        for(int i = 0; i < [self.tagList count]; i++)
        {
            NSString *tagName = [[self.tagList objectAtIndex:i] tagName];
            NSMutableArray *tempTagList = [[NSMutableArray alloc]initWithCapacity:5];
            for(int x = 0; x < [self.gameNoteList count]; x++)
            {                
                for(int y = 0; y < [[[self.gameNoteList objectAtIndex:x] tags] count]; y ++)
                {
                    if ([[[[[self.gameNoteList objectAtIndex:x] tags] objectAtIndex:y] tagName] isEqualToString:tagName])
                    {
                        Note *tempNote;
                        tempNote = [self.gameNoteList objectAtIndex:x];
                        [tempNote setTagName:tagName];
                        [tempTagList addObject:tempNote];
                    }
                }
            }
            if([tempTagList count] >0)
            {
                [self.tagGameNoteList addObject:tempTagList];
                [self.headerTitleGameList addObject:tagName];
            }
        }
        
        [tagNoteList removeAllObjects];
        [headerTitleList removeAllObjects];
        
        for(int i = 0; i < [self.tagList count]; i++)
        {
            NSString *tagName = [[self.tagList objectAtIndex:i] tagName];
            NSMutableArray *tempTagList = [[NSMutableArray alloc]initWithCapacity:5];
            for(int x = 0; x < [self.noteList count]; x++)
            {
                for(int y = 0; y < [[[self.noteList objectAtIndex:x] tags] count]; y ++)
                {
                    if ([[[[[self.noteList objectAtIndex:x] tags] objectAtIndex:y] tagName] isEqualToString:tagName])
                    {
                        Note *tempNote;
                        tempNote = [self.noteList objectAtIndex:x];
                        [tempNote setTagName:tagName];
                        [tempTagList addObject:tempNote];
                    }
                }
                
                
            }
            if([tempTagList count] >0)
            {
                [self.tagNoteList addObject:tempTagList];
                [self.headerTitleList addObject:tagName];
            }
        }
        UIButton *b = [[UIButton alloc]init];
        b.tag = filSelected;
        [self sortButtonTouchAction:b];
    }
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tagFilter)
    {
        if(self.filterControl.selectedSegmentIndex == 0)
            return [self.tagNoteList count];
        else
            return [self.tagGameNoteList count];
    }
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!tagFilter)
    {
        if(self.filterControl.selectedSegmentIndex == 0)
        {
            if([self.noteList count] == 0) return 1;
            return [self.noteList count];
        }
        else
        {
            if([self.gameNoteList count] == 0) return 1;
            return [self.gameNoteList count];
        }
    }
    else
    {
        if(self.filterControl.selectedSegmentIndex == 0)
            return [[self.tagNoteList objectAtIndex:section] count]; 
        else
            return [[self.tagGameNoteList objectAtIndex:section] count]; 
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.videoIconUsed = NO;
    self.photoIconUsed = NO;
    self.audioIconUsed = NO;
    self.textIconUsed = NO;
    NSMutableArray *currentNoteList;
    if(self.filterControl.selectedSegmentIndex == 0)
    {
        currentNoteList = self.noteList;
        [AppModel sharedAppModel].isGameNoteList  = NO;
    }
    else
    {
        currentNoteList = self.gameNoteList;  
        [AppModel sharedAppModel].isGameNoteList  = YES;
    }
    
    if(tagFilter)
    {
        if(self.filterControl.selectedSegmentIndex == 0)
            currentNoteList = self.tagNoteList;
        else 
            currentNoteList = self.tagGameNoteList;
    }
    
	static NSString *CellIdentifier = @"Cell";
    if([currentNoteList count] == 0 && indexPath.row == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.textLabel.text =NSLocalizedString(@"NotebookNoNotesKey", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"NotebooksPressToAddKey", @"");
        cell.userInteractionEnabled = NO;
        return cell;
    }
    
    UITableViewCell *tempCell = (NoteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (tempCell && ![tempCell respondsToSelector:@selector(mediaIcon1)])
    {
        NSLog(@"NotebookViewController: Throwing out dequeued cell");
        tempCell = nil;
    }
    else NSLog(@"NotebookViewController: Reusing out dequeued cell");
    
    NoteCell *cell = (NoteCell *)tempCell;
    
    
    if(cell == nil)
    {
        NSLog(@"NotebookViewController: Allocing a new cell");
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"NoteCell" bundle:nil];
        cell = (NoteCell *)temporaryController.view;
    }
    
    Note *currNote;
    if(!tagFilter)
        currNote = (Note *)[currentNoteList objectAtIndex:indexPath.row];
    else
        currNote = (Note *)[[currentNoteList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    cell.note = currNote;
    cell.delegate = self;
    cell.index = indexPath.row;
    if([currNote.comments count] == 0)
    {
        cell.commentsLbl.text = @"";
        [cell.likesButton setFrame:CGRectMake(cell.likesButton.frame.origin.x,14,cell.likesButton.frame.size.width , cell.likesButton.frame.size.height)];
        [cell.likeLabel setFrame:CGRectMake(cell.likeLabel.frame.origin.x,26,cell.likeLabel.frame.size.width , cell.likeLabel.frame.size.height)];
    }
    else
    {
        cell.commentsLbl.text = [NSString stringWithFormat:@"%d %@",[currNote.comments count],NSLocalizedString(@"NotebookCommentsKey", @"")];
        [cell.likesButton setFrame:CGRectMake(cell.likesButton.frame.origin.x,2,cell.likesButton.frame.size.width , cell.likesButton.frame.size.height)];
        [cell.likeLabel setFrame:CGRectMake(cell.likeLabel.frame.origin.x,14,cell.likeLabel.frame.size.width , cell.likeLabel.frame.size.height)];
    }
    cell.likeLabel.text = [NSString stringWithFormat:@"%d",currNote.numRatings];
    if(currNote.userLiked)cell.likesButton.selected = YES;
    cell.titleLabel.text = currNote.title;
    if([currNote.contents count] == 0 && (currNote.creatorId != [AppModel sharedAppModel].playerId))cell.userInteractionEnabled = NO;
    for(int x = 0; x < [currNote.contents count];x++){
        if([[(NoteContent *)[currNote.contents objectAtIndex:x] type] isEqualToString:kNoteContentTypeText]&& !self.textIconUsed)
        {
            self.textIconUsed = YES;
            if (cell.mediaIcon1.image == nil)
                cell.mediaIcon1.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
            else if(cell.mediaIcon2.image == nil)
                cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
            else if(cell.mediaIcon3.image == nil)
                cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
            else if(cell.mediaIcon4.image == nil)
                cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
        }
        else if ([[(NoteContent *)[currNote.contents objectAtIndex:x] type] isEqualToString:kNoteContentTypePhoto]&& !self.photoIconUsed)
        {
            self.photoIconUsed = YES;
            if (cell.mediaIcon1.image == nil)
                cell.mediaIcon1.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
            else if(cell.mediaIcon2.image == nil)
                cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
            else if(cell.mediaIcon3.image == nil)
                cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
            else if(cell.mediaIcon4.image == nil)
                cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
        }
        else if([[(NoteContent *)[currNote.contents objectAtIndex:x] type] isEqualToString:kNoteContentTypeAudio] && !self.audioIconUsed)
        {
            self.audioIconUsed = YES;
            if (cell.mediaIcon1.image == nil)
                cell.mediaIcon1.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
            else if(cell.mediaIcon2.image == nil)
                cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
            else if(cell.mediaIcon3.image == nil)
                cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
            else if(cell.mediaIcon4.image == nil)
                cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
        }
        else if([[(NoteContent *)[currNote.contents objectAtIndex:x] type] isEqualToString:kNoteContentTypeVideo] && !self.videoIconUsed)
        {
            self.videoIconUsed = YES;
            if (cell.mediaIcon1.image == nil)
                cell.mediaIcon1.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
            else if(cell.mediaIcon2.image == nil)
                cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
            else if(cell.mediaIcon3.image == nil)
                cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
            else if(cell.mediaIcon4.image == nil)
                cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
        }
    }
    
    if(![AppModel sharedAppModel].currentGame.allowNoteLikes)
    {
        cell.likesButton.enabled = NO;
        cell.likeLabel.hidden = YES;
        cell.likesButton.hidden = YES;
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tagFilter)
    {
        if(self.filterControl.selectedSegmentIndex == 0)
        {
            if([self.headerTitleList count] > section)
                return [self.headerTitleList objectAtIndex:section];
            else return @"";
            
        }
        else
        {
            if([self.headerTitleGameList count] > section)
                return [self.headerTitleGameList objectAtIndex:section];
            else return @"";
        }
        
    }
    else return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row % 2 == 0) cell.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];  
    else                        cell.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *currentNoteList;
    if(self.filterControl.selectedSegmentIndex == 0)
    {
        [AppModel sharedAppModel].isGameNoteList = NO;
        if(!tagFilter)
            currentNoteList = self.noteList;
        else
            currentNoteList = [self.tagNoteList objectAtIndex:indexPath.section];
        
    }
    else
    {
        [AppModel sharedAppModel].isGameNoteList = YES;
        
        if(!tagFilter)
            currentNoteList = self.gameNoteList;
        else
            currentNoteList = [self.tagGameNoteList objectAtIndex:indexPath.section];
    }
    
    //open up note viewer
    NoteDetailsViewController *dataVC = [[NoteDetailsViewController alloc] initWithNibName:@"NoteDetailsViewController" bundle:nil];
    dataVC.delegate = self;
    dataVC.note = (Note *)[currentNoteList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:dataVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tagFilter) return UITableViewCellEditingStyleNone;
    if([AppModel sharedAppModel].isGameNoteList )
    {
        if(([self.gameNoteList count] != 0) && [[self.gameNoteList objectAtIndex:indexPath.row] creatorId] == [AppModel sharedAppModel].playerId)
            return UITableViewCellEditingStyleDelete;
    }
    else
    {
        if([self.noteList count] != 0)
            return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[AppServices sharedAppServices]deleteNoteWithNoteId:[(Note *)[self.noteList objectAtIndex:indexPath.row] noteId]];
    if([AppModel sharedAppModel].isGameNoteList)
        [[AppModel sharedAppModel].gameNoteList removeObjectForKey:[NSNumber numberWithInt:[(Note *)[self.noteList objectAtIndex:indexPath.row] noteId]]];
    else
        [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:[(Note *)[self.noteList objectAtIndex:indexPath.row] noteId]]];
    [self refreshViewFromModel];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [noteTable reloadData];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  @"Delete Note";
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

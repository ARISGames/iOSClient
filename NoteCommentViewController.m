//
//  NoteCommentViewController.m
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteCommentViewController.h"
#import "NotebookViewController.h"
#import "NoteViewController.h"
#import "DataCollectionViewController.h"
#import "AppServices.h"
#import "NoteCommentCell.h"
#import "ARISAppDelegate.h"

@implementation NoteCommentViewController
@synthesize parentNote,commentNote,textBox,rating,commentTable,addAudioButton,addPhotoButton,addMediaFromAlbumButton,myIndexPath,commentValid,starView,addTextButton,commentsList,videoIconUsed,photoIconUsed,audioIconUsed,currNoteHasAudio,currNoteHasPhoto,currNoteHasVideo;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.parentNote = [[Note alloc]init];
        self.commentNote = [[Note alloc]init];
        self.title = @"Comments";
        self.commentsList = [[NSMutableArray alloc] initWithCapacity:10];
        self.hidesBottomBarWhenPushed = YES;
        commentValid = NO;
    }
    return self;
}
- (void)viewDidLoad
{
    self.parentNote = [[AppServices sharedAppServices]fetchNote:self.parentNote.noteId];
    self.commentsList = [self.parentNote.comments mutableCopy];
    UIBarButtonItem *hideKeyboardButton = [[UIBarButtonItem alloc] initWithTitle:@"Save Comment" style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];      
    self.navigationItem.rightBarButtonItem = hideKeyboardButton;
    

    
    self.myIndexPath = [[NSIndexPath alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.starView.rating = 0;
    self.starView.backgroundColor = [UIColor clearColor];
	
    [self.starView setStarImage:[UIImage imageNamed:@"star-halfselected.png"]
                       forState:kSCRatingViewHalfSelected];
    [self.starView setStarImage:[UIImage imageNamed:@"star-highlighted.png"]
                       forState:kSCRatingViewHighlighted];
    [self.starView setStarImage:[UIImage imageNamed:@"star-hot.png"]
                       forState:kSCRatingViewHot];
    [self.starView setStarImage:[UIImage imageNamed:@"star-highlighted.png"]
                       forState:kSCRatingViewNonSelected];
    [self.starView setStarImage:[UIImage imageNamed:@"star-selected.png"]
                       forState:kSCRatingViewSelected];
    [self.starView setStarImage:[UIImage imageNamed:@"star-hot.png"]
                       forState:kSCRatingViewUserSelected];
}
-(void)viewWillAppear:(BOOL)animated{
    self.videoIconUsed = NO;
    self.photoIconUsed = NO;
    self.audioIconUsed = NO;
    
}
-(void)addPhotoButtonTouchAction{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
    cameraVC.delegate = self;
    cameraVC.showVid = YES;
    if(self.commentNote.noteId == 0)   self.commentNote.noteId = [[AppServices sharedAppServices]addCommentToNoteWithId:self.parentNote.noteId andRating:self.rating];
    cameraVC.noteId = self.commentNote.noteId;

    [self.navigationController pushViewController:cameraVC animated:YES];
    }
}
-(void)addAudioButtonTouchAction{
    BOOL audioHWAvailable = [[AVAudioSession sharedInstance] inputIsAvailable];
    if(audioHWAvailable){
    AudioRecorderViewController *audioVC = [[[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil] autorelease];
    audioVC.delegate = self;
    if(self.commentNote.noteId == 0)   self.commentNote.noteId = [[AppServices sharedAppServices]addCommentToNoteWithId:self.parentNote.noteId andRating:self.rating];
    audioVC.noteId = self.commentNote.noteId;

    [self.navigationController pushViewController:audioVC animated:YES];
    }

}
-(void)addTextButtonTouchAction{
    NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];
    cell.titleLabel.editable = YES;
    cell.titleLabel.delegate = self;
    [cell.titleLabel becomeFirstResponder];
}
-(void)addMediaFromAlbumButtonTouchAction{
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
    //cameraVC.delegate = self.delegate;
    cameraVC.showVid = NO;
    if(self.commentNote.noteId == 0)   self.commentNote.noteId = [[AppServices sharedAppServices]addCommentToNoteWithId:self.parentNote.noteId andRating:self.rating];
    cameraVC.noteId = self.commentNote.noteId;

    [self.navigationController pushViewController:cameraVC animated:YES];

}
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.commentsList count] + 1;
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.videoIconUsed = NO;
    self.photoIconUsed = NO;
    self.audioIconUsed = NO;
    static NSString *CellIdentifier = @"Cell";
 
    UITableViewCell *tempCell = (NoteCommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (![tempCell respondsToSelector:@selector(mediaIcon2)]){
        //[tempCell release];
        tempCell = nil;
    }
    NoteCommentCell *cell = (NoteCommentCell *)tempCell;
    if (cell == nil) {
        // Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"NoteCommentCell" bundle:nil];
        // Grab a pointer to the custom cell.
        cell = (NoteCommentCell *)temporaryController.view;
        // Release the temporary UIViewController.
        [temporaryController release];
    }


    if(indexPath.row == 0){
        cell.likesLabel.text = [NSString stringWithFormat:@"+%d",0];

        cell.titleLabel.text = self.textBox.text;
        cell.userLabel.text = [AppModel sharedAppModel].userName;
        self.myIndexPath = indexPath;
        cell.starView.rating = self.starView.userRating;
        cell.userInteractionEnabled = NO;
        
        if(self.currNoteHasPhoto) cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
        if(self.currNoteHasAudio) cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
        if(self.currNoteHasVideo) cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
        
        return cell;
    }

    else{
    Note *currNote = [self.commentsList objectAtIndex:(indexPath.row -1)];
        cell.likesLabel.text = [NSString stringWithFormat:@"+%d",currNote.numRatings];

    if([currNote.contents count] == 0 && (currNote.creatorId != [AppModel sharedAppModel].playerId))cell.userInteractionEnabled = NO;
    cell.titleLabel.text = currNote.title;
        cell.userLabel.text = currNote.username;
        cell.starView.rating = currNote.parentRating;
    for(int x = 0; x < [currNote.contents count];x++){
                if([[[[currNote contents] objectAtIndex:x] type] isEqualToString:@"TEXT"]){
                    //Dont show icon for text since it is assumed to always be there
        }
        else if ([[[[currNote contents] objectAtIndex:x] type] isEqualToString:@"PHOTO"]&& !self.photoIconUsed){
            self.photoIconUsed = YES;
            if(cell.mediaIcon2.image == nil) {
                cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
                
            }
            else if(cell.mediaIcon3.image == nil) {
                cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
                
            }
            else if(cell.mediaIcon4.image == nil) {
                cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
                
            }
            
        }
        else if([[[[currNote contents] objectAtIndex:x] type] isEqualToString:@"AUDIO"] && !self.audioIconUsed){
            self.audioIconUsed = YES;
           if(cell.mediaIcon2.image == nil) {
                cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
                
            }
            else if(cell.mediaIcon3.image == nil) {
                cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
                
            }
            else if(cell.mediaIcon4.image == nil) {
                cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
                
            }
            
        }
        else if([[[[currNote contents] objectAtIndex:x] type] isEqualToString:@"VIDEO"] && !self.videoIconUsed){
            self.videoIconUsed = YES;
          if(cell.mediaIcon2.image == nil) {
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
    if(indexPath.row == 0){
        
    }
    else if([[self.commentsList objectAtIndex:(indexPath.row-1)] creatorId] == [AppModel sharedAppModel].playerId){
        
        NoteViewController *noteVC = [[[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil]autorelease];
        noteVC.note = [self.commentsList objectAtIndex:indexPath.row-1];
        noteVC.delegate = self;
        [self.navigationController pushViewController:noteVC animated:YES];
        //[noteVC release];
        
        
        
    }
    else{
        //open up note viewer
        DataCollectionViewController *dataVC = [[[DataCollectionViewController alloc] initWithNibName:@"DataCollectionViewController" bundle:nil]autorelease];
        dataVC.note = [self.commentsList objectAtIndex:indexPath.row-1];
        [self.navigationController pushViewController:dataVC animated:YES];
        //[dataVC release];
    }
    
}
- (int) calculateTextHeight:(NSString *)text {
	CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 200000);
	CGSize calcSize = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0]
					   constrainedToSize:frame.size lineBreakMode:UILineBreakModeWordWrap];
	frame.size = calcSize;
	frame.size.height += 0;
	//NSLog(@"Found height of %f", frame.size.height);
	return frame.size.height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row > 0){
       CGFloat textHeight = [self calculateTextHeight:[(Note *)[self.commentsList objectAtIndex:(indexPath.row - 1)] title]] +35;
    NSLog(@"Height for Row:%d is %f",indexPath.row,textHeight);
        if (textHeight < 60)return 60;
        else
        return textHeight;}
    else {CGFloat textHeight = [self calculateTextHeight:self.textBox.text] +35;
        return textHeight;}
}
#pragma mark Text view methods
-(void)hideKeyboard{
    UIAlertView *alert = [[UIAlertView alloc]init];
    NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];
    [cell.titleLabel resignFirstResponder];

    if([cell.titleLabel.text length] == 0 || [cell.titleLabel.text isEqualToString:@"Write Comment..."]){
        alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                message: NSLocalizedString(@"Please add a comment", @"")
                                               delegate: self cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else if(self.starView.userRating == 0){
        alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                message: NSLocalizedString(@"Please give this game a rating of one through five stars", @"")
                                               delegate: self cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else{
        if(self.commentNote.noteId == 0)   self.commentNote.noteId = [[AppServices sharedAppServices]addCommentToNoteWithId:self.parentNote.noteId andRating:self.starView.userRating];
        [[AppServices sharedAppServices]updateNoteWithNoteId:self.commentNote.noteId title:cell.titleLabel.text andShared:NO];
        [[AppServices sharedAppServices]updateCommentWithId:self.commentNote.noteId parentNoteId:self.parentNote.noteId andRating:self.starView.userRating];
        // [self addedText];
        self.commentValid = YES;
        self.textBox.text = cell.titleLabel.text;

        [commentTable reloadData];
        

    }

}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@"Write Comment..."]) textView.text = @"";
    
}
- (void)textViewDidChange:(UITextView *)textView{
        NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, [self calculateTextHeight:textView.text]+35);
    NSArray *indexArr = [[NSArray alloc] initWithObjects:self.myIndexPath, nil];
    //[self.commentTable reloadRowsAtIndexPaths:indexArr withRowAnimation:nil];
}
-(void)addedPhoto{
    NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];
     if(cell.mediaIcon2.image == nil) {
        cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
        
    }
   self.commentValid = YES;
    self.currNoteHasPhoto = YES;
}
-(void)addedAudio{
    NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];

 
    if(cell.mediaIcon3.image == nil) {
        cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
        
    }
    self.commentValid = YES;
    self.currNoteHasAudio = YES;
}
-(void)addedVideo{
    NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];
   if(cell.mediaIcon4.image == nil) {
        cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
        
    }
self.commentValid = YES;
    self.currNoteHasVideo = YES;
}
-(void)addedText{
    NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];

    if(cell.mediaIcon2.image == nil) {
        cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
        
    }
    else if(cell.mediaIcon3.image == nil) {
        cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
        
    }
    else if(cell.mediaIcon4.image == nil) {
        cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
        
    }
self.commentValid = YES;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0) return UITableViewCellEditingStyleNone;
  if([[self.commentsList objectAtIndex:(indexPath.row-1)] creatorId] == [AppModel sharedAppModel].playerId){
    
      return UITableViewCellEditingStyleDelete;}
  else return UITableViewCellEditingStyleNone;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[self.commentsList objectAtIndex:(indexPath.row-1)] creatorId] == [AppModel sharedAppModel].playerId){
    [[AppServices sharedAppServices]deleteNoteWithNoteId:[[self.commentsList objectAtIndex:(indexPath.row-1)] noteId]];
    [self.commentsList removeObjectAtIndex:(indexPath.row - 1)];
    }
}

- (void)tableView:(UITableView *)tableView 

didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.commentTable reloadData];
    
}


- (void)dealloc
{
    [super dealloc];
    [parentNote release];
    [commentNote release];
    [textBox release];
    [commentTable release];
    [addAudioButton release];
    [addPhotoButton release];
    [addMediaFromAlbumButton release];
    [myIndexPath release];
    [starView release];
    [addTextButton release];
    [commentsList release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



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

@end

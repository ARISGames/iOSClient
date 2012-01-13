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
@synthesize parentNote,commentNote,textBox,rating,commentTable,addAudioButton,addPhotoButton,addMediaFromAlbumButton,myIndexPath,commentValid,addTextButton,videoIconUsed,photoIconUsed,audioIconUsed,currNoteHasAudio,currNoteHasPhoto,currNoteHasVideo,inputView,hideKeyboardButton,addCommentButton,delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.parentNote = [[Note alloc]init];
        self.commentNote = [[Note alloc]init];
        self.title = @"Comments";
        self.hidesBottomBarWhenPushed = YES;
        commentValid = NO;
    }
    return self;
}
- (void)viewDidLoad
{
    self.parentNote = [[AppServices sharedAppServices]fetchNote:self.parentNote.noteId];
    hideKeyboardButton = [[UIBarButtonItem alloc] initWithTitle:@"Save Comment" style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];      
    //self.navigationItem.rightBarButtonItem = hideKeyboardButton;
    
    addCommentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showKeyboard)];     
    self.navigationItem.rightBarButtonItem = addCommentButton;
    

    

    
    self.myIndexPath = [[NSIndexPath alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    }

-(void)viewWillAppear:(BOOL)animated{
    self.videoIconUsed = NO;
    self.photoIconUsed = NO;
    self.audioIconUsed = NO;
    
}
-(void)addPhotoButtonTouchAction{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
    cameraVC.parentDelegate = self;
    cameraVC.showVid = YES;
    if(self.commentNote.noteId == 0)   self.commentNote.noteId = [[AppServices sharedAppServices]addCommentToNoteWithId:self.parentNote.noteId andTitle:self.textBox.text];
    cameraVC.noteId = self.commentNote.noteId;

    [self.navigationController pushViewController:cameraVC animated:YES];
    }
}
-(void)addAudioButtonTouchAction{
    BOOL audioHWAvailable = [[AVAudioSession sharedInstance] inputIsAvailable];
    if(audioHWAvailable){
    AudioRecorderViewController *audioVC = [[[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil] autorelease];
    audioVC.parentDelegate = self;
    if(self.commentNote.noteId == 0)   self.commentNote.noteId = [[AppServices sharedAppServices]addCommentToNoteWithId:self.parentNote.noteId andTitle:self.textBox.text];
    audioVC.noteId = self.commentNote.noteId;

    [self.navigationController pushViewController:audioVC animated:YES];
    }

}
-(void)addTextButtonTouchAction{

}
-(void)addMediaFromAlbumButtonTouchAction{
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
    //cameraVC.delegate = self.delegate;
    cameraVC.parentDelegate = self;

    cameraVC.showVid = NO;
    if(self.commentNote.noteId == 0)   self.commentNote.noteId = [[AppServices sharedAppServices]addCommentToNoteWithId:self.parentNote.noteId andTitle:self.textBox.text];
    cameraVC.noteId = self.commentNote.noteId;

    [self.navigationController pushViewController:cameraVC animated:YES];

}
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.parentNote.comments count];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

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
    self.photoIconUsed = NO;
    self.videoIconUsed = NO;
    self.audioIconUsed = NO;

  
    Note *currNote = [self.parentNote.comments objectAtIndex:(indexPath.row)];
    cell.note = currNote;
    [cell initCell];
    if([currNote.contents count] == 0 && (currNote.creatorId != [AppModel sharedAppModel].playerId))cell.userInteractionEnabled = NO;
    cell.titleLabel.text = currNote.title;
        cell.userLabel.text = currNote.username;
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

    if([[[self.parentNote.comments objectAtIndex:indexPath.row] contents] count] > 0){
        //open up note viewer
        DataCollectionViewController *dataVC = [[[DataCollectionViewController alloc] initWithNibName:@"DataCollectionViewController" bundle:nil]autorelease];
        dataVC.delegate = self;
        dataVC.note = [self.parentNote.comments objectAtIndex:indexPath.row];
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
       CGFloat textHeight = [self calculateTextHeight:[(Note *)[self.parentNote.comments objectAtIndex:(indexPath.row)] title]] +35;
    NSLog(@"Height for Row:%d is %f",indexPath.row,textHeight);
        if (textHeight < 60)return 60;
        else
        return textHeight;
   }
#pragma mark Text view methods
-(void)showKeyboard{
    self.navigationItem.rightBarButtonItem = hideKeyboardButton;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:.5];
    [self.textBox setFrame:CGRectMake(0, 0, 320, 210)];
    [self.inputView setFrame:CGRectMake(0, 150, 320, 52)];
    [UIView commitAnimations];
    [self.textBox becomeFirstResponder];
}
-(void)hideKeyboard{
   

    if([textBox.text length] == 0 || [textBox.text isEqualToString:@"Write Comment..."]){
        UIAlertView *alert = [[UIAlertView alloc]init];

        alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                message: NSLocalizedString(@"Please add a comment", @"")
                                               delegate: self cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else{
        self.navigationItem.rightBarButtonItem = addCommentButton;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:.5];
        [self.textBox setFrame:CGRectMake(0, -215, 320, 215)];
        [self.inputView setFrame:CGRectMake(0, 416, 320, 52)];
        [UIView commitAnimations];

        [self.textBox resignFirstResponder];

        if(self.commentNote.noteId == 0)   self.commentNote.noteId = [[AppServices sharedAppServices]addCommentToNoteWithId:self.parentNote.noteId andTitle:self.textBox.text];
        else [[AppServices sharedAppServices]updateCommentWithId:self.commentNote.noteId andTitle:self.textBox.text];
        
        
       self.parentNote = [[AppServices sharedAppServices]fetchNote:self.parentNote.noteId];
        [self.delegate setNote:parentNote];
        // [self addedText];
        self.commentValid = YES;
        
        [commentTable reloadData];
    }

}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@"Write Comment..."]) textView.text = @"";
    
}
- (void)textViewDidChange:(UITextView *)textView{
     /*   NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, [self calculateTextHeight:textView.text]+35);
    NSArray *indexArr = [[NSArray alloc] initWithObjects:self.myIndexPath, nil];*/
    //[self.commentTable reloadRowsAtIndexPaths:indexArr withRowAnimation:nil];
}

-(void)addedPhoto{
   /* NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];
     if(cell.mediaIcon2.image == nil) {
        cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]]; 
        
    }*/
   self.commentValid = YES;
    self.currNoteHasPhoto = YES;
    self.addPhotoButton.userInteractionEnabled = NO;
    self.addPhotoButton.selected = YES;
    self.addMediaFromAlbumButton.userInteractionEnabled = NO;
    self.addMediaFromAlbumButton.selected = YES;
    
}
-(void)addedAudio{
   /* NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];

 
    if(cell.mediaIcon3.image == nil) {
        cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]]; 
        
    }*/
    self.commentValid = YES;
    self.currNoteHasAudio = YES;
    self.addAudioButton.userInteractionEnabled = NO;
    self.addAudioButton.selected = YES;

}
-(void)addedVideo{
   /* NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];
   if(cell.mediaIcon4.image == nil) {
        cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]]; 
        
    }*/
self.commentValid = YES;
    self.currNoteHasVideo = YES;
    self.addPhotoButton.userInteractionEnabled = NO;
    self.addPhotoButton.selected = YES;
    self.addMediaFromAlbumButton.userInteractionEnabled = NO;
    self.addMediaFromAlbumButton.selected = YES;
}
-(void)addedText{
   /* NoteCommentCell *cell = (NoteCommentCell *)[self.commentTable cellForRowAtIndexPath:self.myIndexPath];

    if(cell.mediaIcon2.image == nil) {
        cell.mediaIcon2.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
        
    }
    else if(cell.mediaIcon3.image == nil) {
        cell.mediaIcon3.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
        
    }
    else if(cell.mediaIcon4.image == nil) {
        cell.mediaIcon4.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
        
    }*/
self.commentValid = YES;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
   // if(indexPath.row == 0) return UITableViewCellEditingStyleNone;
  if([[self.parentNote.comments objectAtIndex:(indexPath.row)] creatorId] == [AppModel sharedAppModel].playerId){
    
      return UITableViewCellEditingStyleDelete;}
  else return UITableViewCellEditingStyleNone;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[self.parentNote.comments objectAtIndex:(indexPath.row)] creatorId] == [AppModel sharedAppModel].playerId){
    [[AppServices sharedAppServices]deleteNoteWithNoteId:[[self.parentNote.comments objectAtIndex:(indexPath.row)] noteId]];
    [self.parentNote.comments removeObjectAtIndex:(indexPath.row)];
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
    [addTextButton release];
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

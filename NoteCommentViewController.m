//
//  NoteCommentViewController.m
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteCommentViewController.h"
#import "NotebookViewController.h"
#import "NoteEditorViewController.h"
#import "NoteDetailsViewController.h"
#import "AppServices.h"
#import "NoteCommentCell.h"
#import "ARISAppDelegate.h"
#import "AudioRecorderViewController.h"
#import "UIImage+Scale.h"
#import "UploadingCell.h"
#import "AsyncMediaPlayerButton.h"


@implementation NoteCommentViewController
@synthesize parentNote,commentNote,textBox,rating,commentTable,addAudioButton,addPhotoButton,addMediaFromAlbumButton,myIndexPath,commentValid,addTextButton,videoIconUsed,photoIconUsed,audioIconUsed,currNoteHasAudio,currNoteHasPhoto,currNoteHasVideo,inputView,hideKeyboardButton,addCommentButton,delegate,movieViews;
@synthesize asyncMediaDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        movieViews = [[NSMutableArray alloc]initWithCapacity:5];
        asyncMediaDict = [[NSMutableDictionary alloc] initWithCapacity:5];
        self.title = NSLocalizedString(@"NoteCommentViewTitleKey", @"");
        self.hidesBottomBarWhenPushed = YES;
        commentValid = NO;
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNoteListReady" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
        
        
    }
    return self;
}
-(void)refreshViewFromModel{
    [self addUploadsToComments];
    
    [self.commentTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parentNote = [[AppModel sharedAppModel] noteForNoteId:self.parentNote.noteId playerListYesGameListNo:NO];
    if(!self.parentNote) self.parentNote = [[AppModel sharedAppModel] noteForNoteId:self.parentNote.noteId playerListYesGameListNo:YES];
    if(!self.parentNote)
        NSLog(@"this shouldn't happen");
    
    hideKeyboardButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveCommentKey", @"") style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];
    //self.navigationItem.rightBarButtonItem = hideKeyboardButton;
    
    addCommentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showKeyboard)];
    self.navigationItem.rightBarButtonItem = addCommentButton;
    
    myIndexPath = [[NSIndexPath alloc] init];
    [self.navigationItem.backBarButtonItem setAction:@selector(perform:)];
    // Do any additional setup after loading the view from its nib.
}

-(void) perform:(id)sender{
    /* if([[self.commentNote contents] count] == 0 && [textBox.text isEqualToString:@""] && self.commentNote.noteId != 0){
     [[AppServices sharedAppServices]deleteNoteWithNoteId:self.commentNote.noteId];
     [self.parentNote.comments removeObjectAtIndex:0];
     if([AppModel sharedAppModel].isGameNoteList){
     [[AppModel sharedAppModel].gameNoteList removeObjectForKey:[NSNumber numberWithInt:self.commentNote.noteId]];
     }
     else{
     [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:self.commentNote.noteId]];
     }
     
     }*/
    [self.navigationController popViewControllerAnimated:NO];
    
}


-(void)viewWillAppear:(BOOL)animated{
    self.videoIconUsed = NO;
    self.photoIconUsed = NO;
    self.audioIconUsed = NO;
    if(self.textBox.frame.origin.y == 0)
        [self.textBox becomeFirstResponder];
    [self refreshViewFromModel];
    
}

-(void)addUploadsToComments{
    Note *note = [[AppModel sharedAppModel] noteForNoteId: self.parentNote.noteId playerListYesGameListNo:YES];
    if(!note) note = [[AppModel sharedAppModel] noteForNoteId: self.parentNote.noteId playerListYesGameListNo:NO];
    if(!note)
        NSLog(@"this shouldn't happen");
    self.parentNote = note;
    for(int i = 0; i < [self.parentNote.comments count];i++){
        Note *currNote = [self.parentNote.comments objectAtIndex:i];
        for(int x = [currNote.contents count]-1; x >= 0; x--){
            if(![[[currNote.contents objectAtIndex:x] getUploadState] isEqualToString:@"uploadStateDONE"])
                [currNote.contents removeObjectAtIndex:x];
        }
        
        NSMutableDictionary *uploads = [AppModel sharedAppModel].uploadManager.uploadContentsForNotes;
        NSArray *uploadContentForNote = [[uploads objectForKey:[NSNumber numberWithInt:currNote.noteId]]allValues];
        [currNote.contents addObjectsFromArray:uploadContentForNote];
        NSLog(@"NoteEditorVC: Added %d upload content(s) to note",[uploadContentForNote count]);
    }
    if([AppModel sharedAppModel].isGameNoteList){
        [[AppModel sharedAppModel].gameNoteList setObject:self.parentNote forKey:[NSNumber numberWithInt:self.parentNote.noteId]];
    }
    else{
        [[AppModel sharedAppModel].playerNoteList setObject:self.parentNote forKey:[NSNumber numberWithInt:self.parentNote.noteId]];
    }
    
}

-(void)addPhotoButtonTouchAction{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil];
        cameraVC.parentDelegate = self;
        cameraVC.showVid = YES;
        
        cameraVC.noteId = self.commentNote.noteId;
        cameraVC.backView = self;
        
        [self.navigationController pushViewController:cameraVC animated:YES];
    }
}

-(void)addAudioButtonTouchAction{
    BOOL audioHWAvailable = [[AVAudioSession sharedInstance] inputIsAvailable];
    if(audioHWAvailable){
        AudioRecorderViewController *audioVC = [[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil];
        audioVC.parentDelegate = self;
        audioVC.noteId = self.commentNote.noteId;
        audioVC.backView = self;
        
        [self.navigationController pushViewController:audioVC animated:YES];
    }
    
}
-(void)addTextButtonTouchAction{
    
}
-(void)addMediaFromAlbumButtonTouchAction{
    CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil];
    //cameraVC.delegate = self.delegate;
    cameraVC.parentDelegate = self;
    
    cameraVC.showVid = NO;
    cameraVC.noteId = self.commentNote.noteId;
    cameraVC.backView = self;
    
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
    if (tempCell && ![tempCell respondsToSelector:@selector(mediaIcon2)]){
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
    }
    self.photoIconUsed = NO;
    self.videoIconUsed = NO;
    self.audioIconUsed = NO;
    
    Note *currNote = [self.parentNote.comments objectAtIndex:(indexPath.row)];
    cell.note = currNote;
    [cell initCell];
    [cell checkForRetry];
    cell.userInteractionEnabled = YES;
    cell.titleLabel.text = currNote.title;
    cell.userLabel.text = currNote.username;
    CGFloat height = [self calculateTextHeight:[currNote title]] +35;
    if (height < 60)height = 60;
    [cell.userLabel setFrame:CGRectMake(cell.userLabel.frame.origin.x, height-cell.userLabel.frame.size.height-5, cell.userLabel.frame.size.width, cell.userLabel.frame.size.height)];
    for(int x = 0; x < [currNote.contents count];x++){
        
        
        if([[(NoteContent *)[[currNote contents] objectAtIndex:x] getType] isEqualToString:kNoteContentTypeText]){
            //Dont show icon for text since it is assumed to always be there
        }
        else if ([[(NoteContent *)[[currNote contents] objectAtIndex:x] getType] isEqualToString:kNoteContentTypePhoto]){
            AsyncMediaImageView *aImageView = [[AsyncMediaImageView alloc]initWithFrame:CGRectMake(10, height, 300, 300) andMedia:[[[currNote contents] objectAtIndex:x] getMedia]];
            
            //if(!currNote.hasAudio)
            [aImageView setFrame:CGRectMake(10, height, 300, 450)];
            //else
            //[aImageView setFrame:CGRectMake(10, height+40, 300, 300)];
            
            [cell addSubview:aImageView];
        }
        else if([[(NoteContent *)[[currNote contents] objectAtIndex:x] getType] isEqualToString:kNoteContentTypeVideo] || [[(NoteContent *)[[currNote contents] objectAtIndex:x] getType] isEqualToString:kNoteContentTypeAudio]){
            NoteContent *content =  (NoteContent *)[[currNote contents] objectAtIndex:x];
            
            CGRect frame = CGRectMake(10, height, 300, 450);
            
            AsyncMediaPlayerButton *mediaButton;
            
            mediaButton = [asyncMediaDict objectForKey:content.getMedia.url];
            if(!mediaButton){
                
                mediaButton = [[AsyncMediaPlayerButton alloc]
                               initWithFrame:frame
                               media:content.getMedia
                               presentingController:self preloadNow:NO];
                
                //if(!currNote.hasAudio)
                [mediaButton setFrame:CGRectMake(10, height, 300, 450)];
                //else
                //  [mediaButton setFrame:CGRectMake(10, height+60, 300, 223)];
                [asyncMediaDict setObject:mediaButton forKey:content.getMedia.url];
                [cell addSubview:mediaButton];
                
            }
            else{
                [cell addSubview:mediaButton];
                
            }
        }
        /* else if([[(NoteContent *)[[currNote contents] objectAtIndex:x] getType] isEqualToString:kNoteContentTypeAudio]){
         
         CustomAudioPlayer *player = [[CustomAudioPlayer alloc]initWithFrame:CGRectMake(10, height, 300, 40) andMedia:[[[currNote contents] objectAtIndex:x] getMedia]];
         [player loadView];
         [cell addSubview:player];
         [player release];
         }*/
        
        /* if (![[[[currNote contents] objectAtIndex:x] getUploadState] isEqualToString:@"uploadStateDONE"]) {
         cell.titleLabel.text = @"Uploading Media";
         cell.userLabel.text = [AppModel sharedAppModel].userName;
         }*/
    }
    
    if(![AppModel sharedAppModel].currentGame.allowNoteLikes){
        cell.likesButton.enabled = NO;
        cell.likeLabel.hidden = YES;
        cell.likesButton.hidden = YES;
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
}

- (int) calculateTextHeight:(NSString *)text {
	CGRect frame = CGRectMake(0, 0, 235, 200000);
	CGSize calcSize = [text sizeWithFont:[UIFont systemFontOfSize:17]
					   constrainedToSize:frame.size lineBreakMode:UILineBreakModeWordWrap];
	frame.size = calcSize;
	frame.size.height += 0;
	//NSLog(@"Found height of %f", frame.size.height);
	return frame.size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Note *note = (Note *)[self.parentNote.comments objectAtIndex:(indexPath.row)];
    CGFloat textHeight = [self calculateTextHeight:[note title]] +35;
    NSLog(@"Height for Row:%d is %f",indexPath.row,textHeight);
    if (textHeight < 60)textHeight = 60;
    BOOL hasImage = NO;
    //BOOL hasAudio = NO;
    for(int i = 0; i < [[note contents] count];i++){
        if([[(NoteContent *)[[note contents]objectAtIndex:i]getType] isEqualToString:kNoteContentTypePhoto] || [[(NoteContent *)[[note contents]objectAtIndex:i]getType] isEqualToString:kNoteContentTypeVideo] || [[(NoteContent *)[[note contents]objectAtIndex:i]getType] isEqualToString:kNoteContentTypeAudio]){
            hasImage = YES;
        }
        /*else if([[(NoteContent *)[[note contents]objectAtIndex:i]getType] isEqualToString:kNoteContentTypeAudio]){
         hasAudio = YES;
         }*/
    }
    //[note setHasAudio:hasAudio];
    [note setHasImage:hasImage];
    if(hasImage) textHeight+=455;
    // if(hasAudio) textHeight += 40;
    
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
    self.textBox.text = @"";
    commentNote = [[Note alloc]init];
    
    self.commentNote.noteId = [[AppServices sharedAppServices]addCommentToNoteWithId:self.parentNote.noteId andTitle:@""];
    if(self.commentNote.noteId == 0){
        self.navigationItem.rightBarButtonItem = addCommentButton;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:.5];
        [self.textBox setFrame:CGRectMake(0, -215, 320, 215)];
        [self.inputView setFrame:CGRectMake(0, 416, 320, 52)];
        [UIView commitAnimations];
        
        [self.textBox resignFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"NoteCommentViewCreateFailedKey", @"") message:NSLocalizedString(@"NoteCommentViewCreateFailedMessageKey", @"") delegate:self.delegate cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
        [alert show];
    }
    
    [self.parentNote.comments insertObject:self.commentNote atIndex:0];
    if([AppModel sharedAppModel].isGameNoteList){
        [[AppModel sharedAppModel].gameNoteList setObject:self.parentNote forKey:[NSNumber numberWithInt:self.parentNote.noteId]];
        
    }
    else{
        [[AppModel sharedAppModel].playerNoteList setObject:self.parentNote forKey:[NSNumber numberWithInt:self.parentNote.noteId]];
    }
    self.addAudioButton.userInteractionEnabled = YES;
    self.addAudioButton.alpha = 1;
    self.addPhotoButton.userInteractionEnabled = YES;
    self.addPhotoButton.alpha = 1;
    self.addMediaFromAlbumButton.userInteractionEnabled = YES;
    self.addMediaFromAlbumButton.alpha = 1;
}

-(void)hideKeyboard{
    
    if([textBox.text length] == 0 || [textBox.text isEqualToString:@"Write Comment..."]){
        UIAlertView *alert;
        
        alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ErrorKey", @"")
                                           message: NSLocalizedString(@"PleaseAddCommentKey", @"")
                                          delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
        [alert show];
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
        commentNote.title = self.textBox.text;
        commentNote.parentNoteId = parentNote.noteId;
        commentNote.creatorId = [AppModel sharedAppModel].playerId;
        commentNote.username = [AppModel sharedAppModel].userName;
        
        //if([[[parentNote.comments objectAtIndex:0] contents]count]>0)
        [[AppServices sharedAppServices]updateCommentWithId:self.commentNote.noteId andTitle:self.textBox.text andRefresh:YES];
        // else
        //[[AppServices sharedAppServices]updateCommentWithId:self.commentNote.noteId andTitle:self.textBox.text andRefresh:NO];
        
        
        if(parentNote.comments.count > 0){
            if([[parentNote.comments objectAtIndex:0] noteId] == commentNote.noteId){
                [[parentNote.comments objectAtIndex:0] setTitle:self.textBox.text];
                [[parentNote.comments objectAtIndex:0] setParentNoteId:parentNote.noteId];
                [[parentNote.comments objectAtIndex:0] setCreatorId:[AppModel sharedAppModel].playerId];
                [[parentNote.comments objectAtIndex:0] setUsername:[AppModel sharedAppModel].userName];
            }
            else{
                [parentNote.comments insertObject:commentNote atIndex:0];
            }
        }
        else{
            [parentNote.comments insertObject:commentNote atIndex:0];
            
        }
        //self.parentNote = [[AppServices sharedAppServices]fetchNote:self.parentNote.noteId];
        [self.delegate setNote:parentNote];
        if([AppModel sharedAppModel].isGameNoteList){
            [[AppModel sharedAppModel].gameNoteList setObject:self.parentNote forKey:[NSNumber numberWithInt:self.parentNote.noteId]];
        }
        else{
            [[AppModel sharedAppModel].playerNoteList setObject:self.parentNote forKey:[NSNumber numberWithInt:self.parentNote.noteId]];
        }
        
        // [self addedText];
        self.commentValid = YES;
        [movieViews removeAllObjects];
        
        [self refreshViewFromModel];
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
    
    self.commentValid = YES;
    self.currNoteHasPhoto = YES;
    self.addPhotoButton.userInteractionEnabled = NO;
    self.addMediaFromAlbumButton.userInteractionEnabled = NO;
    self.addAudioButton.userInteractionEnabled = NO;
    
    self.addPhotoButton.alpha = .3;
    self.addMediaFromAlbumButton.alpha = .3;
    self.addAudioButton.alpha = .3;
}
-(void)addedAudio{
    
    self.commentValid = YES;
    self.currNoteHasAudio = YES;
    self.addPhotoButton.userInteractionEnabled = NO;
    self.addMediaFromAlbumButton.userInteractionEnabled = NO;
    self.addAudioButton.userInteractionEnabled = NO;
    
    self.addPhotoButton.alpha = .3;
    self.addMediaFromAlbumButton.alpha = .3;
    self.addAudioButton.alpha = .3;
    
    
}
-(void)addedVideo{
    
    self.commentValid = YES;
    self.currNoteHasVideo = YES;
    self.addPhotoButton.userInteractionEnabled = NO;
    self.addMediaFromAlbumButton.userInteractionEnabled = NO;
    self.addAudioButton.userInteractionEnabled = NO;
    
    self.addPhotoButton.alpha = .3;
    self.addMediaFromAlbumButton.alpha = .3;
    self.addAudioButton.alpha = .3;
    
    
}
-(void)addedText{
    
    self.commentValid = YES;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    // if(indexPath.row == 0) return UITableViewCellEditingStyleNone;
    if([[self.parentNote.comments objectAtIndex:(indexPath.row)] creatorId] == [AppModel sharedAppModel].playerId ||[self.parentNote creatorId] == [AppModel sharedAppModel].playerId){
        return UITableViewCellEditingStyleDelete;}
    else return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[self.parentNote.comments objectAtIndex:(indexPath.row)] creatorId] == [AppModel sharedAppModel].playerId ||[self.parentNote creatorId] == [AppModel sharedAppModel].playerId){
        [[AppServices sharedAppServices]deleteNoteWithNoteId:[[self.parentNote.comments objectAtIndex:(indexPath.row)] noteId]];
        [self.parentNote.comments removeObjectAtIndex:(indexPath.row)];
    }
}

- (void)tableView:(UITableView *)tableView

didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    //[movieViews removeAllObjects];
    [self.commentTable reloadData];
    
}

- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	NSLog(@"ItemDetailsViewController: movieFinishedCallback");
	[self dismissMoviePlayerViewControllerAnimated];
}
- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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

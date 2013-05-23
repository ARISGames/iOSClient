//
//  NoteCommentViewController.m
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteCommentViewController.h"
#import "AppServices.h"
#import "ARISAlertHandler.h"
#import "Note.h"
#import "NoteCommentCell.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "AsyncMediaPlayerButton.h"

@interface NoteCommentViewController() <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, CameraViewControllerDelegate, AudioRecorderViewControllerDelegate>
{
    Note *note;
    Note *comment;
    BOOL commentValid;
    
    UIView *inputView;
    UIBarButtonItem *hideKeyboardButton;
    UIBarButtonItem *addCommentButton;
    NSMutableDictionary *asyncMediaDict;
    
    IBOutlet UITableView *commentTable;
    IBOutlet UIButton *addPhotoButton;
    IBOutlet UIButton *addAudioButton;
    IBOutlet UIButton *addMediaFromAlbumButton;
    IBOutlet UITextView *textBox;
    
    id __unsafe_unretained delegate;
}

@property (nonatomic) Note *note;
@property (nonatomic) Note *comment;

@property (nonatomic) BOOL commentValid;

@property (nonatomic) UIView *inputView;
@property (nonatomic) UIBarButtonItem *hideKeyboardButton;
@property (nonatomic) UIBarButtonItem *addCommentButton;
@property (nonatomic) NSMutableDictionary *asyncMediaDict;

@property (nonatomic) IBOutlet UITableView *commentTable;
@property (nonatomic) IBOutlet UIButton *addPhotoButton;
@property (nonatomic) IBOutlet UIButton *addAudioButton;
@property (nonatomic) IBOutlet UIButton *addMediaFromAlbumButton;
@property (nonatomic) IBOutlet UITextView *textBox;

- (IBAction) addPhotoButtonTouchAction;
- (IBAction) addAudioButtonTouchAction;
- (IBAction) addMediaFromAlbumButtonTouchAction;

@end

@implementation NoteCommentViewController

@synthesize note;
@synthesize comment;
@synthesize commentValid;
@synthesize inputView;
@synthesize hideKeyboardButton;
@synthesize addCommentButton;
@synthesize asyncMediaDict;
@synthesize commentTable;
@synthesize addPhotoButton;
@synthesize addAudioButton;
@synthesize addMediaFromAlbumButton;
@synthesize textBox;

- (id) initWithNote:(Note *)n delegate:(id)d
{
    if(self = [super initWithNibName:@"NoteCommentViewController" bundle:nil])
    {
        delegate = d;
        self.note = n;
        
        asyncMediaDict = [[NSMutableDictionary alloc] initWithCapacity:5];
        self.title = NSLocalizedString(@"NoteCommentViewTitleKey", @"");
        self.hidesBottomBarWhenPushed = YES;
        commentValid = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNoteListReady" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
    }
    return self;
}

- (void)refreshViewFromModel
{
    [self addUploadsToComments];    
    [self.commentTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hideKeyboardButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveCommentKey", @"") style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];
    self.addCommentButton   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showKeyboard)];
    self.navigationItem.rightBarButtonItem = addCommentButton;
    [self.navigationItem.backBarButtonItem setAction:@selector(dismissSelf:)];
}

- (void) dismissSelf:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(self.textBox.frame.origin.y == 0)
        [self.textBox becomeFirstResponder];
    [self refreshViewFromModel];    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self refreshViewFromModel];
}

-(void)addUploadsToComments
{
    for(int i = 0; i < [self.note.comments count]; i++)
    {
        Note *currNote = [self.note.comments objectAtIndex:i];
        for(int x = [currNote.contents count]-1; x >= 0; x--)
        {
            if(![[[currNote.contents objectAtIndex:x] getUploadState] isEqualToString:@"uploadStateDONE"])
                [currNote.contents removeObjectAtIndex:x];
        }
        
        NSMutableDictionary *uploads = [AppModel sharedAppModel].uploadManager.uploadContentsForNotes;
        NSArray *uploadContentForNote = [[uploads objectForKey:[NSNumber numberWithInt:currNote.noteId]] allValues];
        [currNote.contents addObjectsFromArray:uploadContentForNote];
        NSLog(@"NoteEditorVC: Added %d upload content(s) to note",[uploadContentForNote count]);
    }
}

-(void)addPhotoButtonTouchAction
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        CameraViewController *cameraVC = [[CameraViewController alloc] initWithPresentMode:@"camera" delegate:self];
        [self.navigationController pushViewController:cameraVC animated:YES];
    }
}

-(void)addMediaFromAlbumButtonTouchAction
{
    CameraViewController *cameraVC = [[CameraViewController alloc] initWithPresentMode:@"library" delegate:self];
    [self.navigationController pushViewController:cameraVC animated:YES];
}

-(void)addAudioButtonTouchAction
{
    if([[AVAudioSession sharedInstance] inputIsAvailable])
    {
        AudioRecorderViewController *audioVC = [[AudioRecorderViewController alloc] initWithDelegate:self];
        [self.navigationController pushViewController:audioVC animated:YES];
    }    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.note.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *tempCell = (NoteCommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (tempCell && ![tempCell respondsToSelector:@selector(mediaIcon2)])
    {
        tempCell = nil;
    }
    NoteCommentCell *cell = (NoteCommentCell *)tempCell;
    if (cell == nil)
    {
        // Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"NoteCommentCell" bundle:nil];
        // Grab a pointer to the custom cell.
        cell = (NoteCommentCell *)temporaryController.view;
        // Release the temporary UIViewController.
    }
    
    Note *currComment = [self.note.comments objectAtIndex:(indexPath.row)];
    cell.note = currComment;
    [cell initCell];
    [cell checkForRetry];
    cell.userInteractionEnabled = YES;
    cell.titleLabel.contentInset = UIEdgeInsetsMake(0.0f,4.0f,0.0f,4.0f);
    cell.titleLabel.text = currComment.name;
    if(![currComment.displayname isEqualToString:@""])
        cell.userLabel.text = currComment.displayname;
    else
        cell.userLabel.text = currComment.username;
    CGFloat textHeight = [self calculateTextHeight:currComment.name] +35;
    if (textHeight < 30) textHeight = 30;
    [cell.userLabel setFrame:CGRectMake(cell.userLabel.frame.origin.x, textHeight+5, cell.userLabel.frame.size.width, cell.userLabel.frame.size.height)];
    
    for(int x = 0; x < [currComment.contents count]; x++)
    {
        if ([[(NoteContent *)[currComment.contents objectAtIndex:x] getType] isEqualToString:@"PHOTO"])
        {
            AsyncMediaImageView *aImageView = [[AsyncMediaImageView alloc]initWithFrame:CGRectMake(10, textHeight, 300, 300) andMedia:[[[currComment contents] objectAtIndex:x] getMedia]];
            [cell.userLabel setFrame:CGRectMake(cell.userLabel.frame.origin.x, cell.frame.origin.y+(textHeight+300)+5, cell.userLabel.frame.size.width, cell.userLabel.frame.size.height)];
            
            [cell addSubview:aImageView];
        }
        else if([[(NoteContent *)[currComment.contents objectAtIndex:x] getType] isEqualToString:@"VIDEO"] || [[(NoteContent *)[currComment.contents objectAtIndex:x] getType] isEqualToString:@"AUDIO"])
        {
            NoteContent *content = (NoteContent *)[[currComment contents] objectAtIndex:x];
            AsyncMediaPlayerButton *mediaButton = [asyncMediaDict objectForKey:content.getMedia.url];
            
            if(!mediaButton)
            {
                CGRect frame = CGRectMake(10, textHeight, 300, 450);
                mediaButton = [[AsyncMediaPlayerButton alloc]
                               initWithFrame:frame
                               media:content.getMedia
                               presentingController:[RootViewController sharedRootViewController] preloadNow:NO];
                [asyncMediaDict setObject:mediaButton forKey:content.getMedia.url];
            }
            [cell.userLabel setFrame:CGRectMake(cell.userLabel.frame.origin.x, cell.frame.origin.y+(textHeight+300)+5, cell.userLabel.frame.size.width, cell.userLabel.frame.size.height)];

            [cell addSubview:mediaButton];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) cell.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    else                        cell.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (int) calculateTextHeight:(NSString *)text
{
	CGSize calcSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(235-8, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
	return calcSize.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note *c = (Note *)[self.note.comments objectAtIndex:(indexPath.row)];
    CGFloat textHeight = [self calculateTextHeight:c.name] +35;
    if (textHeight < 30)textHeight = 30;
    BOOL hasImage = NO;
    for(int i = 0; i < [[c contents] count];i++)
    {
        if([[(NoteContent *)[c.contents objectAtIndex:i] getType] isEqualToString:@"PHOTO"] ||
           [[(NoteContent *)[c.contents objectAtIndex:i] getType] isEqualToString:@"VIDEO"] ||
           [[(NoteContent *)[c.contents objectAtIndex:i] getType] isEqualToString:@"AUDIO"])
        {
            hasImage = YES;
        }
    }
    [c setHasImage:hasImage];

    if(hasImage) textHeight+=300;
    textHeight += 21+5; // User Label
    
    return textHeight;
}

-(void)showKeyboard
{
    self.navigationItem.rightBarButtonItem = self.hideKeyboardButton;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:.5];
    [self.textBox setFrame:CGRectMake(0, 0, 320, 210)];
    [self.inputView setFrame:CGRectMake(0, 150, 320, 52)];
    [UIView commitAnimations];
    [self.textBox becomeFirstResponder];
    self.textBox.text = @"";
    self.comment = [[Note alloc] init];
    
    self.comment.noteId = [[AppServices sharedAppServices] addCommentToNoteWithId:self.note.noteId andTitle:@""];
    if(self.comment.noteId == 0){
        self.navigationItem.rightBarButtonItem = addCommentButton;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:.5];
        [self.textBox setFrame:CGRectMake(0, -215, 320, 215)];
        [self.inputView setFrame:CGRectMake(0, 416, 320, 52)];
        [UIView commitAnimations];
        
        [self.textBox resignFirstResponder];
        
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"NoteCommentViewCreateFailedKey", @"") message:NSLocalizedString(@"NoteCommentViewCreateFailedMessageKey", @"")];
    }
    
    [self.note.comments insertObject:self.comment atIndex:0];

    self.addAudioButton.userInteractionEnabled = YES;
    self.addAudioButton.alpha = 1;
    self.addPhotoButton.userInteractionEnabled = YES;
    self.addPhotoButton.alpha = 1;
    self.addMediaFromAlbumButton.userInteractionEnabled = YES;
    self.addMediaFromAlbumButton.alpha = 1;
}

- (void) hideKeyboard
{    
    if([textBox.text length] == 0 || [textBox.text isEqualToString:@"Write Comment..."])
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ErrorKey", @"") message:NSLocalizedString(@"PleaseAddCommentKey", @"")];
    else
    {
        self.navigationItem.rightBarButtonItem = addCommentButton;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:.5];
        [self.textBox   setFrame:CGRectMake(0, -215, 320, 215)];
        [self.inputView setFrame:CGRectMake(0,  416, 320, 52)];
        [UIView commitAnimations];
        
        [self.textBox resignFirstResponder];
        self.comment.name = self.textBox.text;
        self.comment.parentNoteId = self.note.noteId;
        self.comment.creatorId = [AppModel sharedAppModel].player.playerId;
        self.comment.username  = [AppModel sharedAppModel].player.username;
        
        [[AppServices sharedAppServices] updateCommentWithId:self.comment.noteId andTitle:self.textBox.text andRefresh:YES];
        
        if([self.note.comments count] > 0 && [[self.note.comments objectAtIndex:0] noteId] == self.comment.noteId)
        {
            [[self.note.comments objectAtIndex:0] setTitle:self.textBox.text];
            [[self.note.comments objectAtIndex:0] setParentNoteId:self.note.noteId];
            [[self.note.comments objectAtIndex:0] setCreatorId:[AppModel sharedAppModel].player.playerId];
            [[self.note.comments objectAtIndex:0] setUsername:[AppModel sharedAppModel].player.username];
        }
        else
            [self.note.comments insertObject:self.comment atIndex:0];
        
        self.commentValid = YES;
        
        [self refreshViewFromModel];
    }
}

- (void) imageChosenWithURL:(NSURL *)url
{
    [[[AppModel sharedAppModel] uploadManager]uploadContentForNoteId:self.note.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:@"PHOTO" withFileURL:url];
    self.commentValid = YES;
    self.addPhotoButton.userInteractionEnabled = NO;
    self.addMediaFromAlbumButton.userInteractionEnabled = NO;
    self.addAudioButton.userInteractionEnabled = NO;
    
    self.addPhotoButton.alpha = .3;
    self.addMediaFromAlbumButton.alpha = .3;
    self.addAudioButton.alpha = .3;
}

- (void) videoChosenWithURL:(NSURL *)url
{
    [[[AppModel sharedAppModel] uploadManager] uploadContentForNoteId:self.note.noteId withTitle:[NSString stringWithFormat:@"%@", [NSDate date]] withText:nil withType:@"VIDEO" withFileURL:url];
    self.commentValid = YES;
    self.addPhotoButton.userInteractionEnabled = NO;
    self.addMediaFromAlbumButton.userInteractionEnabled = NO;
    self.addAudioButton.userInteractionEnabled = NO;
    
    self.addPhotoButton.alpha = .3;
    self.addMediaFromAlbumButton.alpha = .3;
    self.addAudioButton.alpha = .3;
}

- (void) cameraViewControllerCancelled
{
    //do nothing
}

- (void) audioChosenWith:(NSURL *)url
{
    [[[AppModel sharedAppModel]uploadManager] uploadContentForNoteId:self.note.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:@"AUDIO" withFileURL:url];
    self.commentValid = YES;
    self.addPhotoButton.userInteractionEnabled = NO;
    self.addMediaFromAlbumButton.userInteractionEnabled = NO;
    self.addAudioButton.userInteractionEnabled = NO;
    
    self.addPhotoButton.alpha = .3;
    self.addMediaFromAlbumButton.alpha = .3;
    self.addAudioButton.alpha = .3;
}

- (void) audioRecorderViewControllerCancelled
{
    //do nothing
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.note.comments objectAtIndex:(indexPath.row)] creatorId] == [AppModel sharedAppModel].player.playerId ||
       [self.note creatorId] == [AppModel sharedAppModel].player.playerId)
        return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.note.comments objectAtIndex:(indexPath.row)] creatorId] == [AppModel sharedAppModel].player.playerId ||
       [self.note creatorId] == [AppModel sharedAppModel].player.playerId)
    {
        [[AppServices sharedAppServices] deleteNoteWithNoteId:[[self.note.comments objectAtIndex:(indexPath.row)] noteId]];
        [self.note.comments removeObjectAtIndex:(indexPath.row)];
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.commentTable reloadData];
}

- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end

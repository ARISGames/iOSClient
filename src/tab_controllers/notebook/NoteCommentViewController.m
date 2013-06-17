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
    
    UIView *inputView;
    UIBarButtonItem *hideKeyboardButton;
    UIBarButtonItem *addCommentButton;
    
    IBOutlet UITableView *commentTable;
    IBOutlet UIButton *addPhotoButton;
    IBOutlet UIButton *addAudioButton;
    IBOutlet UIButton *addMediaFromAlbumButton;
    IBOutlet UITextView *textBox;
    
    id __unsafe_unretained delegate;
}

@property (nonatomic) Note *note;
@property (nonatomic) Note *comment;

@property (nonatomic) UIView *inputView;
@property (nonatomic) UIBarButtonItem *hideKeyboardButton;
@property (nonatomic) UIBarButtonItem *addCommentButton;

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
@synthesize inputView;
@synthesize hideKeyboardButton;
@synthesize addCommentButton;
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
        
        self.title = NSLocalizedString(@"NoteCommentViewTitleKey", @"");

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewNoteListReady"                        object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.hideKeyboardButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveCommentKey", @"") style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];
    self.addCommentButton   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showKeyboard)];
    self.navigationItem.rightBarButtonItem = addCommentButton;
    [self.navigationItem.backBarButtonItem setAction:@selector(dismissSelf:)];
}

- (void) viewDidAppear:(BOOL)animated
{
    if(self.textBox.frame.origin.y == 0)
        [self.textBox becomeFirstResponder];
    [self refreshViewFromModel];
}

- (void) refreshViewFromModel
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
    }
    
    [self.commentTable reloadData];
}

- (void) dismissSelf:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) addPhotoButtonTouchAction
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [self.navigationController pushViewController:[[CameraViewController alloc] initWithPresentMode:@"camera" delegate:self] animated:YES];
}

- (void) addMediaFromAlbumButtonTouchAction
{
    [self.navigationController pushViewController:[[CameraViewController alloc] initWithPresentMode:@"library" delegate:self] animated:YES];
}

- (void) addAudioButtonTouchAction
{
    if([[AVAudioSession sharedInstance] inputIsAvailable])
        [self.navigationController pushViewController:[[AudioRecorderViewController alloc] initWithDelegate:self] animated:YES];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.note.comments count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NoteCommentCell *cell = (NoteCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell || ![cell respondsToSelector:@selector(mediaIcon2)])
    {
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"NoteCommentCell" bundle:nil];
        cell = (NoteCommentCell *)temporaryController.view;
    }
        
    [cell initWithNote:[self.note.comments objectAtIndex:(indexPath.row)]];
    [cell checkForRetry];
    cell.userInteractionEnabled = YES;
    
    CGFloat textHeight = [self calculateCellHeightWithText:cell.note.name];
    [cell.userLabel setFrame:CGRectMake(cell.userLabel.frame.origin.x, textHeight+5, cell.userLabel.frame.size.width, cell.userLabel.frame.size.height)];
    
    for(int x = 0; x < [cell.note.contents count]; x++)
    {
        if([[(NoteContent *)[cell.note.contents objectAtIndex:x] getType] isEqualToString:@"PHOTO"])
        {
            [cell.userLabel setFrame:CGRectMake(cell.userLabel.frame.origin.x, cell.frame.origin.y+(textHeight+300)+5, cell.userLabel.frame.size.width, cell.userLabel.frame.size.height)];
            [cell addSubview:[[AsyncMediaImageView alloc] initWithFrame:CGRectMake(10, textHeight, 300, 300) andMedia:[[[cell.note contents] objectAtIndex:x] getMedia]]];
        }
        else if([[(NoteContent *)[cell.note.contents objectAtIndex:x] getType] isEqualToString:@"VIDEO"] ||
                [[(NoteContent *)[cell.note.contents objectAtIndex:x] getType] isEqualToString:@"AUDIO"])
        {
            NoteContent *content = (NoteContent *)[[cell.note contents] objectAtIndex:x];
            
            CGRect frame = CGRectMake(10, textHeight, 300, 450);
            AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:frame
                                                                                          media:content.getMedia
                                                                                      presenter:[RootViewController sharedRootViewController]
                                                                                     preloadNow:NO];

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

    if (indexPath.row % 2 == 0) cell.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    else                        cell.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note *n = (Note *)[self.note.comments objectAtIndex:(indexPath.row)];
    int textHeight = [self calculateCellHeightWithText:n.name];
    for(int i = 0; i < [[n contents] count];i++)
    {
        if([[(NoteContent *)[n.contents objectAtIndex:i] getType] isEqualToString:@"PHOTO"] ||
           [[(NoteContent *)[n.contents objectAtIndex:i] getType] isEqualToString:@"VIDEO"] ||
           [[(NoteContent *)[n.contents objectAtIndex:i] getType] isEqualToString:@"AUDIO"])
        {
            textHeight+=300;
        }
    }
    textHeight += 26; // User Label
    
    return textHeight;
}

- (void) showKeyboard
{
    self.navigationItem.rightBarButtonItem = self.hideKeyboardButton;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:.5];
    [self.textBox   setFrame:CGRectMake(0, 0, 320, self.textBox.superview.frame.size.height-216)];
    [self.inputView setFrame:CGRectMake(0, self.textBox.superview.frame.size.height-268, 320, 52)];
    [UIView commitAnimations];
    
    [self.textBox becomeFirstResponder];
    self.textBox.text = @"";
    self.comment = [[Note alloc] init];
    
    self.comment.noteId = [[AppServices sharedAppServices] addCommentToNoteWithId:self.note.noteId andTitle:@""];
    if(self.comment.noteId == 0)
    {
        self.navigationItem.rightBarButtonItem = addCommentButton;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:.5];
        [self.textBox   setFrame:CGRectMake(0, -216, 320, 216)];
        [self.inputView setFrame:CGRectMake(0, self.textBox.superview.frame.size.height, 320, 52)];
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
        [self.textBox   setFrame:CGRectMake(0, -216, 320, 216)];
        [self.inputView setFrame:CGRectMake(0, self.textBox.superview.frame.size.height, 320, 52)];
        [UIView commitAnimations];
        
        [self.textBox resignFirstResponder];
        self.comment.name = self.textBox.text;
        self.comment.parentNoteId = self.note.noteId;
        self.comment.creatorId = [AppModel sharedAppModel].player.playerId;
        self.comment.username  = [AppModel sharedAppModel].player.username;
        
        [[AppServices sharedAppServices] updateCommentWithId:self.comment.noteId andTitle:self.textBox.text andRefresh:YES];
        
        if([self.note.comments count] > 0 && [[self.note.comments objectAtIndex:0] noteId] == self.comment.noteId)
        {
            ((Note *)[self.note.comments objectAtIndex:0]).name         = self.textBox.text;
            ((Note *)[self.note.comments objectAtIndex:0]).parentNoteId = self.note.noteId;
            ((Note *)[self.note.comments objectAtIndex:0]).creatorId    = [AppModel sharedAppModel].player.playerId;
            ((Note *)[self.note.comments objectAtIndex:0]).username     = [AppModel sharedAppModel].player.username;
        }
        else
            [self.note.comments insertObject:self.comment atIndex:0];
                
        [self refreshViewFromModel];
    }
}

- (void) imageChosenWithURL:(NSURL *)url
{
    [[[AppModel sharedAppModel] uploadManager]uploadContentForNoteId:self.note.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:@"PHOTO" withFileURL:url];
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

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.note.comments objectAtIndex:(indexPath.row)] creatorId] == [AppModel sharedAppModel].player.playerId ||
       [self.note creatorId] == [AppModel sharedAppModel].player.playerId)
        return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[self.note.comments objectAtIndex:(indexPath.row)] creatorId] == [AppModel sharedAppModel].player.playerId ||
       [self.note creatorId] == [AppModel sharedAppModel].player.playerId)
    {
        [[AppServices sharedAppServices] deleteNoteWithNoteId:[[self.note.comments objectAtIndex:(indexPath.row)] noteId]];
        [self.note.comments removeObjectAtIndex:(indexPath.row)];
    }
}

- (void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.commentTable reloadData];
}

- (int) calculateCellHeightWithText:(NSString *)s
{
	CGSize calcSize = [s sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(235-8, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
	return calcSize.height+35;
}

- (void) movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}

- (void) dealloc
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

//
//  NoteEditorViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteEditorViewController.h"
#import "StateControllerProtocol.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "AppModel.h"
#import "ARISAlertHandler.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "TextViewController.h"
#import "AsyncMediaImageView.h"
#import "Media.h"
#import "ImageViewer.h"
#import "ARISMoviePlayerViewController.h"
#import "DropOnMapViewController.h"
#import "NoteCommentViewController.h"
#import "NoteDetailsViewController.h"
#import "NoteContentCell.h"
#import "NoteContentProtocol.h"
#import "TagViewController.h"
#import "ARISAppDelegate.h"

@interface NoteEditorViewController() <AVAudioSessionDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, UIActionSheetDelegate, CameraViewControllerDelegate, AudioRecorderViewControllerDelegate, TextViewControllerDelegate, NoteContentCellDelegate>
{
    IBOutlet UITextField *textField;
    IBOutlet UIButton *cameraButton;
    IBOutlet UIButton *audioButton;
    IBOutlet UIButton *libraryButton;
    IBOutlet UIButton *mapButton;
    IBOutlet UIButton *publicButton;
    IBOutlet UIButton *textButton;
    IBOutlet UITableView *contentTable;
    IBOutlet UILabel *sharingLabel;
    UIActionSheet *actionSheet;

    Note *note;
    id __unsafe_unretained delegate;
    BOOL noteValid;
    BOOL noteChanged;
    NSString *startingView;
}

@property (nonatomic, strong) Note *note;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) IBOutlet UILabel *sharingLabel;
@property (nonatomic, strong) IBOutlet UITableView *contentTable;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) IBOutlet UIButton *audioButton;
@property (nonatomic, strong) IBOutlet UIButton *publicButton;
@property (nonatomic, strong) IBOutlet UIButton *textButton;
@property (nonatomic, strong) IBOutlet UIButton *mapButton;
@property (nonatomic, strong) IBOutlet UIButton *libraryButton;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (readwrite, strong) NSString *startingView;
@property (readwrite, assign) BOOL noteValid;
@property (readwrite, assign) BOOL noteChanged;

- (void) updateTable;
- (void) refreshViewFromModel;
- (void) tagButtonTouchAction;
- (void) addCDUploadsToNote;

- (IBAction) cameraButtonTouchAction;
- (IBAction) audioButtonTouchAction;
- (IBAction) libraryButtonTouchAction;
- (IBAction) mapButtonTouchAction;
- (IBAction) publicButtonTouchAction;
- (IBAction) textButtonTouchAction;

@end

@implementation NoteEditorViewController

@synthesize note;
@synthesize actionSheet;
@synthesize sharingLabel;

@synthesize contentTable;
@synthesize cameraButton;
@synthesize audioButton;
@synthesize publicButton;
@synthesize textButton;
@synthesize mapButton;
@synthesize libraryButton;
@synthesize textField;
@synthesize noteValid;
@synthesize noteChanged;
@synthesize startingView;

- (id) initWithNote:(Note *)n inView:(NSString *)view delegate:(id)d
{
    if(self = [super initWithNibName:@"NoteEditorViewController" bundle:nil])
    {
        delegate = d;
        self.note = n;
        self.startingView = view;
        self.noteValid = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewNoteListReady"                        object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        self.hidesBottomBarWhenPushed = YES;
        
        [[AVAudioSession sharedInstance] setDelegate:self];
        
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SharingKey", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CancelKey", @"")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"NoteEditorListOnlyKey", @""),
                                                                NSLocalizedString(@"NoteEditorMapOnlyKey", @""),
                                                                NSLocalizedString(@"BothKey", @""),
                                                                NSLocalizedString(@"DontShareKey", @""),
                                                                nil];
        
        if(!self.note)
        {
            self.note = [[Note alloc] init];
            self.note.creatorId = [AppModel sharedAppModel].player.playerId;
            self.note.username  = [AppModel sharedAppModel].player.username;
            self.note.noteId    = [[AppServices sharedAppServices] createNoteStartIncomplete];
            if(self.note.noteId != 0)
                [[AppModel sharedAppModel].playerNoteList setObject:self.note forKey:[NSNumber numberWithInt:self.note.noteId]];
            else
            {
                [self dismissSelf];
                [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"NoteEditorCreateNoteFailedKey", @"") message:NSLocalizedString(@"NoteEditorCreateNoteFailedMessageKey", @"")];
            }
        }
        else self.noteValid = YES;
    }
    return self;
}

- (void) dealloc
{
    [[AVAudioSession sharedInstance] setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated
{    
    if(!self.startingView)
    {        
        if(self.note.dropped) self.mapButton.selected = YES;   
        else                  self.mapButton.selected = NO;
        
        if     (!self.note.showOnMap && !self.note.showOnList) self.sharingLabel.text = NSLocalizedString(@"NoneKey", @"");
        else if( self.note.showOnMap && !self.note.showOnList) self.sharingLabel.text = NSLocalizedString(@"NoteEditorMapOnlyKey", @"");
        else if(!self.note.showOnMap &&  self.note.showOnList) self.sharingLabel.text = NSLocalizedString(@"NoteEditorListOnlyKey", @"");
        else if( self.note.showOnMap &&  self.note.showOnList) self.sharingLabel.text = NSLocalizedString(@"NoteEditorListAndMapKey", @"");
        
        if(self.noteChanged)
        {
            self.noteChanged = NO;
            [contentTable reloadData];
        }
        
        [self refreshViewFromModel];
        
        self.textField.text = self.note.name;
        if([self.note.name isEqualToString:NSLocalizedString(@"NodeEditorNewNoteKey", @"")])
        {
            self.textField.text = @"";
            [self.textField becomeFirstResponder];
        }
    }
    else if([self.startingView isEqualToString:@"camera"]) [self cameraButtonTouchAction];
    else if([self.startingView isEqualToString:@"text"])   [self textButtonTouchAction];
    else if([self.startingView isEqualToString:@"audio"])  [self audioButtonTouchAction];
    self.startingView = nil;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DoneKey", @"") style:UIBarButtonItemStyleDone     target:self action:@selector(backButtonTouchAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"16-tag"]     style:UIBarButtonItemStyleBordered target:self action:@selector(tagButtonTouchAction)];
        
    if([delegate isKindOfClass:[NoteCommentViewController class]])
    {
        self.publicButton.hidden = YES;
        self.mapButton.hidden    = YES;
        self.textButton.frame    = CGRectMake(    self.textButton.frame.origin.x,    self.textButton.frame.origin.y,    self.textButton.frame.size.width*1.5,    self.textButton.frame.size.height);
        self.libraryButton.frame = CGRectMake( self.libraryButton.frame.origin.x, self.libraryButton.frame.origin.y, self.libraryButton.frame.size.width*1.5, self.libraryButton.frame.size.height);
        self.audioButton.frame   = CGRectMake(self.textButton.frame.size.width-2,   self.audioButton.frame.origin.y,   self.audioButton.frame.size.width*1.5,   self.audioButton.frame.size.height);
        self.cameraButton.frame  = CGRectMake(self.textButton.frame.size.width-2,  self.cameraButton.frame.origin.y,  self.cameraButton.frame.size.width*1.5,  self.cameraButton.frame.size.height);
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    if(!self.note) return;

    self.startingView = nil;
    self.note.name = self.textField.text;
    if([note.name isEqualToString:@""]) note.name = NSLocalizedString(@"NodeEditorNewNoteKey", @"");
    [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:self.textField.text publicToMap:self.note.showOnMap publicToList:self.note.showOnList];
}

-(void) tagButtonTouchAction
{
    TagViewController *tagView = [[TagViewController alloc] initWithNote:self.note];
    [self.navigationController pushViewController:tagView animated:YES];
}

- (IBAction) backButtonTouchAction:(id)sender
{
    if([self.textField.text isEqualToString:@""]) self.textField.text = NSLocalizedString(@"NodeEditorNewNoteKey", @"");
    [[AppServices sharedAppServices] setNoteCompleteForNoteId:self.note.noteId];
    [self dismissSelf];
}

- (void) dismissSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateTable
{
    [contentTable reloadData];
}

-(void)cameraButtonTouchAction
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        CameraViewController *cameraVC = [[CameraViewController alloc] initWithPresentMode:@"camera" delegate:self];
        [self.navigationController pushViewController:cameraVC animated:NO];
    }
}

-(void)libraryButtonTouchAction
{
    CameraViewController *cameraVC = [[CameraViewController alloc] initWithPresentMode:@"library" delegate:self];
    [self.navigationController pushViewController:cameraVC animated:NO];
}

- (void) imageChosenWithURL:(NSURL *)url
{
    [[[AppModel sharedAppModel] uploadManager] uploadContentForNoteId:self.note.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:@"PHOTO" withFileURL:url];
    self.noteValid   = YES;
    self.noteChanged = YES;
    [self refreshViewFromModel];
}

- (void) videoChosenWithURL:(NSURL *)url
{
    [[[AppModel sharedAppModel] uploadManager] uploadContentForNoteId:self.note.noteId withTitle:[NSString stringWithFormat:@"%@", [NSDate date]] withText:nil withType:@"VIDEO" withFileURL:url];
    self.noteValid   = YES;
    self.noteChanged = YES;
    [self refreshViewFromModel];
}

- (void) cameraViewControllerCancelled
{
    if(!self.noteValid)
    {
        [[AppServices sharedAppServices] deleteNoteWithNoteId:self.note.noteId];
        [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:self.note.noteId]];
        [self dismissSelf];
    }
}

- (void) audioButtonTouchAction
{
    if([[AVAudioSession sharedInstance] inputIsAvailable])
    {
        AudioRecorderViewController *audioVC = [[AudioRecorderViewController alloc] initWithDelegate:self];
        [self.navigationController pushViewController:audioVC animated:NO];
    }
}

- (void) audioChosenWith:(NSURL *)url
{
    [[[AppModel sharedAppModel]uploadManager] uploadContentForNoteId:self.note.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:@"AUDIO" withFileURL:url];
    self.noteValid   = YES;
    self.noteChanged = YES;
    [self refreshViewFromModel];
}

- (void) audioRecorderViewControllerCancelled
{
    if(!self.noteValid)
    {
        [[AppServices sharedAppServices]deleteNoteWithNoteId:self.note.noteId];
        [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:self.note.noteId]];
        [self dismissSelf];
    }
}

-(void)textButtonTouchAction
{
    TextViewController *textVC = [[TextViewController alloc] initWithNote:self.note content:nil inMode:@"edit" delegate:self];
    [self.navigationController pushViewController:textVC animated:NO];
}

- (void) textUpdated:(NSString *)s forContent:(NoteContent *)c
{
    c.text = s;
    [[AppServices sharedAppServices] updateNoteContent:c.contentId text:s];
}

- (void) textChosen:(NSString *)s
{
    [[[AppModel sharedAppModel] uploadManager] uploadContentForNoteId:self.note.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:s withType:@"TEXT" withFileURL:[NSURL URLWithString:[NSString stringWithFormat:@"%d.txt",((NSString *)[NSString stringWithFormat:@"%@.txt",[NSDate date]]).hash]]];
    
    self.noteValid   = YES;
    self.noteChanged = YES;
}

- (void) textViewControllerCancelled
{
    if(!self.noteValid)
    {
        [[AppServices sharedAppServices] deleteNoteWithNoteId:self.note.noteId];
        [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:self.note.noteId]];
        [self dismissSelf];
    }
}

- (void) mapButtonTouchAction
{
    DropOnMapViewController *mapVC = [[DropOnMapViewController alloc] initWithNibName:@"DropOnMapViewController" bundle:nil] ;
    mapVC.noteId = self.note.noteId;
    mapVC.delegate = self;
    self.noteValid = YES;
    self.mapButton.selected = YES;
    
    [self.navigationController pushViewController:mapVC animated:NO];
}

- (void) publicButtonTouchAction
{
    self.noteValid = YES;
    [actionSheet showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
            if([AppModel sharedAppModel].currentGame.allowShareNoteToList)
            {
                self.note.showOnList = YES;
                self.note.showOnMap = NO;
                self.sharingLabel.text = NSLocalizedString(@"NoteEditorListOnlyKey", @""); 
            }
            else
                [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"NoteEditorNotAllowedKey", @"") message:NSLocalizedString(@"NoteEditorNotAllowedSharingToListsMessageKey", @"")];
            break;
        case 1:
        {
            if([AppModel sharedAppModel].currentGame.allowShareNoteToMap){
                self.note.showOnList = NO;
                self.note.showOnMap = YES;
                self.sharingLabel.text = NSLocalizedString(@"NoteEditorMapOnlyKey", @""); 
                if(!self.note.dropped){
                    [[AppServices sharedAppServices] dropNote:self.note.noteId atCoordinate:[AppModel sharedAppModel].player.location.coordinate];
                    self.note.dropped = YES;
                    self.mapButton.selected = YES;
                }
            }
            else
                [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"NoteEditorNotAllowedKey", @"") message:NSLocalizedString(@"NoteEditorNotAllowedSharingToMapMessageKey", @"")];
            break;
        }
        case 2:{
            if([AppModel sharedAppModel].currentGame.allowShareNoteToMap && ([AppModel sharedAppModel].currentGame.allowShareNoteToList)){
                self.note.showOnList = YES;
                self.note.showOnMap = YES;
                self.sharingLabel.text = NSLocalizedString(@"NoteEditorListAndMapKey", @""); 
                if(!self.note.dropped)
                {
                        [[AppServices sharedAppServices] dropNote:self.note.noteId atCoordinate:[AppModel sharedAppModel].player.location.coordinate];
                        self.note.dropped = YES;
                        self.mapButton.selected = YES;
                }
            }
            else
                [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"NoteEditorNotAllowedKey", @"") message:NSLocalizedString(@"NoteEditorNotAllowedOneOrMoreMessageKey", @"")];                
            break;
        }
        case 3:
            self.note.showOnList = NO;
            self.note.showOnMap = NO;
            self.sharingLabel.text = NSLocalizedString(@"NoneKey", @"");
            break;
        default:
            break;
    }
    [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:self.textField.text publicToMap:self.note.showOnMap publicToList:self.note.showOnList];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.note.contents count] == 0 && indexPath.row == 0)
        return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[[self.note.contents objectAtIndex:indexPath.row] getUploadState] isEqualToString:@"uploadStateDONE"])
        [[AppServices sharedAppServices] deleteNoteContentWithContentId:[[self.note.contents objectAtIndex:indexPath.row] getContentId]];
    else
        [[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:self.note.noteId andFileURL:[NSURL URLWithString:[[[self.note.contents objectAtIndex:indexPath.row]getMedia] url]]];
    [self.note.contents removeObjectAtIndex:indexPath.row];
}

-(void)removeLoadingIndicator
{
    [[self navigationItem] setRightBarButtonItem:nil];
    [contentTable reloadData];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [contentTable reloadData];
}

- (void)refreshViewFromModel
{
    self.note = [[[AppModel sharedAppModel] playerNoteList] objectForKey:[NSNumber numberWithInt:self.note.noteId]];
    [self addCDUploadsToNote];
    [contentTable reloadData];
}

-(void)addCDUploadsToNote
{
    for(int x = [self.note.contents count]-1; x >= 0; x--)
    {
        //Removes note contents that are not done uploading, because they will all be added again right after this loop
        if((id<NoteContentProtocol>)[[self.note.contents objectAtIndex:x] managedObjectContext] == nil ||
           ![[[self.note.contents objectAtIndex:x] getUploadState] isEqualToString:@"uploadStateDONE"])
            [self.note.contents removeObjectAtIndex:x];
    }
    
    NSArray *uploadContentsForNote = [[[AppModel sharedAppModel].uploadManager.uploadContentsForNotes objectForKey:[NSNumber numberWithInt:self.note.noteId]]allValues];
    [self.note.contents addObjectsFromArray:uploadContentsForNote];
    NSLog(@"NoteEditorVC: Added %d upload content(s) to note",[uploadContentsForNote count]);
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.note.contents count] == 0) return 1;
	return [self.note.contents count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	static NSString *CellIdentifier = @"Cell";
    
    if([self.note.contents count] == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.text = NSLocalizedString(@"NoteEditorNoContentAddedKey", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"NoteEditorPressButtonsKey", @"");
        cell.userInteractionEnabled = NO;
        return  cell;
    }
    
    NoteContentCell *cell;
    UITableViewCell *tempCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!tempCell || ![tempCell respondsToSelector:@selector(titleLbl)])
        cell = (NoteContentCell *)[[[NSBundle mainBundle] loadNibNamed:@"NoteContentCell" owner:self options:nil] objectAtIndex:0];
    else
        cell = (NoteContentCell *)tempCell;

    [cell setupWithNoteContent:[self.note.contents objectAtIndex:indexPath.row] delegate:self];

    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if(indexPath.row % 2 == 0) cell.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    else                       cell.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteContent *noteC;
    
    if([self.note.contents count] > indexPath.row)
    {
        noteC = [self.note.contents objectAtIndex:indexPath.row];
        if ([noteC.getType isEqualToString:@"TEXT"])
        {
            TextViewController *textVC = [[TextViewController alloc] initWithNote:self.note content:noteC inMode:@"edit" delegate:self];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.5];
            
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
            [self.navigationController pushViewController:textVC animated:NO];
            [UIView commitAnimations];
        }
        else if([noteC.getType isEqualToString:@"PHOTO"])
        {
            ImageViewer *controller = [[ImageViewer alloc] initWithNibName:@"ImageViewer" bundle:nil];
            controller.media = noteC.getMedia;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.5];
            
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                                   forView:self.navigationController.view cache:YES];
            [self.navigationController pushViewController:controller
                                                 animated:NO];
            [UIView commitAnimations];
        }
        else if([noteC.getType isEqualToString:@"VIDEO"] || [noteC.getType isEqualToString:@"AUDIO"])
        {
            ARISMoviePlayerViewController *mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:noteC.getMedia.url]];
            mMoviePlayer.moviePlayer.shouldAutoplay = YES;
            [self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
        }
    }
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void) cellStartedEditing:(NoteContentCell *)c
{
    [self.contentTable setFrame:CGRectMake(self.contentTable.frame.origin.x, self.contentTable.frame.origin.y, self.contentTable.frame.size.width, 160)];
}

- (void) cellFinishedEditing:(NoteContentCell *)c
{
    [self.contentTable setFrame:CGRectMake(self.contentTable.frame.origin.x, self.contentTable.frame.origin.y, self.contentTable.frame.size.width, 261)];
}

- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
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

//
//  NoteEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "NoteEditorViewController.h"
#import "NoteTagEditorViewController.h"
#import "NoteCameraViewController.h"
#import "NoteRecorderViewController.h"
#import "NoteLocationPickerController.h"
#import "ARISMediaView.h"
#import "Note.h"
#import "AppModel.h"
#import "User.h"
#import "CircleButton.h"

@interface NoteEditorViewController () <UITextFieldDelegate, UITextViewDelegate, NoteTagEditorViewControllerDelegate, ARISMediaViewDelegate, NoteCameraViewControllerDelegate, NoteRecorderViewControllerDelegate, NoteLocationPickerControllerDelegate, UIActionSheetDelegate>
{
    Note *note;
    Tag *tag;
    Media *media;
    Trigger *trigger;

    NoteTagEditorViewController *tagViewController;
    NoteLocationPickerController *locationPickerController;

    UITextView *description;
    UILabel *descriptionPrompt;
    ARISMediaView *contentView;

    UIView *line1;
    UIView *line2;

    UIButton *deleteButton;
    UIButton *descriptionDoneButton;
    UIButton *saveNoteButton;
    UIButton *backButton;

    UIActionSheet *confirmPrompt;
    UIActionSheet *deletePrompt;
    UIActionSheet *discardChangesPrompt;

    NoteEditorMode mode;

    BOOL blockKeyboard;
    BOOL dirtybit;

    id<NoteEditorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteEditorViewController

- (id) initWithNote:(Note *)n mode:(NoteEditorMode)m delegate:(id<NoteEditorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        dirtybit = NO;
        if(!n)
        {
            n = [[Note alloc] init];
            n.created = [NSDate date];
            n.user_id = _MODEL_PLAYER_.user_id;
            dirtybit = YES;
        }
        note = n;
        mode = m;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    // NOTE some hacky solutions to moving down the top
    // self.edgesForExtendedLayout = UIRectEdgeNone;
    // self.navigationController.navigationBar.translucent = NO;

    description = [[UITextView alloc] init];
    description.delegate = self;
    description.contentInset = UIEdgeInsetsZero;
    description.font = [ARISTemplate ARISBodyFont];

    if(note.note_id && !tag && [_MODEL_TAGS_ tagsForObjectType:@"NOTE" id:note.note_id].count) tag = [_MODEL_TAGS_ tagsForObjectType:@"NOTE" id:note.note_id][0];
    tagViewController = [[NoteTagEditorViewController alloc] initWithTag:tag editable:YES delegate:self];

    descriptionPrompt = [[UILabel alloc] init];
    descriptionPrompt.text = NSLocalizedString(@"NoteEditorDescriptionKey", @"");
    descriptionPrompt.font = [ARISTemplate ARISBodyFont];
    descriptionPrompt.textColor = [UIColor ARISColorLightGray];

    descriptionDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [descriptionDoneButton setImage:[UIImage imageNamed:@"overarrow.png"] forState:UIControlStateNormal];
    [descriptionDoneButton sizeToFit];
    [descriptionDoneButton addTarget:self action:@selector(doneButtonTouched) forControlEvents:UIControlEventTouchUpInside];

    saveNoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveNoteButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [saveNoteButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
    saveNoteButton.titleLabel.font = [ARISTemplate ARISCellBoldTitleFont];
    [saveNoteButton sizeToFit];
    [saveNoteButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];

    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setAccessibilityLabel: @"Back Button"];
    [backButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];

    confirmPrompt = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"NoteEditorTitleNoteKey", @"") destructiveButtonTitle:NSLocalizedString(@"NoteEditorSaveUntitledKey", @"") otherButtonTitles:nil];
    deletePrompt = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") destructiveButtonTitle:NSLocalizedString(@"DeleteKey", @"") otherButtonTitles:nil];
    discardChangesPrompt = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"NoteEditorContinueEditingKey", @"") destructiveButtonTitle:NSLocalizedString(@"DiscardKey", @"") otherButtonTitles:nil];

    [self setLocationOnMap];

    contentView = [[ARISMediaView alloc] initWithDelegate:self];
    [contentView setDisplayMode:ARISMediaDisplayModeAspectFill];
    contentView.clipsToBounds = YES;

    line1 = [[UIView alloc] init];
    line1.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    line2 = [[UIView alloc] init];
    line2.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];

    //trashLabel.text = [NSString stringWithFormat:@"%@\n%@", [NSLocalizedString(@"DeleteKey", @"") uppercaseString], [NSLocalizedString(@"NoteKey", @"") uppercaseString]];

    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:NSLocalizedString(@"DeleteKey", nil) forState:UIControlStateNormal];
    [deleteButton setBackgroundColor:[UIColor ARISColorRed]];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [ARISTemplate ARISButtonFont];
    [deleteButton addTarget:self action:@selector(trashButtonTouched) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:description];
    [self.view addSubview:descriptionPrompt];
    [self.view addSubview:contentView];
    [self.view addSubview:deleteButton];

    // FIXME convert to view later
    [self.view addSubview:locationPickerController.view];

    [self.view addSubview:line1];
    [self.view addSubview:line2];

    if([_MODEL_TAGS_ tags].count)
    {
      [self.view addSubview:tagViewController.view];
    }

    [self refreshViewFromNote];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    //order of sizing not top to bottom- calculate edge views to derive sizes of middle views

    contentView.frame = CGRectMake(0, 64, self.view.bounds.size.width/4, self.view.bounds.size.width/4);
    if(media) {
      [contentView setMedia:media];
    }
    else if(note.media_id == 0)
    {
      [contentView setImage:[UIImage imageNamed:@"notebooktext.png"]];
    }

    if([_MODEL_TAGS_ tags].count > 0)
    {
        [tagViewController setExpandHeight:250];
        if(tagViewController.view.frame.size.height <= 35)
            // TODO make relative to media coordinates
            tagViewController.view.frame = CGRectMake(
                self.view.bounds.size.width/4,
                CGRectGetMaxY(contentView.frame)-35,
                self.view.bounds.size.width-self.view.bounds.size.width/4,
                35
            );
        else
            tagViewController.view.frame = CGRectMake(
                self.view.bounds.size.width/4,
                CGRectGetMaxY(contentView.frame)-35,
                self.view.bounds.size.width-self.view.bounds.size.width/4,
                250
            );

    }

    line2.frame = CGRectMake(0, CGRectGetMaxY(description.frame), self.view.frame.size.width, 1);
    line1.frame = CGRectMake(0, CGRectGetMaxY(contentView.frame), self.view.frame.size.width, 1);

    if([_MODEL_TAGS_ tags].count > 0)
    {
        description.frame = CGRectMake(
            CGRectGetMinX(contentView.frame),
            CGRectGetMaxY(contentView.frame)+5,
            self.view.bounds.size.width,
            self.view.bounds.size.width/4 // TODO line height derrived
        );
    }
    else
    {
        description.frame = CGRectMake(
            CGRectGetMaxX(contentView.frame),
            CGRectGetMinY(contentView.frame),
            self.view.bounds.size.width-CGRectGetMaxX(contentView.frame),
            self.view.bounds.size.width/4 // TODO line height derrived
        );
    }
    descriptionPrompt.frame = CGRectMake(description.frame.origin.x+5, description.frame.origin.y+5, self.view.bounds.size.width, 24);

    if(note.note_id)
    {
      deleteButton.frame = CGRectMake(0,self.view.bounds.size.height-40,self.view.bounds.size.width,40);
      locationPickerController.view.frame = CGRectMake(
          0,
          CGRectGetMaxY(description.frame),
          self.view.bounds.size.width,
          self.view.bounds.size.height-CGRectGetMinY(line2.frame)-40
       );
    }
    else
    {
      locationPickerController.view.frame = CGRectMake(
          0,
          CGRectGetMaxY(description.frame),
          self.view.bounds.size.width,
          self.view.bounds.size.height-CGRectGetMinY(line2.frame)
      );
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    blockKeyboard = NO;

    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveNoteButton];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

         if(mode == NOTE_EDITOR_MODE_AUDIO)  [self audioPickerButtonTouched];
    else if(mode == NOTE_EDITOR_MODE_CAMERA) [self cameraPickerButtonTouched];
    else if(mode == NOTE_EDITOR_MODE_ROLL)   [self rollPickerButtonTouched];
    //else if(mode == NOTE_EDITOR_MODE_TEXT)   [self guideNextEdit];
    mode = NOTE_EDITOR_MODE_NONE;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    blockKeyboard = YES;
}

- (void) guideNextEdit
{
    if(blockKeyboard) return;
    if(!tag && [_MODEL_TAGS_ tags].count)
        [tagViewController beginEditing];
}

- (void) refreshViewFromNote
{
    if(!self.view) [self loadView];

    description.text = note.desc;
    if(![description.text isEqualToString:@""]) descriptionPrompt.hidden = YES;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    if(note.media_id) [contentView setMedia:[_MODEL_MEDIA_ mediaForId:note.media_id]];
    [tagViewController setTag:tag];
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [self guideNextEdit];
    return NO;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
 {
     [self.view endEditing:YES];
 }

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [tagViewController stopEditing];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if([description.text isEqualToString:@""]) descriptionPrompt.hidden = NO;
    [tagViewController stopEditing];
}

- (void) noteTagEditorWillBeginEditing
{
    [description resignFirstResponder];
}

- (void) noteTagEditorAddedTag:(Tag *)nt
{
    tag = nt;
    [tagViewController setTag:nt];
}

- (void) noteTagEditorCancelled
{

}

- (void) noteTagEditorDeletedTag:(Tag *)nt
{
    tag = nil;
    [tagViewController setTag:tag];
}

- (void) doneButtonTouched
{
    [description resignFirstResponder];
}

- (void) textViewDidChange:(UITextView *)textView
{
    descriptionPrompt.hidden = YES;
    dirtybit = YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if([description.text isEqualToString:@""]) descriptionPrompt.hidden = NO;
    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:saveNoteButton];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;
}

- (void) mediaWasSelected:(Media *)m
{
    //do nothing
}

- (void) setLocationOnMap
{
    if(!trigger)
    {
        if(note.note_id)
        {
            NSArray *a = [_MODEL_INSTANCES_ instancesForType:@"NOTE" id:note.note_id];
            if(a.count) a = [_MODEL_TRIGGERS_ triggersForInstanceId:((Instance *)a[0]).instance_id];
            if(a.count) trigger = a[0];
        }
    }

    if(trigger)
        locationPickerController = [[NoteLocationPickerController alloc] initWithInitialLocation:trigger.location.coordinate delegate:self];
    else
        locationPickerController = [[NoteLocationPickerController alloc] initWithInitialLocation:_MODEL_PLAYER_.location.coordinate delegate:self];
}

- (void) cameraPickerButtonTouched
{
    [self.navigationController pushViewController:[[NoteCameraViewController alloc] initWithMode:NOTE_CAMERA_MODE_CAMERA delegate:self] animated:YES];
}

- (void) audioPickerButtonTouched
{
    [self.navigationController pushViewController:[[NoteRecorderViewController alloc] initWithDelegate:self] animated:YES];
}

- (void) rollPickerButtonTouched
{
    [self.navigationController pushViewController:[[NoteCameraViewController alloc] initWithMode:NOTE_CAMERA_MODE_ROLL delegate:self] animated:YES];
}

- (void) trashButtonTouched
{
    deletePrompt.title = [NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"DeleteKey", @""), NSLocalizedString(@"NoteKey", @"")];
    [deletePrompt showInView:self.view];
}

- (void) saveButtonTouched
{
    [self saveNote];
}

- (void) saveNote
{
    note.desc = description.text;

    if(note.note_id) [_MODEL_NOTES_ saveNote:note withTag:tag media:media trigger:trigger];
    else             [_MODEL_NOTES_ createNote:note withTag:tag media:media trigger:trigger];

    [delegate noteEditorConfirmedNoteEdit:self note:note];
}

- (void) deleteNote
{
    [_MODEL_NOTES_ deleteNoteId:note.note_id];
    [delegate noteEditorDeletedNoteEdit:self];
}

- (void) newLocationPicked:(CLLocationCoordinate2D)l
{
    trigger = [_MODEL_TRIGGERS_ triggerForId:0]; //get null trigger
    trigger.location = [[CLLocation alloc] initWithLatitude:l.latitude longitude:l.longitude];
    dirtybit = YES;
}


- (void) imageChosenWithURL:(NSURL *)url
{
    [self setTempMediaFromURL:url];
    [self.navigationController popToViewController:self animated:YES];
    dirtybit = YES;
}

- (void) videoChosenWithURL:(NSURL *)url
{
    [self setTempMediaFromURL:url];
    [self.navigationController popToViewController:self animated:YES];
    dirtybit = YES;
}

- (void) audioChosenWithURL:(NSURL *)url
{
    [self setTempMediaFromURL:url];
    [self.navigationController popToViewController:self animated:YES];
    dirtybit = YES;
}

- (void) setTempMediaFromURL:(NSURL *)url
{
    media = [_MODEL_MEDIA_ newMedia];
    media.data = [NSData dataWithContentsOfURL:url];
    [media setPartialLocalURL:[url absoluteString]]; //technically full URL- all that matters though is extension
    [contentView setMedia:media];
}

- (void) actionSheet:(UIActionSheet *)a clickedButtonAtIndex:(NSInteger)b
{
    if(a == confirmPrompt && b == 0) //save anyway
        [self saveNote];
    if(a == deletePrompt && b == 0) //delete
       [self deleteNote];
    if(a == discardChangesPrompt && b == 0) //discard
        [self dismissSelf];
}

- (void) cameraViewControllerCancelled
{
    [self dismissSelf];
}

- (void) recorderViewControllerCancelled
{
    [self dismissSelf];
}

- (void) locationPickerCancelled:(NoteLocationPickerController *)nlp
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) backButtonTouched
{
    if(dirtybit || ![note.desc isEqualToString:description.text])
    {
        discardChangesPrompt.title = NSLocalizedString(@"NoteEditorUnsavedChagned", @"");
        [discardChangesPrompt showInView:self.view];
    }
    else [self dismissSelf];
}

- (void) dismissSelf
{
   [delegate noteEditorCancelledNoteEdit:self];
}

@end

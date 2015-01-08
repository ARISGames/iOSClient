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
    UITextView *description;
    UILabel *descriptionPrompt;
    ARISMediaView *contentView;
    
    UIView *bottombar;
    CircleButton *locationPickerButton; 
    UILabel *locationPickerLabel;  
    CircleButton *trashButton; 
    UILabel *trashLabel;   
    
    UIView *line1;
    UIView *line2; 
    
    UIButton *descriptionDoneButton; 
    UIButton *saveNoteButton;
    UIButton *backButton;
    
    UIActionSheet *confirmPrompt;
    UIActionSheet *deletePrompt; 
    UIActionSheet *discardChangesPrompt;  

    NoteLocationPickerController *locationPickerController;

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
    [saveNoteButton setFont:[ARISTemplate ARISCellBoldTitleFont]];
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
    
    contentView = [[ARISMediaView alloc] initWithDelegate:self];
    [contentView setDisplayMode:ARISMediaDisplayModeAspectFill];
    contentView.clipsToBounds = YES;
    
    line1 = [[UIView alloc] init];
    line1.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    line2 = [[UIView alloc] init];
    line2.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    
    UIColor *fc = [UIColor whiteColor];
    UIColor *sc = [UIColor blackColor]; 
    UIColor *tc = [UIColor blackColor]; 
    int sw = 1; 
    
    bottombar = [[UIView alloc] init]; 
    
    locationPickerButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:fc disabledStrokeColor:[UIColor grayColor] disabledtitleColor:[UIColor grayColor] strokeWidth:sw];
    [locationPickerButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    [locationPickerButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [locationPickerButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    [locationPickerButton addTarget:self action:@selector(locationPickerButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    locationPickerLabel = [[UILabel alloc] init];
    locationPickerLabel.textAlignment = NSTextAlignmentCenter;
    locationPickerLabel.font = [ARISTemplate ARISCellSubtextFont];
    locationPickerLabel.textColor = [UIColor blackColor];  
    locationPickerLabel.numberOfLines = 0;
    locationPickerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    locationPickerLabel.text = [NSString stringWithFormat:@"%@\n%@", [NSLocalizedString(@"SetKey", @"") uppercaseString], [NSLocalizedString(@"LocationKey", @"") uppercaseString]];
    
    trashButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
    [trashButton setImage:[UIImage imageNamed:@"trash_red.png"] forState:UIControlStateNormal];
    [trashButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [trashButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    [trashButton addTarget:self action:@selector(trashButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    trashLabel = [[UILabel alloc] init];
    trashLabel.textAlignment = NSTextAlignmentCenter;
    trashLabel.font = [ARISTemplate ARISCellSubtextFont];
    trashLabel.textColor = [UIColor blackColor];  
    trashLabel.numberOfLines = 0;
    trashLabel.lineBreakMode = NSLineBreakByWordWrapping;
    trashLabel.text = [NSString stringWithFormat:@"%@\n%@", [NSLocalizedString(@"DeleteKey", @"") uppercaseString], [NSLocalizedString(@"NoteKey", @"") uppercaseString]];
    
    [bottombar addSubview:locationPickerButton];
    [bottombar addSubview:locationPickerLabel];
    
    [bottombar addSubview:trashButton];
    [bottombar addSubview:trashLabel];
    
    [self.view addSubview:description];
    [self.view addSubview:descriptionPrompt]; 
    [self.view addSubview:contentView];
    //[self.view addSubview:bottombar]; 
    if([_MODEL_TAGS_ tags].count) [self.view addSubview:tagViewController.view];  
    [self.view addSubview:line1];  
    [self.view addSubview:line2];   
    
    [self refreshViewFromNote];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //order of sizing not top to bottom- calculate edge views to derive sizes of middle views
    
    if([_MODEL_TAGS_ tags].count > 0)
    {
        [tagViewController setExpandHeight:self.view.frame.size.height-64-49-216]; 
        if(tagViewController.view.frame.size.height <= 30)
            tagViewController.view.frame = CGRectMake(0, 54+64+3, self.view.bounds.size.width, 30);   
        else
            tagViewController.view.frame = CGRectMake(0, 54+64+3, self.view.bounds.size.width, self.view.frame.size.height-64-49-216);    
        
        line2.frame = CGRectMake(0, tagViewController.view.frame.origin.y+tagViewController.view.frame.size.height+3, self.view.frame.size.width, 1); 
    }
    
    line1.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, 1);
    
    int buttonDiameter = 50;
    int buttonPadding = ((self.view.frame.size.width/4)-buttonDiameter)/2; 
    locationPickerButton.frame = CGRectMake(buttonPadding*5+buttonDiameter*2, 5, buttonDiameter, buttonDiameter); 
    locationPickerLabel.frame  = CGRectMake(buttonPadding*5+buttonDiameter*2-buttonDiameter/2+10, buttonDiameter+5, buttonDiameter*2-20, 30);
    trashButton.frame          = CGRectMake(buttonPadding*7+buttonDiameter*3, 5, buttonDiameter, buttonDiameter); 
    trashLabel.frame           = CGRectMake(buttonPadding*7+buttonDiameter*3-buttonDiameter/2+10, buttonDiameter+5, buttonDiameter*2-20, 30);
    bottombar.frame = CGRectMake(0, self.view.bounds.size.height-buttonDiameter-40, self.view.bounds.size.width, buttonDiameter+25); 
    
    contentView.frame = CGRectMake(0, bottombar.frame.origin.y-200, self.view.bounds.size.width, 200);       
    
    if([_MODEL_TAGS_ tags].count > 0)
    {
        description.frame = CGRectMake(5, tagViewController.view.frame.origin.y+tagViewController.view.frame.size.height+5, self.view.bounds.size.width-10, self.view.bounds.size.height-tagViewController.view.frame.origin.y-tagViewController.view.frame.size.height-contentView.frame.size.height-bottombar.frame.size.height-5);
    }
    else
    {
        description.frame = CGRectMake(5, line1.frame.origin.y+line1.frame.size.height+5, self.view.bounds.size.width-10, self.view.bounds.size.height-line1.frame.origin.y-line1.frame.size.height-contentView.frame.size.height-bottombar.frame.size.height-5);
    }
    descriptionPrompt.frame = CGRectMake(10, description.frame.origin.y+5, self.view.bounds.size.width, 24);  
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
    else if(mode == NOTE_EDITOR_MODE_TEXT)   [self guideNextEdit];
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

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [tagViewController stopEditing]; 
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if([description.text isEqualToString:@""]) descriptionPrompt.hidden = NO;
    [tagViewController stopEditing];
    
    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:descriptionDoneButton];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;      
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

- (void) locationPickerButtonTouched
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
        [self.navigationController pushViewController:[[NoteLocationPickerController alloc] initWithInitialLocation:trigger.location.coordinate delegate:self] animated:YES];
    else
        [self.navigationController pushViewController:[[NoteLocationPickerController alloc] initWithInitialLocation:_MODEL_PLAYER_.location.coordinate delegate:self] animated:YES]; 
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

    [self setLocationDefault];

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
    [self.navigationController popToViewController:self animated:YES];
    dirtybit = YES; 
}


- (void) setLocationDefault
{
    if(!trigger)
    {
      trigger = [_MODEL_TRIGGERS_ triggerForId:0]; //get null trigger
      // NOTE is this alright? direct assignment.
      CLLocationCoordinate2D coordinate = _MODEL_PLAYER_.location.coordinate;
      trigger.location = [[CLLocation alloc] initWithLatitude: coordinate.latitude longitude: coordinate.longitude];
    }
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

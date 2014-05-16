//
//  NoteEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "NoteEditorViewController.h"
#import "NoteContentsViewController.h"
#import "NoteTagEditorViewController.h"
#import "NoteCameraViewController.h"
#import "NoteRecorderViewController.h"
#import "NoteLocationPickerController.h"
#import "Note.h"
#import "NoteTag.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "AppServices.h"
#import "User.h"
#import "ARISTemplate.h"
#import "CircleButton.h"

@interface NoteEditorViewController () <UITextFieldDelegate, UITextViewDelegate, NoteTagEditorViewControllerDelegate, NoteContentsViewControllerDelegate, NoteCameraViewControllerDelegate, NoteRecorderViewControllerDelegate, NoteLocationPickerControllerDelegate, UIActionSheetDelegate>
{
    Note *note;
    
    UITextField *title;
    UILabel *owner;
    UILabel *date;
    NoteTagEditorViewController *tagViewController;  
    NoteTag *newTag;
    UITextView *description;
    UILabel *descriptionPrompt;
    NoteContentsViewController *contentsViewController;
    
    UIView *bottombar;
    CircleButton *imagePickerButton; 
    UILabel *imagePickerLabel;
    CircleButton *audioPickerButton;  
    UILabel *audioPickerLabel; 
    CircleButton *locationPickerButton; 
    UILabel *locationPickerLabel;  
    CircleButton *trashButton; 
    UILabel *trashLabel;   
    
    UIView *line1;
    UIView *line2; 
    
    UIButton *descriptionDoneButton; 
    UIButton *saveNoteButton;
    
    UIActionSheet *confirmPrompt;
    UIActionSheet *deletePrompt; 
    UIActionSheet *discardChangesPrompt;  
    
    NSMutableArray *mediaToUpload;
    
    NoteEditorMode mode;
    
    BOOL blockKeyboard;
    BOOL newNote;
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
        newNote = (!n);
        if(newNote)
        {
            n = [[Note alloc] init];
            n.created = [NSDate date];
            n.owner = _MODEL_PLAYER_;
            n.location = [[Location alloc] init];
            n.location.latlon = _MODEL_PLAYER_.location;
            n.location.coordinate = _MODEL_PLAYER_.location.coordinate; 
            dirtybit = YES;
        }
        note = n; 
        if([n.tags count] > 0) newTag = [n.tags objectAtIndex:0]; 
        mode = m;
        delegate = d;
        
        mediaToUpload = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    title = [[UITextField alloc] init];
    title.delegate = self;
    title.font = [ARISTemplate ARISTitleFont];
    title.placeholder = NSLocalizedString(@"TitleAndDescriptionTitleKey", @"");
    title.returnKeyType = UIReturnKeyDone;
    
    date = [[UILabel alloc] init];  
    date.font = [ARISTemplate ARISSubtextFont]; 
    date.textColor = [UIColor ARISColorDarkBlue];
    date.adjustsFontSizeToFitWidth = NO;
    
    owner = [[UILabel alloc] init];
    owner.font = [ARISTemplate ARISSubtextFont];
    owner.adjustsFontSizeToFitWidth = NO;
    
    description = [[UITextView alloc] init];   
    description.delegate = self;
    description.contentInset = UIEdgeInsetsZero; 
    description.font = [ARISTemplate ARISBodyFont];
    
    tagViewController = [[NoteTagEditorViewController alloc] initWithTags:note.tags editable:YES delegate:self]; 
    
    descriptionPrompt = [[UILabel alloc] init];
    descriptionPrompt.text = NSLocalizedString(@"NoteEditorDescriptionKey", @"");
    descriptionPrompt.font = [ARISTemplate ARISBodyFont]; 
    descriptionPrompt.textColor = [UIColor ARISColorLightGray];
    
    descriptionDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [descriptionDoneButton setImage:[UIImage imageNamed:@"overarrow.png"] forState:UIControlStateNormal]; 
    descriptionDoneButton.frame = CGRectMake(0, 0, 24, 24); 
    [descriptionDoneButton addTarget:self action:@selector(doneButtonTouched) forControlEvents:UIControlEventTouchUpInside];
       
    saveNoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveNoteButton setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    saveNoteButton.frame = CGRectMake(0, 0, 24, 24);
    [saveNoteButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    confirmPrompt = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"NoteEditorTitleNoteKey", @"") destructiveButtonTitle:NSLocalizedString(@"NoteEditorSaveUntitledKey", @"") otherButtonTitles:nil];
    deletePrompt = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") destructiveButtonTitle:NSLocalizedString(@"DeleteKey", @"") otherButtonTitles:nil];
    discardChangesPrompt = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"NoteEditorContinueEditingKey", @"") destructiveButtonTitle:NSLocalizedString(@"DiscardKey", @"") otherButtonTitles:nil];
    
    contentsViewController = [[NoteContentsViewController alloc] initWithNoteContents:note.contents delegate:self];
    
    line1 = [[UIView alloc] init];
    line1.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    line2 = [[UIView alloc] init];
    line2.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    
    UIColor *fc = [UIColor whiteColor];
    UIColor *sc = [UIColor blackColor]; 
    UIColor *tc = [UIColor blackColor]; 
    int sw = 1; 
    
    bottombar = [[UIView alloc] init]; 
    
    imagePickerButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw]; 
    [imagePickerButton setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];  
    [imagePickerButton.titleLabel setFont:[ARISTemplate ARISButtonFont]]; 
    [imagePickerButton addTarget:self action:@selector(imagePickerButtonTouched) forControlEvents:UIControlEventTouchUpInside];  
    imagePickerLabel = [[UILabel alloc] init];
    imagePickerLabel.textAlignment = NSTextAlignmentCenter;  
    imagePickerLabel.font = [ARISTemplate ARISCellSubtextFont];
    imagePickerLabel.textColor = [UIColor blackColor];
    imagePickerLabel.numberOfLines = 0;
    imagePickerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    imagePickerLabel.text = [NSString stringWithFormat:@"%@\n%@", [NSLocalizedString(@"AddKey", @"") uppercaseString], [NSLocalizedString(@"ImageKey", @"") uppercaseString]];
    
    audioPickerButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw]; 
    [audioPickerButton setImage:[UIImage imageNamed:@"microphone.png"] forState:UIControlStateNormal]; 
    [audioPickerButton.titleLabel setFont:[ARISTemplate ARISButtonFont]]; 
    [audioPickerButton addTarget:self action:@selector(audioPickerButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    audioPickerLabel = [[UILabel alloc] init];
    audioPickerLabel.textAlignment = NSTextAlignmentCenter; 
    audioPickerLabel.font = [ARISTemplate ARISCellSubtextFont];
    audioPickerLabel.textColor = [UIColor blackColor]; 
    audioPickerLabel.numberOfLines = 0; 
    audioPickerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    audioPickerLabel.text = [NSString stringWithFormat:@"%@\n%@", [NSLocalizedString(@"AddKey", @"") uppercaseString], [NSLocalizedString(@"AudioKey", @"") uppercaseString]];
    
    locationPickerButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
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
    
    [bottombar addSubview:imagePickerButton]; 
    [bottombar addSubview:imagePickerLabel];  
    [bottombar addSubview:audioPickerButton]; 
    [bottombar addSubview:audioPickerLabel];   
    [bottombar addSubview:locationPickerButton]; 
    [bottombar addSubview:locationPickerLabel];   
    [bottombar addSubview:trashButton]; 
    [bottombar addSubview:trashLabel];    
    
    [self.view addSubview:title];
    [self.view addSubview:date];
    [self.view addSubview:owner];
    [self.view addSubview:description];
    [self.view addSubview:descriptionPrompt]; 
    [self.view addSubview:contentsViewController.view];
    [self.view addSubview:bottombar]; 
    [self.view addSubview:tagViewController.view];  
    [self.view addSubview:line1];  
    [self.view addSubview:line2];   
    
    [self refreshViewFromNote];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //order of sizing not top to bottom- calculate edge views to derive sizes of middle views
    
    title.frame = CGRectMake(10, 15+64, self.view.bounds.size.width-20, 20);
    date.frame = CGRectMake(10, 40+64, 65, 14);
    owner.frame = CGRectMake(75, 40+64, self.view.bounds.size.width-85, 14);
    
    [tagViewController setExpandHeight:self.view.frame.size.height-64-49-216]; 
    if(tagViewController.view.frame.size.height <= 30)
        tagViewController.view.frame = CGRectMake(0, 54+64+3, self.view.bounds.size.width, 30);   
    else
        tagViewController.view.frame = CGRectMake(0, 54+64+3, self.view.bounds.size.width, self.view.frame.size.height-64-49-216);    
    
    line1.frame = CGRectMake(0, owner.frame.origin.y+owner.frame.size.height+3, self.view.frame.size.width, 1);
    line2.frame = CGRectMake(0, tagViewController.view.frame.origin.y+tagViewController.view.frame.size.height+3, self.view.frame.size.width, 1); 
    
    int buttonDiameter = 50;
    int buttonPadding = ((self.view.frame.size.width/4)-buttonDiameter)/2; 
    imagePickerButton.frame    = CGRectMake(buttonPadding*1+buttonDiameter*0, 5, buttonDiameter, buttonDiameter);
    imagePickerLabel.frame     = CGRectMake(buttonPadding*1+buttonDiameter*0-buttonDiameter/2+10, buttonDiameter+5, buttonDiameter*2-20, 30);
    audioPickerButton.frame    = CGRectMake(buttonPadding*3+buttonDiameter*1, 5, buttonDiameter, buttonDiameter); 
    audioPickerLabel.frame     = CGRectMake(buttonPadding*3+buttonDiameter*1-buttonDiameter/2+10, buttonDiameter+5, buttonDiameter*2-20, 30);
    locationPickerButton.frame = CGRectMake(buttonPadding*5+buttonDiameter*2, 5, buttonDiameter, buttonDiameter); 
    locationPickerLabel.frame  = CGRectMake(buttonPadding*5+buttonDiameter*2-buttonDiameter/2+10, buttonDiameter+5, buttonDiameter*2-20, 30);
    trashButton.frame          = CGRectMake(buttonPadding*7+buttonDiameter*3, 5, buttonDiameter, buttonDiameter); 
    trashLabel.frame           = CGRectMake(buttonPadding*7+buttonDiameter*3-buttonDiameter/2+10, buttonDiameter+5, buttonDiameter*2-20, 30);
    bottombar.frame = CGRectMake(0, self.view.bounds.size.height-buttonDiameter-40, self.view.bounds.size.width, buttonDiameter+25); 
    
    //contentsViewController.view.frame = CGRectMake(0, 249+64, self.view.bounds.size.width, self.view.bounds.size.height-249-44-64);      
    contentsViewController.view.frame = CGRectMake(0, bottombar.frame.origin.y-200, self.view.bounds.size.width, 200);       
    
    description.frame = CGRectMake(5, tagViewController.view.frame.origin.y+tagViewController.view.frame.size.height+5, self.view.bounds.size.width-10, self.view.bounds.size.height-tagViewController.view.frame.origin.y-tagViewController.view.frame.size.height-contentsViewController.view.frame.size.height-bottombar.frame.size.height-5);
    descriptionPrompt.frame = CGRectMake(10, description.frame.origin.y+5, self.view.bounds.size.width, 24);  
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    blockKeyboard = NO;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,19,19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];   
    
    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:saveNoteButton];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;     
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
         if(mode == NOTE_EDITOR_MODE_AUDIO) [self audioPickerButtonTouched];
    else if(mode == NOTE_EDITOR_MODE_IMAGE) [self imagePickerButtonTouched];
    else if(mode == NOTE_EDITOR_MODE_VIDEO) [self videoPickerButtonTouched];
    else if(mode == NOTE_EDITOR_MODE_TEXT)  [self guideNextEdit];
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
    if([title.text isEqualToString:@""] && !title.isFirstResponder)
        [title becomeFirstResponder]; 
    else if(note.tags.count == 0)
        [tagViewController beginEditing];
    else if(title.isFirstResponder)
        [title resignFirstResponder];
}

- (void) refreshViewFromNote
{
    if(!self.view) [self loadView];
    
    title.text = note.name; 
    description.text = note.desc;
    if(![description.text isEqualToString:@""]) descriptionPrompt.hidden = YES;  
    NSDateFormatter *format = [[NSDateFormatter alloc] init]; 
    [format setDateFormat:@"MM/dd/yy"]; 
    date.text = [format stringFromDate:note.created]; 
    owner.text = note.owner.display_name; 
    [contentsViewController setContents:note.contents];
    newTag = nil; if([note.tags count] > 0) newTag = [note.tags objectAtIndex:0];   
    if(newTag) [tagViewController setTags:@[newTag]];
    else       [tagViewController setTags:nil];
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
    [title resignFirstResponder]; 
    [description resignFirstResponder];
}

- (void) noteTagEditorAddedTag:(NoteTag *)nt
{
    newTag = nt;   
    if(nt) [tagViewController setTags:@[nt]];
    else   [tagViewController setTags:nil];
}

- (void) noteTagEditorCreatedTag:(NoteTag *)nt
{
    newTag = nt;   
    if(nt) [tagViewController setTags:@[nt]];
    else   [tagViewController setTags:nil]; 
}

- (void) noteTagEditorDeletedTag:(NoteTag *)nt
{
    newTag = nil;   
    [tagViewController setTags:nil];  
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
    if(note.location && note.location.latlon)
        [self.navigationController pushViewController:[[NoteLocationPickerController alloc] initWithInitialLocation:note.location.coordinate delegate:self] animated:YES];
    else
        [self.navigationController pushViewController:[[NoteLocationPickerController alloc] initWithInitialLocation:_MODEL_PLAYER_.location.coordinate delegate:self] animated:YES]; 
}

- (void) imagePickerButtonTouched
{
    [self.navigationController pushViewController:[[NoteCameraViewController alloc] initWithDelegate:self] animated:YES];
}

- (void) audioPickerButtonTouched
{
    [self.navigationController pushViewController:[[NoteRecorderViewController alloc] initWithDelegate:self] animated:YES]; 
}

- (void) videoPickerButtonTouched
{
    [self.navigationController pushViewController:[[NoteCameraViewController alloc] initWithDelegate:self] animated:YES]; 
}

- (void) trashButtonTouched
{
    deletePrompt.title = [NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"DeleteKey", @""), NSLocalizedString(@"NoteKey", @"")];
    [deletePrompt showInView:self.view]; 
}

- (void) saveButtonTouched
{
    if([title.text isEqualToString:@""])
    {
        confirmPrompt.title = NSLocalizedString(@"NoteEditorNoteIsUntitledKey", @"");
        [confirmPrompt showInView:self.view];
    }
    else if(!newTag)
    {
        confirmPrompt.title = NSLocalizedString(@"NoteEditorNoteIsntLabeled", @"");
        [confirmPrompt showInView:self.view];
    } 
    else [self saveNote];
}

- (void) saveNote
{
    note.name = title.text;
    note.desc = description.text;
    if(newTag) note.tags = [NSMutableArray arrayWithArray:@[newTag]];
    else note.tags = [[NSMutableArray alloc] init];

    //for(int i = 0; i < [mediaToUpload count]; i++)
        //[note.contents addObject:[mediaToUpload objectAtIndex:i]];

    //feel icky about this...
    note.contents = mediaToUpload;

    //[_SERVICES_ uploadNote:note];

    [delegate noteEditorConfirmedNoteEdit:self note:note];
}

- (void) deleteNote
{
    [[AppServices sharedAppServices] deleteNoteWithNoteId:note.noteId]; 
    [_MODEL_GAME_.notesModel deleteNote:note];
    [delegate noteEditorDeletedNoteEdit:self];  
}

- (void) newLocationPicked:(CLLocationCoordinate2D)l
{
    note.location = [[Location alloc] init];
    note.location.latlon = [[CLLocation alloc] initWithLatitude:l.latitude longitude:l.longitude];
    note.location.coordinate = l;
    [self.navigationController popToViewController:self animated:YES];
    dirtybit = YES; 
}

- (void) imageChosenWithURL:(NSURL *)url
{
    [self addMediaToUploadFromURL:url];  
    [self.navigationController popToViewController:self animated:YES];  
    dirtybit = YES;
}

- (void) videoChosenWithURL:(NSURL *)url
{
    [self addMediaToUploadFromURL:url]; 
    [self.navigationController popToViewController:self animated:YES]; 
    dirtybit = YES; 
}

- (void) audioChosenWithURL:(NSURL *)url
{
    [self addMediaToUploadFromURL:url];
    [self.navigationController popToViewController:self animated:YES];  
    dirtybit = YES; 
}

- (void) addMediaToUploadFromURL:(NSURL *)url
{
    Media *m = [_MODEL_MEDIA_ newMedia];
    m.localURL = url;
    m.data = [NSData dataWithContentsOfURL:m.localURL]; 
    [mediaToUpload addObject:m];   
    
    [contentsViewController setContents:[mediaToUpload arrayByAddingObjectsFromArray:note.contents]];  
}

- (void) actionSheet:(UIActionSheet *)a clickedButtonAtIndex:(NSInteger)b
{
    if(a == confirmPrompt && b ==0) //save anyway
        [self saveNote];
    if(a == deletePrompt && b ==0) //delete
       [self deleteNote]; 
    if(a == discardChangesPrompt && b ==0) //discard
        [self dismissSelf];  
}

- (void) cameraViewControllerCancelled
{
    [self.navigationController popToViewController:self animated:YES];   
}

- (void) recorderViewControllerCancelled
{
    [self.navigationController popToViewController:self animated:YES];   
}

- (void) locationPickerCancelled:(NoteLocationPickerController *)nlp
{
    [self.navigationController popToViewController:self animated:YES];    
}

- (void) backButtonTouched
{
    if(dirtybit || ![note.name isEqualToString:title.text] || ![note.desc isEqualToString:description.text])
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

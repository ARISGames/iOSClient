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
#import "Player.h"
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
    CircleButton *locationPickerButton;
    CircleButton *imagePickerButton; 
    CircleButton *audioPickerButton;  
    
    UIView *line1;
    UIView *line2; 
    
    UIButton *descriptionDoneButton; 
    UIButton *saveNoteButton;
    
    UIActionSheet *confirmPrompt;
    
    NSMutableArray *mediaToUpload;
    
    NoteEditorMode mode;
    
    BOOL blockKeyboard;
    BOOL newNote;
    id<NoteEditorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteEditorViewController

- (id) initWithNote:(Note *)n mode:(NoteEditorMode)m delegate:(id<NoteEditorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        newNote = (!n);
        if(newNote)
        {
            n = [[Note alloc] init];
            n.created = [NSDate date];
            n.owner = [AppModel sharedAppModel].player;
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
    title.placeholder = @"Title";
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
    descriptionPrompt.text = @"Note Description";
    descriptionPrompt.textColor = [UIColor ARISColorLightGray];
    
    descriptionDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [descriptionDoneButton setImage:[UIImage imageNamed:@"overarrow.png"] forState:UIControlStateNormal]; 
    descriptionDoneButton.frame = CGRectMake(0, 0, 24, 24); 
    [descriptionDoneButton addTarget:self action:@selector(doneButtonTouched) forControlEvents:UIControlEventTouchUpInside];
       
    saveNoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveNoteButton setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    saveNoteButton.frame = CGRectMake(0, 0, 24, 24);
    [saveNoteButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    confirmPrompt = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Save Anyway" otherButtonTitles:nil];
    
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
    
    audioPickerButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw]; 
    [audioPickerButton setImage:[UIImage imageNamed:@"microphone.png"] forState:UIControlStateNormal]; 
    [audioPickerButton.titleLabel setFont:[ARISTemplate ARISButtonFont]]; 
    [audioPickerButton addTarget:self action:@selector(audioPickerButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    locationPickerButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
    [locationPickerButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    [locationPickerButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [locationPickerButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    [locationPickerButton addTarget:self action:@selector(locationPickerButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [bottombar addSubview:imagePickerButton]; 
    [bottombar addSubview:audioPickerButton]; 
    [bottombar addSubview:locationPickerButton]; 
    
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
    
    title.frame = CGRectMake(10, 10+64, self.view.bounds.size.width-20, 20);
    date.frame = CGRectMake(10, 35+64, 65, 14);
    owner.frame = CGRectMake(75, 35+64, self.view.bounds.size.width-85, 14);
    
    [tagViewController setExpandHeight:self.view.frame.size.height-64-49-216]; 
    if(tagViewController.view.frame.size.height <= 30)
        tagViewController.view.frame = CGRectMake(0, 49+64+3, self.view.bounds.size.width, 30);   
    else
        tagViewController.view.frame = CGRectMake(0, 49+64+3, self.view.bounds.size.width, self.view.frame.size.height-64-49-216);    
    
    line1.frame = CGRectMake(0, owner.frame.origin.y+owner.frame.size.height+3, self.view.frame.size.width, 1);
    line2.frame = CGRectMake(0, tagViewController.view.frame.origin.y+tagViewController.view.frame.size.height+3, self.view.frame.size.width, 1); 
    
    int buttonDiameter = 50;
    int buttonPadding = ((self.view.frame.size.width/3)-buttonDiameter)/2; 
    imagePickerButton.frame    = CGRectMake(buttonPadding*1+buttonDiameter*0, 5, buttonDiameter, buttonDiameter);
    audioPickerButton.frame    = CGRectMake(buttonPadding*3+buttonDiameter*1, 5, buttonDiameter, buttonDiameter); 
    locationPickerButton.frame = CGRectMake(buttonPadding*5+buttonDiameter*2, 5, buttonDiameter, buttonDiameter); 
    bottombar.frame = CGRectMake(0, self.view.bounds.size.height-buttonDiameter-10, self.view.bounds.size.width, buttonDiameter+10); 
    
    //contentsViewController.view.frame = CGRectMake(0, 249+64, self.view.bounds.size.width, self.view.bounds.size.height-249-44-64);      
    contentsViewController.view.frame = CGRectMake(0, bottombar.frame.origin.y-250, self.view.bounds.size.width, 250);       
    
    description.frame = CGRectMake(5, tagViewController.view.frame.origin.y+tagViewController.view.frame.size.height, self.view.bounds.size.width-10, self.view.bounds.size.height-tagViewController.view.frame.origin.y-tagViewController.view.frame.size.height-contentsViewController.view.frame.size.height);
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
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:saveNoteButton];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;     
    
         if(mode == NOTE_EDITOR_MODE_AUDIO) [self audioPickerButtonTouched];
    else if(mode == NOTE_EDITOR_MODE_IMAGE) [self imagePickerButtonTouched];
    else if(mode == NOTE_EDITOR_MODE_VIDEO) [self videoPickerButtonTouched];
    else [self guideNextEdit];
    
    mode = NOTE_EDITOR_MODE_TEXT;
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
    owner.text = note.owner.displayname; 
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
        [self.navigationController pushViewController:[[NoteLocationPickerController alloc] initWithInitialLocation:[AppModel sharedAppModel].player.location.coordinate delegate:self] animated:YES]; 
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

- (void) saveButtonTouched
{
    if([title.text isEqualToString:@""])
    {
        confirmPrompt.title = @"Your note has no title!";
        [confirmPrompt showInView:self.view];
    }
    else if(!newTag)
    {
        confirmPrompt.title = @"Your note isn't labeled!";
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

    [[AppServices sharedAppServices] uploadNote:note];

    [delegate noteEditorConfirmedNoteEdit:self note:note];
}

- (void) newLocationPicked:(CLLocationCoordinate2D)l
{
    note.location = [[Location alloc] init];
    note.location.latlon = [[CLLocation alloc] initWithLatitude:l.latitude longitude:l.longitude];
    note.location.coordinate = l;
    [self.navigationController popToViewController:self animated:YES];
}

- (void) imageChosenWithURL:(NSURL *)url
{
    [self addMediaToUploadFromURL:url];  
    [self.navigationController popToViewController:self animated:YES];  
}

- (void) videoChosenWithURL:(NSURL *)url
{
    [self addMediaToUploadFromURL:url]; 
    [self.navigationController popToViewController:self animated:YES]; 
}

- (void) audioChosenWithURL:(NSURL *)url
{
    [self addMediaToUploadFromURL:url];
    [self.navigationController popToViewController:self animated:YES];  
}

- (void) addMediaToUploadFromURL:(NSURL *)url
{
    Media *m = [[AppModel sharedAppModel].mediaModel newMedia];
    m.localURL = url;
    m.data = [NSData dataWithContentsOfURL:m.localURL]; 
    [mediaToUpload addObject:m];   
    
    [contentsViewController setContents:[mediaToUpload arrayByAddingObjectsFromArray:note.contents]];  
}

- (void) actionSheet:(UIActionSheet *)a clickedButtonAtIndex:(NSInteger)b
{
    if(b == 0) //save anyway
        [self saveNote];
}

- (void) cameraViewControllerCancelled
{
    [self.navigationController popToViewController:self animated:YES];   
}

- (void) recorderViewControllerCancelled
{
    [self.navigationController popToViewController:self animated:YES];   
}

- (void) backButtonTouched
{
    [delegate noteEditorCancelledNoteEdit:self];
}

@end

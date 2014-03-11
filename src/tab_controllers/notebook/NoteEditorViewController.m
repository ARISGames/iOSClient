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

@interface NoteEditorViewController () <UITextFieldDelegate, UITextViewDelegate, NoteTagEditorViewControllerDelegate, NoteContentsViewControllerDelegate, NoteCameraViewControllerDelegate, NoteRecorderViewControllerDelegate, NoteLocationPickerControllerDelegate>
{
    Note *note;
    
    UITextField *title;
    UILabel *owner;
    UILabel *date;
    UITextView *description;
    NoteTagEditorViewController *tagViewController;
    NoteContentsViewController *contentsViewController;
    UIButton *locationPickerButton;
    UIButton *imagePickerButton; 
    UIButton *audioPickerButton;  
    
    UIButton *descriptionDoneButton; 
    UIButton *saveNoteButton;
    
    NSMutableArray *mediaToUpload;
    
    BOOL newNote;
    id<NoteEditorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteEditorViewController

- (id) initWithNote:(Note *)n delegate:(id<NoteEditorViewControllerDelegate>)d
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
        delegate = d;
        
        mediaToUpload = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    title = [[UITextField alloc] initWithFrame:CGRectMake(10, 10+64, self.view.bounds.size.width-20, 20)];
    title.delegate = self;
    title.font = [ARISTemplate ARISTitleFont]; 
    title.placeholder = @"Title";
    title.returnKeyType = UIReturnKeyDone;
    
    date = [[UILabel alloc] initWithFrame:CGRectMake(10, 35+64, 65, 14)];  
    date.font = [ARISTemplate ARISSubtextFont]; 
    date.textColor = [UIColor ARISColorDarkBlue];
    date.adjustsFontSizeToFitWidth = NO;
    
    owner = [[UILabel alloc] initWithFrame:CGRectMake(75, 35+64, self.view.bounds.size.width-85, 14)];
    owner.font = [ARISTemplate ARISSubtextFont];
    owner.adjustsFontSizeToFitWidth = NO;
    
    description = [[UITextView alloc] initWithFrame:CGRectMake(10, 49+64, self.view.bounds.size.width-20, 170)];   
    description.delegate = self;
    description.contentInset = UIEdgeInsetsZero; 
    description.font = [ARISTemplate ARISBodyFont];
    
    descriptionDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [descriptionDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [descriptionDoneButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
    descriptionDoneButton.frame = CGRectMake(0, 0, 70, 24); 
    [descriptionDoneButton addTarget:self action:@selector(doneButtonTouched) forControlEvents:UIControlEventTouchUpInside];
       
    saveNoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveNoteButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveNoteButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
    saveNoteButton.frame = CGRectMake(0, 0, 70, 24);
    [saveNoteButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    tagViewController = [[NoteTagEditorViewController alloc] initWithTags:note.tags editable:YES delegate:self];
    tagViewController.view.frame = CGRectMake(0, 219+64, self.view.bounds.size.width, 30);
    contentsViewController = [[NoteContentsViewController alloc] initWithNoteContents:note.contents delegate:self];
    contentsViewController.view.frame = CGRectMake(0, 249+64, self.view.bounds.size.width, self.view.bounds.size.height-249-44-64);     
    
    UIView *bottombar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    locationPickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationPickerButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    locationPickerButton.frame = CGRectMake(10, 10, 24, 24);
    [locationPickerButton addTarget:self action:@selector(locationPickerButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    imagePickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imagePickerButton setImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal]; 
    imagePickerButton.frame = CGRectMake(44, 10, 24, 24); 
    [imagePickerButton addTarget:self action:@selector(imagePickerButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    audioPickerButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
    [audioPickerButton setImage:[UIImage imageNamed:@"microphone.png"] forState:UIControlStateNormal]; 
    audioPickerButton.frame = CGRectMake(78, 10, 24, 24); 
    [audioPickerButton addTarget:self action:@selector(audioPickerButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    [bottombar addSubview:locationPickerButton];
    [bottombar addSubview:imagePickerButton]; 
    [bottombar addSubview:audioPickerButton]; 
    
    [self.view addSubview:title];
    [self.view addSubview:date];
    [self.view addSubview:owner];
    [self.view addSubview:description];
    [self.view addSubview:tagViewController.view];
    [self.view addSubview:contentsViewController.view];
    [self.view addSubview:bottombar]; 
    
    [self refreshViewFromNote];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([title.text isEqualToString:@""])
        [title becomeFirstResponder];
             
    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:saveNoteButton];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;     
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,19,19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];  
}

- (void) refreshViewFromNote
{
    if(!self.view) [self loadView];
    
    title.text = note.name; 
    description.text = note.desc;
    NSDateFormatter *format = [[NSDateFormatter alloc] init]; 
    [format setDateFormat:@"MM/dd/yy"]; 
    date.text = [format stringFromDate:note.created]; 
    owner.text = note.owner.displayname; 
    [contentsViewController setContents:note.contents];
    [tagViewController setTags:note.tags];
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [title resignFirstResponder];
    return NO; //prevents \n from being added to description
}

- (void) textFieldWillBeginEditing:(UITextField *)textField
{
    [tagViewController stopEditing]; 
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if([description.text isEqualToString:@""])
        [description becomeFirstResponder];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
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
    [note.tags addObject:nt];
    [tagViewController setTags:note.tags];
}

- (void) noteTagEditorCreatedTag:(NoteTag *)nt
{
    [note.tags addObject:nt];
    [tagViewController setTags:note.tags];
}

- (void) noteTagEditorDeletedTag:(NoteTag *)nt
{
    [note.tags removeObject:nt]; 
    [tagViewController setTags:note.tags]; 
}

- (void) doneButtonTouched
{
    [description resignFirstResponder];
    if(note.tags.count == 0) [tagViewController beginEditing];
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
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

- (void) saveButtonTouched
{
    if([title.text isEqualToString:@""])
        [title becomeFirstResponder];
    else [self saveNote];
}

- (void) saveNote
{
    note.name = title.text;
    note.desc = description.text;

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

- (void) cameraViewControllerCancelled
{
    [self.navigationController popToViewController:self animated:YES];   
}

- (void) recorderViewControllerCancelled
{
    [self.navigationController popToViewController:self animated:YES];   
}

@end

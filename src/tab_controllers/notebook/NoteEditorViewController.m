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
#import "Note.h"
#import "Tag.h"
#import "AppModel.h"
#import "UIColor+ARISColors.h"

@interface NoteEditorViewController () <UITextFieldDelegate, UITextViewDelegate, NoteTagEditorViewControllerDelegate, NoteContentsViewControllerDelegate>
{
    Note *note;
    
    UITextField *title;
    UILabel *owner;
    UILabel *date;
    UITextView *description;
    UIButton *descriptionDoneButton;
    NoteTagEditorViewController *tagViewController;
    NoteContentsViewController *contentsViewController;
    UIButton *locationPickerButton;
    UIButton *imagePickerButton; 
    UIButton *audioPickerButton;  
    UIButton *shareButton;   
    
    id<NoteEditorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteEditorViewController

- (id) initWithNote:(Note *)n delegate:(id<NoteEditorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        if(!n)
        {
            n = [[Note alloc] init];
            n.created = [NSDate date];
            n.owner = [AppModel sharedAppModel].player;
        }
        note = n; 
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    title = [[UITextField alloc] initWithFrame:CGRectMake(10, 10+64, self.view.bounds.size.width-20, 20)];
    title.delegate = self;
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20]; 
    title.placeholder = @"Title";
    title.returnKeyType = UIReturnKeyDone;
    
    date = [[UILabel alloc] initWithFrame:CGRectMake(10, 35+64, 65, 14)];  
    date.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
    date.textColor = [UIColor ARISColorDarkBlue];
    date.adjustsFontSizeToFitWidth = NO;
    
    owner = [[UILabel alloc] initWithFrame:CGRectMake(75, 35+64, self.view.bounds.size.width-85, 14)];
    owner.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    owner.adjustsFontSizeToFitWidth = NO;
    
    description = [[UITextView alloc] initWithFrame:CGRectMake(10, 49+64, self.view.bounds.size.width-20, 170)];   
    description.delegate = self;
    description.contentInset = UIEdgeInsetsZero; 
    description.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    descriptionDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [descriptionDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [descriptionDoneButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
    descriptionDoneButton.frame = CGRectMake(self.view.bounds.size.width-80, 219+64-18, 70, 18);
    [descriptionDoneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    descriptionDoneButton.hidden = YES;
    
    tagViewController = [[NoteTagEditorViewController alloc] initWithTags:note.tags delegate:self];
    tagViewController.view.frame = CGRectMake(0, 219+64, self.view.bounds.size.width, 30);
    contentsViewController = [[NoteContentsViewController alloc] initWithNoteContents:note.contents delegate:self];
    contentsViewController.view.frame = CGRectMake(0, 249+64, self.view.bounds.size.width, self.view.bounds.size.height-249-44-64);     
    
    UIView *bottombar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    locationPickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationPickerButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    locationPickerButton.frame = CGRectMake(10, 10, 24, 24);
    imagePickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imagePickerButton setImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal]; 
    imagePickerButton.frame = CGRectMake(44, 10, 24, 24); 
    audioPickerButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
    [audioPickerButton setImage:[UIImage imageNamed:@"microphone.png"] forState:UIControlStateNormal]; 
    audioPickerButton.frame = CGRectMake(78, 10, 24, 24); 
    shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage imageNamed:@"lock.png"] forState:UIControlStateNormal]; 
    shareButton.frame = CGRectMake(self.view.bounds.size.width-34, 10, 24, 24); 
    [bottombar addSubview:locationPickerButton];
    [bottombar addSubview:imagePickerButton]; 
    [bottombar addSubview:audioPickerButton]; 
    [bottombar addSubview:shareButton]; 
    
    [self.view addSubview:title];
    [self.view addSubview:date];
    [self.view addSubview:owner];
    [self.view addSubview:description];
    [self.view addSubview:descriptionDoneButton];
    [self.view addSubview:tagViewController.view];
    [self.view addSubview:contentsViewController.view];
    [self.view addSubview:bottombar]; 
    
    [self refreshViewFromNote];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([title.text isEqualToString:@""])
        [title becomeFirstResponder];
}

- (void) refreshViewFromNote
{
    if(!self.view) [self loadView];
    
    title.text = note.name; 
    NSDateFormatter *format = [[NSDateFormatter alloc] init]; 
    [format setDateFormat:@"MM/dd/yy"]; 
    date.text = [format stringFromDate:note.created]; 
    owner.text = note.owner.displayname; 
    [contentsViewController setContents:note.contents];
    //[tagViewController setTags:note.tags];
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    [title resignFirstResponder];
    return NO; //prevents \n from being added to description
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if([description.text isEqualToString:@""])
        [description becomeFirstResponder];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    descriptionDoneButton.hidden = NO; 
}

- (void) doneButtonPressed
{
    [description resignFirstResponder];
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    descriptionDoneButton.hidden = YES; 
}

@end

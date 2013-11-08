//
//  NoteEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "NoteEditorViewController.h"
#import "Note.h"
#import "UIColor+ARISColors.h"

@interface NoteEditorViewController ()
{
    Note *note;
    
    UITextField *title;
    UILabel *owner;
    UILabel *date;
    UITextView *description;
    UIButton *descriptionDoneButton;
    UIView *tagView;
    UIScrollView *mediaView;
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
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20]; 
    title.placeholder = @"Title";
    title.text = note.name;
    
    date = [[UILabel alloc] initWithFrame:CGRectMake(10, 35+64, 65, 14)];  
    date.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
    date.textColor = [UIColor ARISColorDarkBlue];
    date.adjustsFontSizeToFitWidth = NO;  
    NSDateFormatter *format = [[NSDateFormatter alloc] init]; 
    [format setDateFormat:@"MM/dd/yy"];
    date.text = [format stringFromDate:[NSDate date]];
    
    owner = [[UILabel alloc] initWithFrame:CGRectMake(75, 35+64, self.view.bounds.size.width-85, 14)];  
    owner.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
    owner.adjustsFontSizeToFitWidth = NO;
    owner.text = @"Phildo";
    
    description = [[UITextView alloc] initWithFrame:CGRectMake(10, 49+64, self.view.bounds.size.width-20, 170)];   
    description.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    descriptionDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [descriptionDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [descriptionDoneButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
    descriptionDoneButton.frame = CGRectMake(self.view.bounds.size.width-80, 219+64-18, 70, 18);
    
    tagView = [[UIView alloc] initWithFrame:CGRectMake(0, 219+64, self.view.bounds.size.width, 20)];    
    mediaView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 239+64, self.view.bounds.size.width, self.view.bounds.size.height-239-44-64)];     
    
    UIView *bottombar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    locationPickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imagePickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    audioPickerButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
    shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottombar addSubview:locationPickerButton];
    [bottombar addSubview:imagePickerButton]; 
    [bottombar addSubview:audioPickerButton]; 
    [bottombar addSubview:shareButton]; 
    
    [self.view addSubview:title];
    [self.view addSubview:date]; 
    [self.view addSubview:owner]; 
    [self.view addSubview:description]; 
    [self.view addSubview:descriptionDoneButton];  
    [self.view addSubview:tagView]; 
    [self.view addSubview:mediaView]; 
    [self.view addSubview:bottombar];  
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) refreshViewFromNote
{
    
}

@end

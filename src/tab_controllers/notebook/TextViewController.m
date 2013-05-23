//
//  NoteViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextViewController.h"
#import "Note.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"

@interface TextViewController() <UITextViewDelegate>
{
    Note *note;
    NoteContent *content;
    NSString *mode;

    IBOutlet UITextView *textBox;
    IBOutlet UIButton *keyboardButton;
    
    id<TextViewControllerDelegate> __unsafe_unretained delegate;
}

@property(nonatomic, strong) Note *note;
@property(nonatomic, strong) NoteContent *content;
@property(nonatomic, strong) NSString *mode;

@property(nonatomic, strong) IBOutlet UITextView *textBox;
@property(nonatomic, strong) IBOutlet UIButton *keyboardButton;

- (IBAction) saveButtonTouchAction;
- (IBAction) hideKeyboard;
- (void) updateContentTouchAction;

@end

@implementation TextViewController

@synthesize note;
@synthesize content;
@synthesize mode;
@synthesize textBox;
@synthesize keyboardButton;

- (id) initWithNote:(Note *)n content:(NoteContent *)c inMode:(NSString *)m delegate:(id<TextViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"TextViewController" bundle:nil])
    {
        delegate = d;
        self.note = n;
        self.content = c;
        self.mode = m;
        
        self.title = NSLocalizedString(@"TextViewTitleKey", @"");
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey", @"")
                                                                   style: UIBarButtonItemStyleBordered
                                                                  target:self 
                                                                  action:@selector(backButtonTouchAction)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    if(self.content)
    {
        self.textBox.text = self.content.text;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveKey", @"" )style:UIBarButtonItemStylePlain target:self action:@selector(updateContentTouchAction)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveKey", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTouchAction)];    
    }
    
    if([self.mode isEqualToString:@"preview"])
        self.textBox.userInteractionEnabled = NO;
    else
        [self.textBox becomeFirstResponder];
}

- (void) backButtonTouchAction
{
    [delegate textViewControllerCancelled];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    if([self.mode isEqualToString:@"preview"])
    {
        self.textBox.userInteractionEnabled = NO;
        self.textBox.frame = CGRectMake(0, 0, 320, 367);
    }
    else self.textBox.frame = CGRectMake(0, 0, 320, 330);
}

-(void)updateContentTouchAction
{
    [delegate textUpdated:self.textBox.text forContent:self.content];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if([self.textBox.text isEqualToString:@"Write note here..."])
        [self.textBox setText:@""];
    self.textBox.frame = CGRectMake(0, 0, 320, 230);
}

-(void)hideKeyboard
{
    [self.textBox resignFirstResponder];
    if([self.mode isEqualToString:@"edit"])
        self.textBox.frame = CGRectMake(0, 0, 320, 330);
    else
        self.textBox.frame = CGRectMake(0, 0, 320, 367);
}

-(void)saveButtonTouchAction
{
    [delegate textChosen:self.textBox.text];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations]; 
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
    if([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}


@end

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
#import "UIColor+ARISColors.h"

@interface TextViewController() <UITextViewDelegate>
{
    Note *note;
    NoteContent *content;
    NSString *mode;

    UITextView *textBox;
    UIButton *keyboardButton;
    
    BOOL hasAppeared;
    id<TextViewControllerDelegate> __unsafe_unretained delegate;
}

@property(nonatomic, strong) Note *note;
@property(nonatomic, strong) NoteContent *content;
@property(nonatomic, strong) NSString *mode;

@property(nonatomic, strong) UITextView *textBox;
@property(nonatomic, strong) UIButton *keyboardButton;

@end

@implementation TextViewController

@synthesize note;
@synthesize content;
@synthesize mode;
@synthesize textBox;
@synthesize keyboardButton;

- (id) initWithNote:(Note *)n content:(NoteContent *)c inMode:(NSString *)m delegate:(id<TextViewControllerDelegate>)d
{
    if(self = [super init])
    {
        hasAppeared = NO;
        delegate = d;
        self.note = n;
        self.content = c;
        self.mode = m;
        
        self.title = NSLocalizedString(@"TextViewTitleKey", @"");
    }
    return self;
}

- (void) loadView
{
    [super loadView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(hasAppeared) return;
    hasAppeared = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.textBox = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textBox.delegate = self;
    self.textBox.contentSize = CGSizeMake(self.view.bounds.size.width,self.view.bounds.size.height-64-44);
    self.textBox.contentInset = UIEdgeInsetsMake(64,0,44,0);
    [self.view addSubview:self.textBox];
    
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    goButton.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
    [goButton setBackgroundColor:[UIColor ARISColorTextBackdrop]];
    goButton.titleEdgeInsets = UIEdgeInsetsMake(0,0,0,30);
    [goButton setTitleColor:[UIColor ARISColorText] forState:UIControlStateNormal];
    [goButton setTitle:NSLocalizedString(@"SaveKey",@"Save") forState:UIControlStateNormal];
    [goButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    UIImageView *continueArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    continueArrow.frame = CGRectMake(self.view.bounds.size.width-25, 14, 19, 19);
    [goButton addSubview:continueArrow];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 1)];
    line.backgroundColor = [UIColor ARISColorLightGray];
    [goButton addSubview:line];
    [self.view addSubview:goButton];
    
    if(self.content)
    {
        self.textBox.text = self.content.text;
        [goButton addTarget:self action:@selector(updateContentTouched) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else
        [goButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    if([self.mode isEqualToString:@"preview"])
        self.textBox.userInteractionEnabled = NO;
    else
        [self.textBox becomeFirstResponder];
}

- (void) backButtonTouched
{
    [delegate textViewControllerCancelled];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)updateContentTouched
{
    [delegate textUpdated:self.textBox.text forContent:self.content];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) saveButtonTouched
{
    [delegate textChosen:self.textBox.text];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if([self.textBox.text isEqualToString:@"Write note here..."])
        [self.textBox setText:@""];
    self.textBox.frame = CGRectMake(0, 0, 320, 230);
}

- (void) hideKeyboard
{
    [self.textBox resignFirstResponder];
    if([self.mode isEqualToString:@"edit"])
        self.textBox.frame = CGRectMake(0, 0, 320, 330);
    else
        self.textBox.frame = CGRectMake(0, 0, 320, 367);
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

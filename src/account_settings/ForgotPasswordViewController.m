//
//  ForgotPasswordViewController.m
//  ARIS
//
//  Created by Brian Thiel on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "AppModel.h"

@interface ForgotPasswordViewController() <UITextFieldDelegate>
{
    UITextField *emailField;
    UILabel *instructions;
    BOOL viewHasAppeared;
    id<ForgotPasswordViewControllerDelegate> delegate;
}

@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UILabel *instructions;

@end

@implementation ForgotPasswordViewController

@synthesize emailField;
@synthesize instructions;

- (id) initWithDelegate:(id<ForgotPasswordViewControllerDelegate>)d
{
    if(self = [super init])
    {
        viewHasAppeared = NO;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorWhite];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(viewHasAppeared) return;
    viewHasAppeared = YES;

    UIView *titleContainer = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    UIImageView *logoText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
    logoText.frame = CGRectMake(titleContainer.frame.size.width/2-50, titleContainer.frame.size.height/2-15, 100, 30);
    [titleContainer addSubview:logoText];
    self.navigationItem.titleView = titleContainer;
    [self.navigationController.navigationBar layoutIfNeeded];

    emailField = [[UITextField alloc] initWithFrame:CGRectMake(20,66+20,self.view.frame.size.width-40,20)];
    emailField.font = [ARISTemplate ARISInputFont];
    emailField.delegate = self;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.placeholder = NSLocalizedString(@"EmailToResetKey", @"");
    emailField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:emailField];

    UIView *line;
    line = [[UIView alloc] initWithFrame:CGRectMake(20,66+20+20+5,self.view.frame.size.width-40, 1)];
    line.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    [self.view addSubview:line];

    instructions = [[UILabel alloc] initWithFrame:CGRectMake(20,66+20+20+20,self.view.frame.size.width-40,80)];
    instructions.numberOfLines = 0;
    instructions.lineBreakMode = NSLineBreakByWordWrapping;
    instructions.text = NSLocalizedString(@"EmailInstructionsKey", @"");
    [self.view addSubview:instructions];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,19,19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [_MODEL_ resetPasswordForEmail:textField.text];
    [self dismissSelf];
    return YES;
}

- (void) backButtonTouched
{
    [self dismissSelf];
}

- (void) dismissSelf
{
    if(delegate) [delegate forgotPasswordWasDismissed];
    else [self.navigationController popViewControllerAnimated:YES];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL) shouldAutorotate
{
  return NO;
}

@end

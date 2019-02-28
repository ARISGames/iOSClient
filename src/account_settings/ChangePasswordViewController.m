//
//  ChangePasswordViewController.m
//  ARIS
//
//  Created by Brian Thiel on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AppModel.h"

@interface ChangePasswordViewController() <UITextFieldDelegate>
{
    UITextField *oldPasswordField;
    UITextField *newPasswordField;
    UILabel *instructions;
    UIView *line;
    id<ChangePasswordViewControllerDelegate> delegate;
}

@end

@implementation ChangePasswordViewController

- (id) initWithDelegate:(id<ChangePasswordViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorWhite];

    oldPasswordField = [[UITextField alloc] init];
    oldPasswordField.font = [ARISTemplate ARISInputFont];
    oldPasswordField.delegate = self;
    oldPasswordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    oldPasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
    oldPasswordField.placeholder = @"Old Password";
    oldPasswordField.secureTextEntry = YES;
    oldPasswordField.clearButtonMode = UITextFieldViewModeAlways;

    newPasswordField = [[UITextField alloc] init];
    newPasswordField.font = [ARISTemplate ARISInputFont];
    newPasswordField.delegate = self;
    newPasswordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    newPasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
    newPasswordField.placeholder = @"New Password";
    newPasswordField.secureTextEntry = YES;
    newPasswordField.clearButtonMode = UITextFieldViewModeAlways;

    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];

    instructions = [[UILabel alloc] init];
    instructions.numberOfLines = 0;
    instructions.lineBreakMode = NSLineBreakByWordWrapping;
    instructions.text = @"Enter old and new password to change";

    [self.view addSubview:oldPasswordField];
    [self.view addSubview:newPasswordField];
    [self.view addSubview:line];
    [self.view addSubview:instructions];
}

- (void) viewWillLayoutSubviews
{
    oldPasswordField.frame = CGRectMake(20,66+20,self.view.frame.size.width-40,20);
    newPasswordField.frame = CGRectMake(20,66+20+30,self.view.frame.size.width-40,20);
    line.frame = CGRectMake(20,66+20+30+30,self.view.frame.size.width-40, 1);
    instructions.frame = CGRectMake(20,66+20+20+20+20,self.view.frame.size.width-40,80);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIView *titleContainer = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    UIImageView *logoText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
    logoText.frame = CGRectMake(titleContainer.frame.size.width/2-50, titleContainer.frame.size.height/2-15, 100, 30);
    [titleContainer addSubview:logoText];
    self.navigationItem.titleView = titleContainer;
    [self.navigationController.navigationBar layoutIfNeeded];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 27, 27);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [oldPasswordField becomeFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if     ([oldPasswordField.text isEqualToString:@""]) [oldPasswordField becomeFirstResponder];
    else if([newPasswordField.text isEqualToString:@""]) [newPasswordField becomeFirstResponder];
    else
    {
        [textField resignFirstResponder];
        [_MODEL_ changePasswordFrom:oldPasswordField.text to:newPasswordField.text];
        oldPasswordField.text = @"";
        newPasswordField.text = @"";
        [self dismissSelf];
    }
    return YES;
}

- (void) backButtonTouched
{
    [self dismissSelf];
}

- (void) dismissSelf
{
    if(delegate) [delegate changePasswordWasDismissed];
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

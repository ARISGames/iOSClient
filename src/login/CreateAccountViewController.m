//
//  CreateAccountViewController.m
//  ARIS
//
//  Created by David Gagnon on 5/14/09.
//  Copyright 2009 . All rights reserved.
//

#import "CreateAccountViewController.h"
#import "AppModel.h"
#import "ARISAlertHandler.h"

@interface CreateAccountViewController() <UITextFieldDelegate, UITextViewDelegate>
{
    UIView *titleContainer;
	UITextField *usernameField;
	UITextField *passwordField;
	UITextField *emailField;
	UIButton *createAccountButton;
    
    UIView *line1;
    UIView *line2;
    UIView *line3;
    UIView *line4;
    
    UIButton *backButton;

    id<CreateAccountViewControllerDelegate> __unsafe_unretained delegate;
}
    
@end

@implementation CreateAccountViewController

- (id)initWithDelegate:(id<CreateAccountViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        self.title = NSLocalizedString(@"CreateAccountTitleKey", @""); 
        _ARIS_NOTIF_LISTEN_(@"MODEL_LOGGED_IN",self,@selector(dismissSelf),nil); 
        _ARIS_NOTIF_LISTEN_(@"MODEL_LOGIN_FAILED",self,@selector(loginFailed),nil); 
	}
	
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorWhite];
    
    long navOffset = 66;
    
    titleContainer = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    UIImageView *logoText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
    logoText.frame = CGRectMake(titleContainer.frame.size.width/2-50, titleContainer.frame.size.height/2-15, 100, 30);
    [titleContainer addSubview:logoText];
    
    line1 = [[UIView alloc] initWithFrame:CGRectMake(20,navOffset+20+20+5,self.view.frame.size.width-40, 1)];
    line1.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    [self.view addSubview:line1];
    line2 = [[UIView alloc] initWithFrame:CGRectMake(20,navOffset+20+20+20+20+5, self.view.frame.size.width-40, 1)];
    line2.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    [self.view addSubview:line2];
    line3 = [[UIView alloc] initWithFrame:CGRectMake(20,navOffset+20+20+20+20+20+20+5, self.view.frame.size.width-40, 1)];
    line3.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    [self.view addSubview:line3];
    line4 = [[UIView alloc] initWithFrame:CGRectMake(20,navOffset+20+20+5,self.view.frame.size.width-40, 1)];
    line4.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    [self.view addSubview:line4];
    
    usernameField = [[UITextField alloc] initWithFrame:CGRectMake(20,navOffset+20,self.view.frame.size.width-40,20)];
    usernameField.font = [ARISTemplate ARISInputFont];
    usernameField.delegate = self;
    usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    usernameField.placeholder = @"ARIS ID";
    usernameField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:usernameField];
    
    passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20,navOffset+20+20+20,self.view.frame.size.width-40,20)];
    passwordField.font = [ARISTemplate ARISInputFont];
    passwordField.delegate = self;
    passwordField.secureTextEntry = YES;
	passwordField.placeholder = NSLocalizedString(@"PasswordKey",@"");
    passwordField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:passwordField];
    
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(20,navOffset+20+20+20+20+20,self.view.frame.size.width-40,20)];
    emailField.font = [ARISTemplate ARISInputFont];
    emailField.delegate = self;
	emailField.placeholder = NSLocalizedString(@"EmailKey",@"");
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:emailField];
    
    createAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createAccountButton.backgroundColor = [UIColor clearColor];
    [createAccountButton setBackgroundImage:[UIImage imageNamed:@"arrowForward"] forState:UIControlStateNormal];
    [createAccountButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
    [createAccountButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    createAccountButton.accessibilityLabel = @"CreateAccount";
    createAccountButton.frame = CGRectMake(self.view.frame.size.width-50, navOffset+20+20+20+20+20+20+20, 20, 20);
    [createAccountButton addTarget:self action:@selector(createAccountButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createAccountButton];
        
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,19,19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView = titleContainer;
    [self.navigationController.navigationBar layoutIfNeeded];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    long navOffset = 66;
    
    line4.frame = CGRectMake(20,navOffset+20+20+5,self.view.frame.size.width-40, 1);
    line3.frame = CGRectMake(20,navOffset+20+20+20+20+20+20+5, self.view.frame.size.width-40, 1);
    line2.frame = CGRectMake(20,navOffset+20+20+20+20+5, self.view.frame.size.width-40, 1);
    line1.frame = CGRectMake(20,navOffset+20+20+5,self.view.frame.size.width-40, 1);
    
    usernameField.frame = CGRectMake(20,navOffset+20,self.view.frame.size.width-40,20);
    passwordField.frame = CGRectMake(20,navOffset+20+20+20,self.view.frame.size.width-40,20);
    createAccountButton.frame = CGRectMake(self.view.frame.size.width-50, navOffset+20+20+20+20+20+20+20, 20, 20);
    emailField.frame = CGRectMake(20,navOffset+20+20+20+20+20,self.view.frame.size.width-40,20);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[usernameField becomeFirstResponder];
}

- (void) attemptRegistration
{
    [_MODEL_ createAccountWithUserName:usernameField.text displayName:@"" groupName:@"" email:emailField.text password:passwordField.text];
}

- (void) createAccountButtonTouched
{
    [self attemptRegistration];
}
	
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if(textField == usernameField) [passwordField becomeFirstResponder];
	if(textField == passwordField) [emailField becomeFirstResponder];
	if(textField == emailField)    [self attemptRegistration];
    return YES;
}

- (void) loginFailed
{
    //[[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:@"Login Failed" message:@"Username taken"];
}

- (void) backButtonTouched
{
    [self dismissSelf];
}

- (void) dismissSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dealloc
{    
    _ARIS_NOTIF_IGNORE_ALL_(self);                                
}

@end

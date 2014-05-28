//
//  SelfRegistrationViewController.m
//  ARIS
//
//  Created by David Gagnon on 5/14/09.
//  Copyright 2009 . All rights reserved.
//

#import "SelfRegistrationViewController.h"
#import "AppServices.h"
#import "ARISServiceResult.h"
#import "ARISAlertHandler.h"
#import "ARISTemplate.h"

@interface SelfRegistrationViewController() <UITextFieldDelegate, UITextViewDelegate>
{
	UITextField *usernameField;
	UITextField *passwordField;
	UITextField *emailField;
	UIButton *createAccountButton;

    BOOL viewHasAppeared;
    id<SelfRegistrationViewControllerDelegate> __unsafe_unretained delegate;
}
    
@property (nonatomic) UITextField *usernameField;
@property (nonatomic) UITextField *passwordField;
@property (nonatomic) UITextField *emailField;
    
@end

@implementation SelfRegistrationViewController

@synthesize usernameField;
@synthesize passwordField;
@synthesize emailField;

- (id)initWithDelegate:(id<SelfRegistrationViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        self.title = NSLocalizedString(@"SelfRegistrationTitleKey", @""); 
        viewHasAppeared = NO;
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
    
    int navOffset = 66;
    
    UIView *titleContainer = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    UIImageView *logoText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
    logoText.frame = CGRectMake(titleContainer.frame.size.width/2-50, titleContainer.frame.size.height/2-15, 100, 30);
    [titleContainer addSubview:logoText];
    self.navigationItem.titleView = titleContainer;
    [self.navigationController.navigationBar layoutIfNeeded];
    
    usernameField = [[UITextField alloc] initWithFrame:CGRectMake(20,navOffset+20,self.view.frame.size.width-40,20)];
    usernameField.font = [ARISTemplate ARISInputFont];
    usernameField.delegate = self;
    usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    usernameField.placeholder = @"ARIS ID";
    usernameField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:usernameField];
    
    UIView *line;
    line = [[UIView alloc] initWithFrame:CGRectMake(20,navOffset+20+20+5,self.view.frame.size.width-40, 1)];
    line.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    [self.view addSubview:line];

    passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20,navOffset+20+20+20,self.view.frame.size.width-40,20)];
    passwordField.font = [ARISTemplate ARISInputFont];
    passwordField.delegate = self;
    passwordField.secureTextEntry = YES;
	passwordField.placeholder = NSLocalizedString(@"PasswordKey",@"");
    passwordField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:passwordField];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(20,navOffset+20+20+20+20+5, self.view.frame.size.width-40, 1)];
    line.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    [self.view addSubview:line];

    emailField = [[UITextField alloc] initWithFrame:CGRectMake(20,navOffset+20+20+20+20+20,self.view.frame.size.width-40,20)];
    emailField.font = [ARISTemplate ARISInputFont];
    emailField.delegate = self;
	emailField.placeholder = NSLocalizedString(@"EmailKey",@"");
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:emailField];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(20,navOffset+20+20+20+20+20+20+5, self.view.frame.size.width-40, 1)];
    line.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    [self.view addSubview:line];
    
    createAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createAccountButton.backgroundColor = [UIColor clearColor];
    [createAccountButton setTitle:@">" forState:UIControlStateNormal];
    [createAccountButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
    [createAccountButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    createAccountButton.frame = CGRectMake(self.view.frame.size.width-60,navOffset+20+20+20+20+20+20, 40, 40);
    [createAccountButton addTarget:self action:@selector(createAccountButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createAccountButton];
    
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
	[usernameField becomeFirstResponder];
}

- (void) attemptRegistration
{
  _ARIS_NOTIF_LISTEN_(@"RegistrationResponseReady",self,@selector(registrationResponseReady:),nil);
    //[_SERVICES_ registerNewUser:self.usernameField.text password:self.passwordField.text firstName:@"" lastName:@"" email:self.emailField.text];
}

//PHIL should refactor to return the equivalent of the login package so we don't have to immediately log in
- (void) registrationResponseReady:(NSNotification *)n
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RegistrationResponseReady" object:nil];
    ARISServiceResult *r = (ARISServiceResult *)[n.userInfo objectForKey:@"result"];

	if([(NSDecimalNumber*)r.resultData intValue] > 0) //There exists a new user_id
        [delegate registrationSucceededWithUsername:usernameField.text password:passwordField.text];
    else
    {
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ErrorKey", @"") message:NSLocalizedString(@"SelfRegistrationErrorMessageKey", @"")];
	}
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

- (void)dealloc
{    
    _ARIS_NOTIF_IGNORE_ALL_(self);                                
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void) backButtonTouched
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

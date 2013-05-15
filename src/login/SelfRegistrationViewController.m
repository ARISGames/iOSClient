//
//  SelfRegistrationViewController.m
//  ARIS
//
//  Created by David Gagnon on 5/14/09.
//  Copyright 2009 . All rights reserved.
//

#import "SelfRegistrationViewController.h"
#import "AppServices.h"
#import "ServiceResult.h"

@interface SelfRegistrationViewController()
{
    id<SelfRegistrationViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation SelfRegistrationViewController

@synthesize userName;
@synthesize password;
@synthesize email;

- (id)initWithDelegate:(id<SelfRegistrationViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"SelfRegistrationViewController" bundle:nil])
    {
        delegate = d;
        self.title = NSLocalizedString(@"SelfRegistrationTitleKey", @""); 
	}
	
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

	userName.placeholder = NSLocalizedString(@"UsernameKey",@"");
	password.placeholder = NSLocalizedString(@"PasswordKey",@"");
	email.placeholder    = NSLocalizedString(@"EmailKey",@"");
	[createAccountButton setTitle:NSLocalizedString(@"CreateAccountKey",@"") forState:UIControlStateNormal];
	
	[userName becomeFirstResponder];
}

- (void) attemptRegistration
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationResponseReady:) name:@"RegistrationResponseReady" object:nil];
    [[AppServices sharedAppServices] registerNewUser:self.userName.text password:self.password.text firstName:@"" lastName:@"" email:self.email.text];
}

//PHIL should refactor to return the equivalent of the login package so we don't have to immediately log in
- (void) registrationResponseReady:(NSNotification *)n
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RegistrationResponseReady" object:nil];
    ServiceResult *r = (ServiceResult *)[n.userInfo objectForKey:@"result"];

	if([(NSDecimalNumber*)r.data intValue] > 0) //There exists a new playerId
        [delegate registrationSucceededWithUsername:userName.text password:password.text];
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorKey", @"")
                                                        message:NSLocalizedString(@"SelfRegistrationErrorMessageKey", @"")
													   delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
                                              otherButtonTitles:nil];
		[alert show];
	}
}

- (IBAction) submitButtonTouched:(id)sender
{
    [self attemptRegistration];
}
	
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if(textField == userName) [password becomeFirstResponder];
	if(textField == password) [email becomeFirstResponder];
	if(textField == email)    [self attemptRegistration];
    return YES;
}

- (void)dealloc
{    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

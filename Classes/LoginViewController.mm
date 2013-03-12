//
//  LoginViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "LoginViewController.h"
#import "SelfRegistrationViewController.h"
#import "ARISAppDelegate.h"
#import "ChangePasswordViewController.h"
#import "ForgotViewController.h"
#import "QRCodeReader.h"
#import "BumpTestViewController.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self)
    {
        self.title = NSLocalizedString(@"LoginTitleKey", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    usernameField.placeholder = NSLocalizedString(@"UsernameKey", @"");
    passwordField.placeholder = NSLocalizedString(@"PasswordKey", @"");
    [loginButton setTitle:NSLocalizedString(@"LoginKey",@"") forState:UIControlStateNormal];
    newAccountMessageLabel.text = NSLocalizedString(@"NewAccountMessageKey", @"");
    [newAccountButton setTitle:NSLocalizedString(@"CreateAccountKey",@"") forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameField)
        [passwordField becomeFirstResponder];
    if(textField == passwordField)
        [self loginButtonTouched:self];
    return YES;
}

//Makes keyboard disappear on touch outside of keyboard or textfield
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
}

-(IBAction)loginButtonTouched:(id)sender
{
    [[RootViewController sharedRootViewController] attemptLoginWithUserName:usernameField.text andPassword:passwordField.text andGameId:0 inMuseumMode:false];

    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
}

-(IBAction)QRButtonTouched
{
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    
    widController.readers = [[NSMutableSet alloc ] initWithObjects:[[QRCodeReader alloc] init], nil];
    [self presentModalViewController:widController animated:NO];
}

-(void)changePassTouch
{
    ForgotViewController *forgotPassViewController = [[ForgotViewController alloc] initWithNibName:@"ForgotViewController" bundle:[NSBundle mainBundle]];
    [[self navigationController] pushViewController:forgotPassViewController animated:NO];
}

-(IBAction)newAccountButtonTouched:(id)sender
{
    SelfRegistrationViewController *selfRegistrationViewController = [[SelfRegistrationViewController alloc] initWithNibName:@"SelfRegistration" bundle:[NSBundle mainBundle]];
    [[self navigationController] pushViewController:selfRegistrationViewController animated:NO];
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    [self dismissModalViewControllerAnimated:NO];
    if([result isEqualToString:@"TEST_BUMP"])
    {
        BumpTestViewController *b = [[BumpTestViewController alloc] initWithNibName:@"BumpTestViewController" bundle:nil];
        [self presentViewController:b animated:NO completion:nil];
    }
    else
    {
        NSArray *terms  = [result componentsSeparatedByString:@","];
        if([terms count] > 1)
        {
            int gameId = 0;
            bool create;
            bool museumMode;
            
            if([terms count] > 0) create = [[terms objectAtIndex:0] boolValue];
            if(create)
            {
                if([terms count] > 1) usernameField.text = [terms objectAtIndex:1]; //Group Name
                if([terms count] > 2) gameId = [[terms objectAtIndex:2] intValue];
                if([terms count] > 3) museumMode = [[terms objectAtIndex:3] boolValue];
                [[RootViewController sharedRootViewController] createUserAndLoginWithGroup:usernameField.text andGameId:gameId inMuseumMode:museumMode];
            }
            else
            {
                if([terms count] > 1) usernameField.text = [terms objectAtIndex:1]; //Username
                if([terms count] > 2) passwordField.text = [terms objectAtIndex:2]; //Password
                if([terms count] > 3) gameId = [[terms objectAtIndex:3] intValue];
                if([terms count] > 4) museumMode = [[terms objectAtIndex:4] boolValue];
                [[RootViewController sharedRootViewController] attemptLoginWithUserName:usernameField.text andPassword:passwordField.text andGameId:gameId inMuseumMode:museumMode];
            }
        }
    }
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    [self dismissModalViewControllerAnimated:NO];
}

@end

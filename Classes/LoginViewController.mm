//
//  LoginViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "QRScannerViewController.h"

#import "LoginViewController.h"
#import "SelfRegistrationViewController.h"
#import "ARISAppDelegate.h"
#import "ChangePasswordViewController.h"
#import "ForgotViewController.h"

#import "Decoder.h"
#import <QRCodeReader.h>
#import "ZBarReaderViewController.h"


@implementation LoginViewController



//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"LoginTitleKey", @"");
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
    [AppModel sharedAppModel].inGame = NO;
	usernameField.placeholder = NSLocalizedString(@"UsernameKey", @"");
	passwordField.placeholder = NSLocalizedString(@"PasswordKey", @"");
	[loginButton setTitle:NSLocalizedString(@"LoginKey",@"") forState:UIControlStateNormal];
	newAccountMessageLabel.text = NSLocalizedString(@"NewAccountMessageKey", @"");
	[newAccountButton setTitle:NSLocalizedString(@"CreateAccountKey",@"") forState:UIControlStateNormal];
		
	NSLog(@"Login View Loaded");
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameField) {
		[passwordField becomeFirstResponder];
	}	
	if(textField == passwordField) {
		[self loginButtonTouched:self];
	}

    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(IBAction)loginButtonTouched: (id) sender {
	NSLog(@"Login: Login Button Touched");

	[[RootViewController sharedRootViewController] attemptLoginWithUserName:usernameField.text andPassword:passwordField.text andGameId:0 inMuseumMode:false];
    
	[usernameField resignFirstResponder];
	[passwordField resignFirstResponder];
}

-(IBAction)QRButtonTouched:(id)sender
{
    NSLog(@"LoginViewController: QR Scan Button Pressed");
	
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
    widController.readers = readers;
    [self presentViewController:widController animated:YES completion:nil];
}
-(void)changePassTouch{
    NSLog(@"Login: Change Password Button Touched");
	ForgotViewController *forgotPassViewController = [[ForgotViewController alloc] 
                                                                      initWithNibName:@"ForgotViewController" bundle:[NSBundle mainBundle]];
	//Put the view on the screen
	[[self navigationController] pushViewController:forgotPassViewController animated:YES];
}
-(IBAction)newAccountButtonTouched: (id) sender{
	NSLog(@"Login: New User Button Touched");
	SelfRegistrationViewController *selfRegistrationViewController = [[SelfRegistrationViewController alloc] 
															initWithNibName:@"SelfRegistration" bundle:[NSBundle mainBundle]];
	//Put the view on the screen
	[[self navigationController] pushViewController:selfRegistrationViewController animated:YES];
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)resultString {
    [controller dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"LoginViewController: Scan result: %@",resultString);
    NSArray *terms  = [resultString componentsSeparatedByString:@","];
    if([terms count] > 1)
    {
        int gameId = 0;
        bool museumMode = false;
        if([terms count] > 0) usernameField.text = [terms objectAtIndex:0]; //Username
        if([terms count] > 1) passwordField.text = [terms objectAtIndex:1]; //Password
        if([terms count] > 2) gameId = [[terms objectAtIndex:2] intValue];
        if([terms count] > 3) museumMode = [[terms objectAtIndex:3] boolValue];
        [[RootViewController sharedRootViewController] attemptLoginWithUserName:usernameField.text andPassword:passwordField.text andGameId:gameId inMuseumMode:museumMode];
    }
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [controller dismissViewControllerAnimated:NO completion:nil];
}

@end
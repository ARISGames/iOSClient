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

	ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate attemptLoginWithUserName:usernameField.text andPassword:passwordField.text]; 
    UINavigationController *tempNC;
    for(int i = 0; i < [appDelegate.gameSelectionTabBarController.viewControllers count];i++)
    {
	tempNC = [appDelegate.gameSelectionTabBarController.viewControllers objectAtIndex:i];	
        UIViewController *vc = [tempNC.viewControllers objectAtIndex:0];
        if ([vc respondsToSelector:@selector(refresh)]) [vc performSelector:@selector(refresh)];
    }
	[usernameField resignFirstResponder];
	[passwordField resignFirstResponder];
}

-(IBAction)newAccountButtonTouched: (id) sender{
	NSLog(@"Login: New User Button Touched");
	SelfRegistrationViewController *selfRegistrationViewController = [[SelfRegistrationViewController alloc] 
															initWithNibName:@"SelfRegistration" bundle:[NSBundle mainBundle]];
	
	//Put the view on the screen
	[[self navigationController] pushViewController:selfRegistrationViewController animated:YES];
	[selfRegistrationViewController release];
	
}


- (void)dealloc {
	[usernameField release];
	[passwordField release];
	[loginButton release];
	[newAccountMessageLabel release];
	[newAccountButton release];
    [super dealloc];
}


@end

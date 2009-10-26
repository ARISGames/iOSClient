//
//  LoginViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "LoginViewController.h"
#import "SelfRegistrationViewController.h"


@implementation LoginViewController

@synthesize username;
@synthesize password;
@synthesize login;
//@synthesize titleItem;


//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Login to ARIS";
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[login addTarget:self action:@selector(performLogin) forControlEvents:UIControlEventTouchUpInside];
	
	NSLog(@"Login View Loaded");
}

-(void) setModel:(AppModel *)model {
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	
	NSLog(@"Login: Model Set");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == username) {
		[password becomeFirstResponder];
	}	
	if(textField == password) {
		[self performLogin];
	}

    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)performLogin {
	
	NSArray *keys = [NSArray arrayWithObjects:@"username", @"password", nil];
	NSArray *objects = [NSArray arrayWithObjects:username.text, password.text, nil];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	NSNotification *loginNotification = [NSNotification notificationWithName:@"PerformUserLogin" object:self userInfo:dictionary];
	[[NSNotificationCenter defaultCenter] postNotification:loginNotification];
	
	[username resignFirstResponder];
	[password resignFirstResponder];
}

-(IBAction)newUserButtonTouched: (id) sender{
	NSLog(@"Login: New User Button Touched");
	SelfRegistrationViewController *selfRegistrationViewController = [[SelfRegistrationViewController alloc] 
															initWithNibName:@"SelfRegistration" bundle:[NSBundle mainBundle]];
	[selfRegistrationViewController setModel:appModel];
	
	//Put the view on the screen
	[[self navigationController] pushViewController:selfRegistrationViewController animated:YES];
	
}

- (void)dealloc {
	[username release];
	[password release];
	[login release];
    [super dealloc];
}


@end

//
//  LoginViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "LoginViewController.h"


@implementation LoginViewController

@synthesize username;
@synthesize password;
@synthesize login;
@synthesize titleItem;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[login addTarget:self action:@selector(performLogin) forControlEvents:UIControlEventTouchUpInside];
	
	NSLog(@"Login View Loaded");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //NSLog(@"%@ textFieldShouldReturn", [self class]);	
	if(textField == password) {
		[self performLogin];
	}
    // do stuff with the text
   // NSLog(@"text = %@", [theTextField text]);
    return YES;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark custom methods and logic

- (void)fadeIn {
	self.view.alpha = 0;
	
	[UIView beginAnimations:nil context:nil];
	self.view.alpha = 1;
	[UIView commitAnimations];
}

- (void)fadeOut {
	self.view.alpha = 1;
	
	[UIView beginAnimations:nil context:nil];
	self.view.alpha = 0;
	[UIView commitAnimations];
}

-(void) setNavigationTitle:(NSString *)title {
	titleItem.title = title;
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


- (void)dealloc {
	[titleItem release];
	[username release];
	[password release];
	[login release];
    [super dealloc];
}


@end

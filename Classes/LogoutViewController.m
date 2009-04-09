//
//  UpdatesViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "LogoutViewController.h"


@implementation LogoutViewController

@synthesize moduleName;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
	NSLog(@"Logout View Controller Loaded");
}


- (IBAction)logoutButtonPressed: (id) sender {
	NSLog(@"Logout Requested");
	
	NSNotification *logoutRequestNotification = [NSNotification notificationWithName:@"LogoutRequested" object:self];
	[[NSNotificationCenter defaultCenter] postNotification:logoutRequestNotification];

	
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[moduleName release];
    [super dealloc];
}


@end

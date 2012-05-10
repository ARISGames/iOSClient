//
//  UpdatesViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "LogoutViewController.h"


@implementation LogoutViewController


//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"LogoutTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"298-circlex"];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	warningLabel.text = NSLocalizedString(@"LogoutWarningKey", @"");
	[logoutButton setTitle:NSLocalizedString(@"LogoutKey",@"") forState:UIControlStateNormal];
	
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




@end

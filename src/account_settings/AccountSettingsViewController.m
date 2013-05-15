//
//  AccountSettingsViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "ForgotPasswordViewController.h"

@interface AccountSettingsViewController()
{
    id<AccountSettingsViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation AccountSettingsViewController

- (id)initWithDelegate:(id<AccountSettingsViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"AccountSettingsViewController" bundle:nil])
    {
        delegate = d;
        self.title = @"Account Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	warningLabel.text = NSLocalizedString(@"LogoutWarningKey", @"");
	[logoutButton setTitle:NSLocalizedString(@"LogoutKey",@"") forState:UIControlStateNormal];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouched)];
	self.navigationItem.leftBarButtonItem = backButton;
}

- (IBAction)logoutButtonPressed:(id)sender
{
	[delegate logoutWasRequested];
}

- (IBAction)passButtonPressed:(id)sender
{
	ForgotPasswordViewController *forgotPassViewController = [[ForgotPasswordViewController alloc] init];
	[[self navigationController] pushViewController:forgotPassViewController animated:YES];
}

- (IBAction)profileButtonPressed:(id)sender
{
    [delegate playerSettingsRequested];
}

- (void) backButtonTouched
{
    [delegate accountSettingsWereDismissed];
}

@end
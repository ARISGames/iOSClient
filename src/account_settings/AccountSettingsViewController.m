//
//  AccountSettingsViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "ForgotPasswordViewController.h"
#import "ARISTemplate.h"

@interface AccountSettingsViewController()
{
    BOOL hasAppeared;
    id<AccountSettingsViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation AccountSettingsViewController

- (id)initWithDelegate:(id<AccountSettingsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        hasAppeared = NO;
        delegate = d;
        self.title = @"Account Settings";
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(hasAppeared) return;
    hasAppeared = YES;
    
    UIView *logoContainer = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    UIImageView *logoText  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
    logoText.frame = CGRectMake(logoContainer.frame.size.width/2-50, logoContainer.frame.size.height/2-15, 100, 30);
    [logoContainer addSubview:logoText];
    self.navigationItem.titleView = logoContainer;
    
    UIButton *profileButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, 40)];
	[profileButton setTitle:@"Public Name and Image" forState:UIControlStateNormal];
	[profileButton setTitleColor:[UIColor ARISColorBlack] forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(profileButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:profileButton];
    
    UIButton *passButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 144, self.view.bounds.size.width, 40)];
	[passButton setTitle:@"Change Password" forState:UIControlStateNormal];
	[passButton setTitleColor:[UIColor ARISColorBlack] forState:UIControlStateNormal];
    [passButton addTarget:self action:@selector(passButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:passButton];
    
    UIView *logoutButton = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-44,self.view.bounds.size.width,44)];
    UILabel *logoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(30,0,self.view.bounds.size.width-30,44)];
    logoutLabel.textAlignment = NSTextAlignmentLeft;
    logoutLabel.font = [ARISTemplate ARISButtonFont];
    logoutLabel.text = NSLocalizedString(@"LogoutKey",@"");
    logoutLabel.textColor = [ARISTemplate ARISColorText];
    UIImageView *leaveGameArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowBack"]];
    
    leaveGameArrow.frame = CGRectMake(6,13,19,19);
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,1)];
    line.backgroundColor = [UIColor ARISColorLightGray];
    [logoutButton addSubview:line];
    [logoutButton addSubview:logoutLabel];
    [logoutButton addSubview:leaveGameArrow];
    logoutButton.userInteractionEnabled = YES;
    logoutButton.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
    logoutButton.opaque = NO;
    [logoutButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutButtonTouched)]];
    
    [self.view addSubview:logoutButton];
}

- (void) logoutButtonTouched
{
	[delegate logoutWasRequested];
}

- (void) passButtonTouched
{
	ForgotPasswordViewController *forgotPassViewController = [[ForgotPasswordViewController alloc] init];
	[[self navigationController] pushViewController:forgotPassViewController animated:YES];
}

- (void) profileButtonTouched
{
    [delegate playerSettingsRequested];
}

@end
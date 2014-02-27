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
    UIButton *profileButton;
    UIButton *passButton; 
    UIView *logoutButton;
    UILabel *logoutLabel;
    UIView *line;
    UIImageView *leaveGameArrow;
    id<AccountSettingsViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation AccountSettingsViewController

- (id)initWithDelegate:(id<AccountSettingsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        self.title = @"Account Settings";
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
    
    UIView *logoContainer = [[UIView alloc] init];
    logoContainer.frame = self.navigationItem.titleView.frame;
    UIImageView *logoText  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
    logoText.frame = CGRectMake(logoContainer.frame.size.width/2-50, logoContainer.frame.size.height/2-15, 100, 30);
    [logoContainer addSubview:logoText];
    self.navigationItem.titleView = logoContainer;
    
    profileButton = [[UIButton alloc] init];
	[profileButton setTitle:@"Public Name and Image" forState:UIControlStateNormal];
	[profileButton setTitleColor:[UIColor ARISColorBlack] forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(profileButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    profileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    profileButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:profileButton];
    
    passButton = [[UIButton alloc] init];
	[passButton setTitle:@"Change Password" forState:UIControlStateNormal];
	[passButton setTitleColor:[UIColor ARISColorBlack] forState:UIControlStateNormal];
    [passButton addTarget:self action:@selector(passButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    passButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; 
    passButton.titleLabel.textAlignment = NSTextAlignmentLeft; 
    [self.view addSubview:passButton];
    
    //Logout button \/
    logoutButton = [[UIView alloc] init];
    logoutLabel = [[UILabel alloc] init];
    leaveGameArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowBack"]];
    line = [[UIView alloc] init]; 
    
    logoutLabel.textAlignment = NSTextAlignmentLeft;
    logoutLabel.font = [ARISTemplate ARISButtonFont];
    logoutLabel.text = NSLocalizedString(@"LogoutKey",@"");
    logoutLabel.textColor = [ARISTemplate ARISColorText];
    
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

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    profileButton.frame = CGRectMake(20, 84, self.view.bounds.size.width-20, 40);
    passButton.frame = CGRectMake(20, 144, self.view.bounds.size.width-20, 40);
    
    logoutButton.frame = CGRectMake(0,self.view.bounds.size.height-44,self.view.bounds.size.width,44);
    logoutLabel.frame = CGRectMake(30,0,self.view.bounds.size.width-30,44);
    line.frame = CGRectMake(0,0,self.view.bounds.size.width,1);
    leaveGameArrow.frame = CGRectMake(6,13,19,19); 
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
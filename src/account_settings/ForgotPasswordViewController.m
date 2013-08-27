//
//  ForgotPasswordViewController.m
//  ARIS
//
//  Created by Brian Thiel on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "AppServices.h"
#import "UIColor+ARISColors.h"

@interface ForgotPasswordViewController() <UITextFieldDelegate>
{
    UITextField *emailField;
    UILabel *instructions;
}

@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UILabel *instructions;

@end

@implementation ForgotPasswordViewController

@synthesize emailField;
@synthesize instructions;

- (id) init
{
    if(self = [super init])
    {
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorWhite];
    
    UIView *titleContainer = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    UIImageView *logoText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
    logoText.frame = CGRectMake(titleContainer.frame.size.width/2-50, titleContainer.frame.size.height/2-15, 100, 30);
    [titleContainer addSubview:logoText];
    self.navigationItem.titleView = titleContainer;
    [self.navigationController.navigationBar layoutIfNeeded];
    
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(20,66+20,self.view.frame.size.width-40,20)];
    emailField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    emailField.delegate = self;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.placeholder = @"Email";
    emailField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:emailField];
    
    UIView *line;
    line = [[UIView alloc] initWithFrame:CGRectMake(20,66+20+20+5,self.view.frame.size.width-40, 1)];
    line.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
    [self.view addSubview:line];
    
    instructions = [[UILabel alloc] initWithFrame:CGRectMake(20,66+20+20+20,self.view.frame.size.width-40,80)];
    instructions.numberOfLines = 0;
    instructions.lineBreakMode = NSLineBreakByWordWrapping;
    instructions.text = @"An email will be sent to the above address with instructions on how to reset your password.";
    [self.view addSubview:instructions];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [[AppServices sharedAppServices] resetAndEmailNewPassword:textField.text];
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

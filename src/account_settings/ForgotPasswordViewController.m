//
//  ForgotPasswordViewController.m
//  ARIS
//
//  Created by Brian Thiel on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "AppServices.h"

@implementation ForgotPasswordViewController

@synthesize userField;
@synthesize userLabel;

- (id) init
{
    if(self = [super initWithNibName:@"ForgotPasswordViewController" bundle:nil])
    {
    }
    return self;
}

#pragma mark - View lifecycle

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

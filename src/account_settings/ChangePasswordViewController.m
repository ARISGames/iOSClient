//
//  ChangePasswordViewController.m
//  ARIS
//
//  Created by Brian Thiel on 10/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChangePasswordViewController.h"


@implementation ChangePasswordViewController
@synthesize userField,userLabel,requestedPasswordField,requestedPasswordLabel,prevPasswordField,prevPasswordLabel,submitButton;

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)submitButtonTouchAction
{
    //Server Call Here and confirmation message
}

- (NSInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

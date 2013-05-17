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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end

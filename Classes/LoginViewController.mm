//
//  LoginViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "LoginViewController.h"
#import "SelfRegistrationViewController.h"
#import "ARISAppDelegate.h"
#import "ChangePasswordViewController.h"
#import "ForgotViewController.h"

#import "Decoder.h"
#import <QRCodeReader.h>
#import "ARISZBarReaderWrapperViewController.h"

#import "BumpTestViewController.h"

@implementation LoginViewController

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"LoginTitleKey", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    usernameField.placeholder = NSLocalizedString(@"UsernameKey", @"");
    passwordField.placeholder = NSLocalizedString(@"PasswordKey", @"");
    [loginButton setTitle:NSLocalizedString(@"LoginKey",@"") forState:UIControlStateNormal];
    newAccountMessageLabel.text = NSLocalizedString(@"NewAccountMessageKey", @"");
    [newAccountButton setTitle:NSLocalizedString(@"CreateAccountKey",@"") forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usernameField)
        [passwordField becomeFirstResponder];
    if(textField == passwordField)
        [self loginButtonTouched:self];
    return YES;
}

//Makes keyboard disappear on touch outside of keyboard or textfield
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(IBAction)loginButtonTouched:(id)sender
{
    [[RootViewController sharedRootViewController] attemptLoginWithUserName:usernameField.text andPassword:passwordField.text andGameId:0 inMuseumMode:false];

    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
}

-(IBAction)QRButtonTouched
{
    ARISZBarReaderWrapperViewController *reader = [ARISZBarReaderWrapperViewController new];
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    reader.supportedOrientationsMask = 0;
    
    [scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
    [scanner setSymbology:ZBAR_UPCA   config:ZBAR_CFG_ENABLE to:1];
    [scanner setSymbology:ZBAR_UPCE   config:ZBAR_CFG_ENABLE to:1];

    [self presentViewController:reader animated:NO completion:nil];
}

-(void)changePassTouch
{
    ForgotViewController *forgotPassViewController = [[ForgotViewController alloc] initWithNibName:@"ForgotViewController" bundle:[NSBundle mainBundle]];
    [[self navigationController] pushViewController:forgotPassViewController animated:YES];
}

-(IBAction)newAccountButtonTouched:(id)sender
{
    SelfRegistrationViewController *selfRegistrationViewController = [[SelfRegistrationViewController alloc] initWithNibName:@"SelfRegistration" bundle:[NSBundle mainBundle]];
    [[self navigationController] pushViewController:selfRegistrationViewController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary  *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];

    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results) break;

    //PHIL ADDED BUMP DEBUGGING
    if([symbol.data isEqualToString:@"TEST_BUMP"])
    {
        BumpTestViewController *b = [[BumpTestViewController alloc] initWithNibName:@"BumpTestViewController" bundle:nil];
        [self presentViewController:b animated:NO completion:nil];
    }
    //END BUMP DEBUGGING
    
    NSArray *terms  = [symbol.data componentsSeparatedByString:@","];
    if([terms count] > 1)
    {
        int gameId = 0;
        bool create;
        bool museumMode;

        if([terms count] > 0) create = [[terms objectAtIndex:0] boolValue];
        if(create)
        {
            if([terms count] > 1) usernameField.text = [terms objectAtIndex:1]; //Group Name
            if([terms count] > 2) gameId = [[terms objectAtIndex:2] intValue];
            if([terms count] > 3) museumMode = [[terms objectAtIndex:3] boolValue];
            [[RootViewController sharedRootViewController] createUserAndLoginWithGroup:usernameField.text andGameId:gameId inMuseumMode:museumMode];
        }
        else
        {
            if([terms count] > 1) usernameField.text = [terms objectAtIndex:1]; //Username
            if([terms count] > 2) passwordField.text = [terms objectAtIndex:2]; //Password
            if([terms count] > 3) gameId = [[terms objectAtIndex:3] intValue];
            if([terms count] > 4) museumMode = [[terms objectAtIndex:4] boolValue];
            [[RootViewController sharedRootViewController] attemptLoginWithUserName:usernameField.text andPassword:passwordField.text andGameId:gameId inMuseumMode:museumMode];
        }
    }
}

@end

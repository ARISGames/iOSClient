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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    [AppModel sharedAppModel].inGame = NO;
    usernameField.placeholder = NSLocalizedString(@"UsernameKey", @"");
    passwordField.placeholder = NSLocalizedString(@"PasswordKey", @"");
    [loginButton setTitle:NSLocalizedString(@"LoginKey",@"") forState:UIControlStateNormal];
    newAccountMessageLabel.text = NSLocalizedString(@"NewAccountMessageKey", @"");
    [newAccountButton setTitle:NSLocalizedString(@"CreateAccountKey",@"") forState:UIControlStateNormal];

    NSLog(@"Login View Loaded");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usernameField) {
        [passwordField becomeFirstResponder];
    }	
    if(textField == passwordField) {
        [self loginButtonTouched:self];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(IBAction)loginButtonTouched: (id) sender {
    NSLog(@"Login: Login Button Touched");
    [[RootViewController sharedRootViewController] attemptLoginWithUserName:usernameField.text andPassword:passwordField.text andGameId:0 inMuseumMode:false];

    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
}

-(IBAction)QRButtonTouched
{
    // ADD: present a barcode reader that scans from the camera feed
    ARISZBarReaderWrapperViewController *reader = [ARISZBarReaderWrapperViewController new];
    reader.readerDelegate = self;

    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    reader.supportedOrientationsMask = 0;

    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_QRCODE
        config: ZBAR_CFG_ENABLE
        to: 1];
    [scanner setSymbology: ZBAR_UPCA
        config: ZBAR_CFG_ENABLE
        to: 1];
    [scanner setSymbology: ZBAR_UPCE
        config: ZBAR_CFG_ENABLE
        to: 1];

    // present the controller
    [self presentViewController:reader animated:YES completion:nil];
}

-(void)changePassTouch{
    NSLog(@"Login: Change Password Button Touched");
    ForgotViewController *forgotPassViewController = [[ForgotViewController alloc] initWithNibName:@"ForgotViewController" bundle:[NSBundle mainBundle]];
    [[self navigationController] pushViewController:forgotPassViewController animated:YES];
}

-(IBAction)newAccountButtonTouched: (id) sender{
    NSLog(@"Login: New User Button Touched");
    SelfRegistrationViewController *selfRegistrationViewController = [[SelfRegistrationViewController alloc] initWithNibName:@"SelfRegistration" bundle:[NSBundle mainBundle]];
    [[self navigationController] pushViewController:selfRegistrationViewController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary  *)info{
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];

    // ADD: get the decode results
    id<NSFastEnumeration> results =
        [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;

    NSLog(@"LoginViewController: Scan result: %@",symbol.data);
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

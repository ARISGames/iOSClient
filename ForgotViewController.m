//
//  ForgotViewController.m
//  ARIS
//
//  Created by Brian Thiel on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ForgotViewController.h"
#import "AppServices.h"

@implementation ForgotViewController
@synthesize userField,userLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [[AppServices sharedAppServices] emailPlayerNewPasswordEmail:textField.text ]; 
    NSLog(@"emailPlayerNewPasswordEmail");
    [textField resignFirstResponder];
    NSLog(@"resignFirstResponder");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Email Sent" message: @"An email has been sent to you containing your password" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
    NSLog(@"alert show");
	[alert release];
    
    
    return YES;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

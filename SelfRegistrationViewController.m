//
//  SelfRegistrationViewController.m
//  ARIS
//
//  Created by David Gagnon on 5/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SelfRegistrationViewController.h"


@implementation SelfRegistrationViewController

@synthesize moduleName;
@synthesize userName;
@synthesize password;
@synthesize firstName;
@synthesize lastName;
@synthesize email;


//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Create a New User";
		self.moduleName = @"RESTLogin";
    }
    return self;
}


-(void) setModel:(AppModel *)model {
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	
	NSLog(@"Self Registration: Model Set");
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

- (IBAction)submitButtonTouched: (id) sender{
	//Check with the Server
	NSString *newUserURLString = [[NSString alloc] initWithFormat:@"?module=%@&event=selfRegistration&site=%@&user_name=%@&password=%@&first_name=%@&last_name=%@&email=%@",
									 moduleName, appModel.site, self.userName.text, self.password.text, self.firstName.text, self.lastName.text, self.email.text];
	//NSLog(@"SelfRegistration: Module String = %@",newUserModuleString);
	NSURLRequest *newUserRequest = [appModel getEngineURL:newUserURLString];
	NSData *newUserRequestData = [appModel fetchURLData:newUserRequest];
	NSString *newUserRequestResponse = [[NSString alloc] initWithData:newUserRequestData encoding:NSASCIIStringEncoding];
	
	//handle login response
	if([newUserRequestResponse isEqual:@"1"]) {
		NSLog(@"SelfRegistration: New User Created Successfully");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your new User was Created. Go ahead and login."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[self.navigationController popToRootViewControllerAnimated:YES];

	}
	else {
		NSLog(@"SelfRegistration: Error Creating New User");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Either this name has been taken or you didn't fill out all the required information."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
	}

}

- (IBAction)cancelButtonTouched: (id) sender{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)doneButtonOnKeyboardTouched: (id)sender{
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[appModel release];
	[moduleName release];
    [super dealloc];
}


@end

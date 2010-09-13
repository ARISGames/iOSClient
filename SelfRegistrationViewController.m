//
//  SelfRegistrationViewController.m
//  ARIS
//
//  Created by David Gagnon on 5/14/09.
//  Copyright 2009 . All rights reserved.
//

#import "SelfRegistrationViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"

@implementation SelfRegistrationViewController

@synthesize waitingIndicator;
@synthesize scrollView;
@synthesize entryFields;
@synthesize userName;
@synthesize password;
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize messageLabel;


//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"SelfRegistrationTitleKey", @"");
		self.waitingIndicator = [[WaitingIndicatorView alloc] initWithWaitingMessage:@"Creating a New User" showProgressBar:NO];

		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:)  name:UIKeyboardWillShowNotification object:nil];  
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selfRegistrationFailure)  name:@"SelfRegistrationFailed" object:nil];  
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selfRegistrationSuccess)  name:@"SelfRegistrationSucceeded" object:nil];  
    
	}
	
    return self;
}


- (void)viewDidLoad {
	messageLabel.text = NSLocalizedString(@"SelfRegistrationMessageKey",@"");
	userName.placeholder = NSLocalizedString(@"UsernameKey",@"");
	password.placeholder = NSLocalizedString(@"PasswordKey",@"");
	email.placeholder = NSLocalizedString(@"EmailKey",@"");
	firstName.placeholder = NSLocalizedString(@"FirstNameKey",@"");
	lastName.placeholder = NSLocalizedString(@"LastNameKey",@"");
	[createAccountButton setTitle:NSLocalizedString(@"CreateAccountKey",@"") forState:UIControlStateNormal];
	[super viewDidLoad];
}
 
-(void)showLoadingIndicator{
	[self.waitingIndicator show];
}

-(void)removeLoadingIndicator{
	[self.waitingIndicator dismiss];
}


- (IBAction)submitButtonTouched: (id) sender{
	[self submitRegistration];
}


-(void)submitRegistration {
	[self showLoadingIndicator];
	
	//Check with the Server
	//self.userName.text, self.password.text, self.firstName.text, self.lastName.text, self.email.text];
	
	[appModel registerNewUser:self.userName.text password:self.password.text 
								   firstName:self.firstName.text lastName:self.lastName.text email:self.email.text]; 
}
	

-(void)selfRegistrationFailure{
	NSLog(@"SelfRegistration: Unsuccessfull registration attempt, check network before giving an alert");

	[self removeLoadingIndicator];
	
	if (appModel.networkAlert) NSLog(@"SelfRegistration: Network is down, skip alert");
	else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Either this name has been taken or you didn't fill out all the required information."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}		
}

-(void)selfRegistrationSuccess{
	NSLog(@"SelfRegistration: New User Created Successfully");
	
	[self removeLoadingIndicator];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your new User was Created. Go ahead and login."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
	[self.navigationController popToRootViewControllerAnimated:YES];
}
	

- (void)scrollViewToCenterOfScreen:(UIView *)theView {  
    CGFloat viewCenterY = theView.center.y;  
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];  
	
    CGFloat availableHeight = applicationFrame.size.height - keyboardBounds.size.height;    // Remove area covered by keyboard  
	
    CGFloat y = viewCenterY - availableHeight / 2.0;  
    if (y < 0) {  
        y = 0;  
    }  
    scrollView.contentSize = CGSizeMake(applicationFrame.size.width, applicationFrame.size.height + keyboardBounds.size.height);  
    [scrollView setContentOffset:CGPointMake(0, y) animated:YES];  
} 


#pragma mark UITextFieldDelegate  

- (void)textFieldDidBeginEditing:(UITextField *)textField {  
    [self scrollViewToCenterOfScreen:textField];  
}  

#pragma mark UITextViewDelegate  

- (void)textViewDidBeginEditing:(UITextView *)textView {  
    [self scrollViewToCenterOfScreen:textView];  
}  

- (void)keyboardNotification:(NSNotification*)notification {  
    NSDictionary *userInfo = [notification userInfo];  
    NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];  
    [keyboardBoundsValue getValue:&keyboardBounds];  
}  

- (BOOL)textFieldShouldReturn:(UITextField *)textField {  
    // Find the next entry field  
    for (UIView *view in [self entryFields]) {  
        if (view.tag == (textField.tag + 1)) {  
            [view becomeFirstResponder];  
            break;  
        }  
    }  
	
	if (textField.tag == 5) {
		//Last field, go ahead and submit
		[self submitRegistration];
	}
	
    return NO;  
} 

/* 
 Returns an array of all data entry fields in the view. 
 Fields are ordered by tag, and only fields with tag > 0 are included. 
 Returned fields are guaranteed to be a subclass of UIResponder. 
 */  
- (NSMutableArray *)entryFields {  
    if (!entryFields) {  
        self.entryFields = [[NSMutableArray alloc] init];  
        NSInteger tag = 1;  
        UIView *aView;  
        while (aView = [self.view viewWithTag:tag]) {  
            if (aView && [[aView class] isSubclassOfClass:[UIResponder class]]) {  
                [entryFields addObject:aView];  
            }  
            tag++;  
        }  
    }  
    return entryFields;  
}  

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[waitingIndicator release];
    [super dealloc];
}


@end

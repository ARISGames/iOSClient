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

@synthesize scrollView;
@synthesize entryFields;
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
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:)  name:UIKeyboardWillShowNotification object:nil];  
    
	}
	
    return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
}
 

- (IBAction)submitButtonTouched: (id) sender{
	[self submitRegistration];
}

- (IBAction)cancelButtonTouched: (id) sender{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)submitRegistration {
	//Check with the Server
	//self.userName.text, self.password.text, self.firstName.text, self.lastName.text, self.email.text];
	
	BOOL success = [appModel registerNewUser:self.userName.text password:self.password.text 
								   firstName:self.firstName.text lastName:self.lastName.text email:self.email.text]; 
	
	if(success) {
		NSLog(@"SelfRegistration: New User Created Successfully");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your new User was Created. Go ahead and login."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	else {
		NSLog(@"SelfRegistration: Unsuccessfull registration attempt, check network before giving an alert");
		if (appModel.networkAlert) NSLog(@"SelfRegistration: Network is down, skip alert");
		else{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Either this name has been taken or you didn't fill out all the required information."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];	
			[alert release];
		}	
	}
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
	[appModel release];
    [super dealloc];
}


@end

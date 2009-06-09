//
//  SelfRegistrationViewController.h
//  ARIS
//
//  Created by David Gagnon on 5/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"


@interface SelfRegistrationViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
	AppModel *appModel;
	NSString *moduleName;
	UIScrollView *scrollView;
	CGRect keyboardBounds; 
	NSMutableArray *entryFields;
	UITextField *userName;
	UITextField *password;
	UITextField *firstName;
	UITextField *lastName;
	UITextField *email;
	
}

@property(copy, readwrite) NSString *moduleName;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *entryFields;
@property (nonatomic, retain) IBOutlet UITextField *userName;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UITextField *firstName;
@property (nonatomic, retain) IBOutlet UITextField *lastName;
@property (nonatomic, retain) IBOutlet UITextField *email;


-(void) setModel:(AppModel *)model;
-(IBAction)submitButtonTouched: (id) sender;
-(IBAction)cancelButtonTouched: (id) sender;
-(void)submitRegistration;


@end

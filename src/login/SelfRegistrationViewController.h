//
//  SelfRegistrationViewController.h
//  ARIS
//
//  Created by David Gagnon on 5/14/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelfRegistrationViewControllerDelegate
- (void) registrationSucceededWithUsername:(NSString *)username password:(NSString *)password;
@end

@interface SelfRegistrationViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
	IBOutlet UITextField *userName;
	IBOutlet UITextField *password;
	IBOutlet UITextField *email;
	IBOutlet UIButton *createAccountButton;
}

@property (nonatomic) IBOutlet UITextField *userName;
@property (nonatomic) IBOutlet UITextField *password;
@property (nonatomic) IBOutlet UITextField *email;

- (id)initWithDelegate:(id<SelfRegistrationViewControllerDelegate>)d;
- (IBAction)submitButtonTouched:(id)sender;

@end

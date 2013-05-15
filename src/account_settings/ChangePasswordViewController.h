//
//  ChangePasswordViewController.h
//  ARIS
//
//  Created by Brian Thiel on 10/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChangePasswordViewController : UIViewController<UITextFieldDelegate> {
    IBOutlet UITextField *userField;
    IBOutlet UITextField *prevPasswordField;
    IBOutlet UITextField *requestedPasswordField;
    IBOutlet UILabel *userLabel;
    IBOutlet UILabel *prevPasswordLabel;
    IBOutlet UILabel *newPasswordLabel;
    IBOutlet UIButton *submitButton;
}
@property(nonatomic)IBOutlet UITextField *userField;
@property(nonatomic)IBOutlet UITextField *prevPasswordField;
@property(nonatomic)IBOutlet UITextField *requestedPasswordField;
@property(nonatomic)IBOutlet UILabel *userLabel;
@property(nonatomic)IBOutlet UILabel *prevPasswordLabel;
@property(nonatomic)IBOutlet UILabel *requestedPasswordLabel;
@property(nonatomic)IBOutlet UIButton *submitButton;

-(IBAction)submitButtonTouchAction;

@end

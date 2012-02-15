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
@property(nonatomic,retain)IBOutlet UITextField *userField;
@property(nonatomic,retain)IBOutlet UITextField *prevPasswordField;
@property(nonatomic,retain)IBOutlet UITextField *requestedPasswordField;
@property(nonatomic,retain)IBOutlet UILabel *userLabel;
@property(nonatomic,retain)IBOutlet UILabel *prevPasswordLabel;
@property(nonatomic,retain)IBOutlet UILabel *requestedPasswordLabel;
@property(nonatomic,retain)IBOutlet UIButton *submitButton;

-(IBAction)submitButtonTouchAction;

@end

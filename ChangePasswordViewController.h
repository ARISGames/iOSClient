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
    IBOutlet UITextField *prevField;
    IBOutlet UITextField *newField;
    IBOutlet UILabel *userLabel;
    IBOutlet UILabel *prevLabel;
    IBOutlet UILabel *newLabel;
    IBOutlet UIButton *submitButton;
}
@property(nonatomic,retain)IBOutlet UITextField *userField;
@property(nonatomic,retain)IBOutlet UITextField *prevField;
@property(nonatomic,retain)IBOutlet UITextField *newField;
@property(nonatomic,retain)IBOutlet UILabel *userLabel;
@property(nonatomic,retain)IBOutlet UILabel *prevLabel;
@property(nonatomic,retain)IBOutlet UILabel *newLabel;
@property(nonatomic,retain)IBOutlet UIButton *submitButton;

-(IBAction)submitButtonTouchAction;

@end

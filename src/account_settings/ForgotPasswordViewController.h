//
//  ForgotPasswordViewController.h
//  ARIS
//
//  Created by Brian Thiel on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *userField;
    IBOutlet UILabel *userLabel;
}

@property(nonatomic)IBOutlet UITextField *userField;
@property(nonatomic)IBOutlet UILabel *userLabel;

@end

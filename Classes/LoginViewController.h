//
//  LoginViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "WaitingIndicatorView.h"


@interface LoginViewController : UIViewController {
	WaitingIndicatorView *waitingIndicator;

	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UIButton *loginButton;
	IBOutlet UIButton *newAccountButton;
	IBOutlet UILabel *newAccountMessageLabel;
}

@property (nonatomic, retain) WaitingIndicatorView *waitingIndicator;


-(IBAction)newAccountButtonTouched: (id) sender;
-(IBAction)loginButtonTouched: (id) sender;


@end

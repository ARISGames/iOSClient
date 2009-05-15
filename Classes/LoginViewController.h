//
//  LoginViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"

@interface LoginViewController : UIViewController {
	AppModel *appModel;
	UITextField *username;
	UITextField *password;
	UIButton *login;
	UINavigationItem *titleItem;
}

-(void) setModel:(AppModel *)model;

-(void) setNavigationTitle:(NSString *)title;
-(void) fadeIn;
-(void) fadeOut;
-(void) performLogin;
-(IBAction)newUserButtonTouched: (id) sender;

@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIButton *login;
@property (nonatomic, retain) IBOutlet UINavigationItem *titleItem;

@end

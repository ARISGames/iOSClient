//
//  LoginViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController {
	UITextField *username;
	UITextField *password;
	UIButton *login;
	UINavigationItem *titleItem;
}

-(void) setNavigationTitle:(NSString *)title;
-(void) fadeIn;
-(void) fadeOut;

@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIButton *login;
@property (nonatomic, retain) IBOutlet UINavigationItem *titleItem;

@end

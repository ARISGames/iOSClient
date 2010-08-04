//
//  UpdatesViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogoutViewController : UIViewController {
	IBOutlet UIButton *logoutButton;
	IBOutlet UILabel *warningLabel;
}

-(IBAction)logoutButtonPressed: (id) sender;

@end

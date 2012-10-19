//
//  AccountSettingsController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AccountSettingsViewController : UIViewController {
	IBOutlet UIButton *logoutButton;
	IBOutlet UIButton *passButton;
	IBOutlet UIButton *profileButton;
	IBOutlet UILabel *warningLabel;
}

-(IBAction)logoutButtonPressed: (id) sender;
-(IBAction)passButtonPressed: (id) sender;
-(IBAction)profileButtonPressed: (id) sender;

@end

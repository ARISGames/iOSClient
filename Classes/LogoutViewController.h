//
//  UpdatesViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogoutViewController : UIViewController {
	NSString *moduleName;
	IBOutlet UIButton *logoutButton;
}

@property(copy, readwrite) NSString *moduleName;

-(IBAction)logoutButtonPressed: (id) sender;

@end

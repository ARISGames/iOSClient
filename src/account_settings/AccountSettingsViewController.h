//
//  AccountSettingsController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountSettingsViewControllerDelegate
- (void) playerSettingsRequested;
- (void) logoutWasRequested;
- (void) accountSettingsWereDismissed;
@end

@interface AccountSettingsViewController : UIViewController
{
	IBOutlet UIButton *logoutButton;
	IBOutlet UIButton *passButton;
	IBOutlet UIButton *profileButton;
	IBOutlet UILabel *warningLabel;
}

- (id) initWithDelegate:(id<AccountSettingsViewControllerDelegate>)d;
- (IBAction) logoutButtonPressed:(id)sender;
- (IBAction) passButtonPressed:(id)sender;
- (IBAction) profileButtonPressed:(id)sender;

@end

//
//  LoginViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class User;

@protocol LoginViewControllerDelegate
- (void) loginCredentialsApprovedForPlayer:(User *)p toGame:(int)gameId newPlayer:(BOOL)newPlayer disableLeaveGame:(BOOL)disableLeaveGame;
@end

@interface LoginViewController : ARISViewController
- (id) initWithDelegate:(id<LoginViewControllerDelegate>)d;
- (void) resetState;
@end

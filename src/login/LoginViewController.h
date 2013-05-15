//
//  LoginViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Player;

@protocol LoginViewControllerDelegate
- (void) loginCredentialsApprovedForPlayer:(Player *)p toGame:(int)gameId newPlayer:(BOOL)newPlayer disableLeaveGame:(BOOL)disableLeaveGame;
@end

@interface LoginViewController : UIViewController
- (id) initWithDelegate:(id<LoginViewControllerDelegate>)d;
- (void) resetState;
@end

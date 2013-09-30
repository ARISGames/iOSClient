//
//  SelfRegistrationViewController.h
//  ARIS
//
//  Created by David Gagnon on 5/14/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol SelfRegistrationViewControllerDelegate
- (void) registrationSucceededWithUsername:(NSString *)username password:(NSString *)password;
@end

@interface SelfRegistrationViewController : ARISViewController
- (id)initWithDelegate:(id<SelfRegistrationViewControllerDelegate>)d;
@end

//
//  CreateAccountViewController.h
//  ARIS
//
//  Created by David Gagnon on 5/14/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol CreateAccountViewControllerDelegate
@end

@interface CreateAccountViewController : ARISViewController
- (id)initWithDelegate:(id<CreateAccountViewControllerDelegate>)d;
@end

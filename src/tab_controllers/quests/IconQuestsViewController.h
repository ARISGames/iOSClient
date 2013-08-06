//
//  IconQuestsViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"
#import "QuestsViewControllerDelegate.h"

@interface IconQuestsViewController : ARISGamePlayTabBarViewController
- (id)initWithDelegate:(id<QuestsViewControllerDelegate,StateControllerProtocol>)d;
@end
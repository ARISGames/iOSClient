//
//  IconQuestsViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"
#import "QuestsViewControllerDelegate.h"

@interface IconQuestsViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id)initWithDelegate:(id<QuestsViewControllerDelegate,StateControllerProtocol>)d;
@end

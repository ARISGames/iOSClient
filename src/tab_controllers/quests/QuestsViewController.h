//
//  QuestsViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"
#import "QuestsViewControllerDelegate.h"

@class Tab;
@interface QuestsViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithTab:(Tab *)t delegate:(id<QuestsViewControllerDelegate>)d;
- (void) showQuestByName:(NSString *) quest_name;
@end

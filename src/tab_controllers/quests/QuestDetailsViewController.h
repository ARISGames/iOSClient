//
//  QuestDetailsViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 10/11/12.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class Quest;
@protocol QuestDetailsViewControllerDelegate
- (void) questDetailsRequestsDismissal;
@end
@interface QuestDetailsViewController : ARISViewController
- (id) initWithQuest:(Quest *)q mode:(NSString *)m delegate:(id<QuestDetailsViewControllerDelegate>)d;
- (void) dismissQuestDetails;
@end

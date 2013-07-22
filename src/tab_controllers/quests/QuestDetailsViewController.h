//
//  QuestDetailsViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 10/11/12.
//
//

#import <UIKit/UIKit.h>

@class Quest;
@protocol QuestDetailsViewControllerDelegate
- (void) questDetailsRequestedExitToTab:(NSString *)tab;
@end
@interface QuestDetailsViewController : UIViewController
- (id) initWithQuest:(Quest *)q delegate:(id<QuestDetailsViewControllerDelegate>)d;

@end

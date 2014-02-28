//
//  QuestCell.h
//  ARIS
//
//  Created by Phil Dougherty on 2/27/14.
//
//

#import <UIKit/UIKit.h>

@class Quest;
@class QuestCell;

@protocol QuestCellDelegate
- (void) heightCalculated:(int)h forQuest:(Quest *)q inCell:(QuestCell *)qc;
@end

@interface QuestCell : UITableViewCell
- (void) setQuest:(Quest *)q;
- (void) setDelegate:(id<QuestCellDelegate>)d;
@end

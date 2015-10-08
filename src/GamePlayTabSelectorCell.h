//
//  GamePlayTabSelectorCell.h
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISMediaView.h"

@class GamePlayTabSelector;
@protocol GamePlayTabSelectorCellDelegate
@end

@interface GamePlayTabSelectorCell : UITableViewCell
+ (NSString *) cellIdentifier;
- (id) initWithDelegate:(id<GamePlayTabSelectorCellDelegate>)d;

- (void) setLabel:(NSString *)t;
- (void) setIcon:(ARISMediaView *)i;

@end

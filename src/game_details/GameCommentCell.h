//
//  GameCommentCell.h
//  ARIS
//
//  Created by Philip Dougherty on 6/7/11.
//  Copyright 2011 UW Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameComment;
@class GameCommentCell;

@protocol GameCommentCellDelegate
- (void) heightCalculated:(int)h forComment:(GameComment *)gc inCell:(GameCommentCell *)gcc;
@end

@interface GameCommentCell : UITableViewCell 
- (void) setComment:(GameComment *)gc;
- (void) setDelegate:(id<GameCommentCellDelegate>)d;
@end

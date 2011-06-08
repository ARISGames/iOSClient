//
//  CommentCell.h
//  ARIS
//
//  Created by Philip Dougherty on 6/7/11.
//  Copyright 2011 UW Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRRatingView.h"

@interface CommentCell : UITableViewCell {
	UILabel *commentLabel;
	UILabel *authorLabel;
	SCRRatingView *starView;
}

@property(nonatomic,retain) IBOutlet UILabel *commentLabel;
@property(nonatomic,retain) IBOutlet UILabel *authorLabel;
@property(nonatomic,retain) IBOutlet SCRRatingView *starView;

@end
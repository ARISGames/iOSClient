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
	UITextView *commentLabel;
	UILabel *authorLabel;
	SCRRatingView *starView;
}

@property(nonatomic) IBOutlet UITextView *commentLabel;
@property(nonatomic) IBOutlet UILabel *authorLabel;
@property(nonatomic) IBOutlet SCRRatingView *starView;

@end
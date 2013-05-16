//
//  GamePickerCell.h
//  ARIS
//
//  Created by David J Gagnon on 2/19/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncMediaImageView.h"
#import "SCRRatingView.h"

@interface GamePickerCell : UITableViewCell
{
	UILabel *titleLabel;
	UILabel *distanceLabel;
	UILabel *authorLabel;
	UILabel *numReviewsLabel;
	AsyncMediaImageView *iconView;
	SCRRatingView *starView;
}

@property(nonatomic) IBOutlet UILabel *titleLabel;
@property(nonatomic) IBOutlet UILabel *distanceLabel;
@property(nonatomic) IBOutlet UILabel *authorLabel;
@property(nonatomic) IBOutlet UILabel *numReviewsLabel;
@property(nonatomic) IBOutlet AsyncMediaImageView *iconView;
@property(nonatomic) IBOutlet SCRRatingView *starView;

@end

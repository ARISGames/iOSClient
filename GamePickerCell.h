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

@interface GamePickerCell : UITableViewCell {
	UILabel *titleLabel;
	UILabel *distanceLabel;
	UILabel *authorLabel;
	UILabel *numReviewsLabel;
	AsyncMediaImageView *iconView;
	SCRRatingView *starView;
}

@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UILabel *distanceLabel;
@property(nonatomic,retain) IBOutlet UILabel *authorLabel;
@property(nonatomic,retain) IBOutlet UILabel *numReviewsLabel;
@property(nonatomic,retain) IBOutlet AsyncMediaImageView *iconView;
@property(nonatomic,retain) IBOutlet SCRRatingView *starView;

@end

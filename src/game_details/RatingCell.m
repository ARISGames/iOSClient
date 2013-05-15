//
//  RatingCell.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "RatingCell.h"


@implementation RatingCell


@synthesize ratingView;
@synthesize reviewsLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        [self.ratingView setStarImage:[UIImage imageNamed:@"small-star-halfselected.png"]
                             forState:kSCRatingViewHalfSelected];
        [self.ratingView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]
                             forState:kSCRatingViewHighlighted];
        [self.ratingView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]
                             forState:kSCRatingViewHot];
        [self.ratingView setStarImage:[UIImage imageNamed:@"small-star-nonselected.png"]
                             forState:kSCRatingViewNonSelected];
        [self.ratingView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]
                             forState:kSCRatingViewSelected];
        [self.ratingView setStarImage:[UIImage imageNamed:@"small-star-userselected.png"]
                             forState:kSCRatingViewUserSelected];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


@end

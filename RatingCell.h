//
//  RatingCell.h
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRRatingView.h"


@interface RatingCell : UITableViewCell {
    SCRRatingView *ratingView;
    UILabel *reviewsLabel;
}

@property (nonatomic) IBOutlet SCRRatingView *ratingView;
@property (nonatomic) IBOutlet UILabel *reviewsLabel;


@end

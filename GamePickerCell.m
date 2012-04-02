//
//  GamePickerCell.m
//  ARIS
//
//  Created by David J Gagnon on 2/19/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "GamePickerCell.h"


@implementation GamePickerCell

@synthesize titleLabel;
@synthesize distanceLabel;
@synthesize authorLabel;
@synthesize numReviewsLabel;
@synthesize iconView;
@synthesize starView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}



@end

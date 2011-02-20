//
//  GamePickerCell.h
//  ARIS
//
//  Created by David J Gagnon on 2/19/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface GamePickerCell : UITableViewCell {
	UILabel *titleLabel;
	UILabel *distanceLabel;
	UILabel *authorLabel;
	UILabel *percentCompleteLabel;
	AsyncImageView *iconView;
	UIProgressView *progressView;
}

@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UILabel *distanceLabel;
@property(nonatomic,retain) IBOutlet UILabel *authorLabel;
@property(nonatomic,retain) IBOutlet UILabel *percentCompleteLabel;
@property(nonatomic,retain) IBOutlet AsyncImageView *iconView;
@property(nonatomic,retain) IBOutlet UIProgressView *progressView;

@end

//
//  NearbyObjectCell.h
//  ARIS
//
//  Created by David J Gagnon on 2/13/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface NearbyObjectCell : UITableViewCell {
	UILabel *title;
	UILabel *qty;
	AsyncImageView *iconView;
}

@property(nonatomic,retain) IBOutlet UILabel *title;
@property(nonatomic,retain) IBOutlet AsyncImageView *iconView;

@end

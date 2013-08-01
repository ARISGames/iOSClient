//
//  NearbyObjectCell.h
//  ARIS
//
//  Created by David J Gagnon on 2/13/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISMediaView.h"

@interface NearbyObjectCell : UITableViewCell {
	UILabel *title;
	UILabel *qty;
	ARISMediaView *iconView;
}

@property(nonatomic) IBOutlet UILabel *title;
@property(nonatomic) IBOutlet ARISMediaView *iconView;

@end

//
//  NoteCell.h
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRRatingView.h"


@interface NoteCell : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UIImageView *mediaIcon1;
    IBOutlet UIImageView *mediaIcon2;
    IBOutlet UIImageView *mediaIcon3;
    IBOutlet UIImageView *mediaIcon4;
    IBOutlet UILabel *likesLbl;
    IBOutlet UILabel *commentsLbl;
    SCRRatingView *starView;

}
@property(nonatomic,retain)IBOutlet UILabel *titleLabel;
@property(nonatomic,retain)IBOutlet UILabel *likesLbl;
@property(nonatomic,retain)IBOutlet UILabel *commentsLbl;

@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon1;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon2;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon3;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon4;
@property(nonatomic,retain) IBOutlet SCRRatingView *starView;


@end

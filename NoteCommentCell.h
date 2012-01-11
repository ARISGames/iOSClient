//
//  NoteCommentCell.h
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRRatingView.h"


@interface NoteCommentCell : UITableViewCell {
    IBOutlet UITextView *titleLabel;
    IBOutlet UIImageView *mediaIcon2;
    IBOutlet UIImageView *mediaIcon3;
    IBOutlet UIImageView *mediaIcon4;
    IBOutlet UILabel *userLabel;
    IBOutlet UILabel *likesLabel;
    SCRRatingView *starView;

}
@property(nonatomic,retain)IBOutlet UITextView *titleLabel;
@property(nonatomic,retain)IBOutlet UILabel *userLabel;
@property(nonatomic,retain)IBOutlet UILabel *likesLabel;

@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon2;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon3;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon4;
@property(nonatomic,retain) IBOutlet SCRRatingView *starView;

@end
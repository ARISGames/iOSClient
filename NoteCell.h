//
//  NoteCell.h
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRRatingView.h"
#import "Note.h"

@interface NoteCell : UITableViewCell<UITextViewDelegate> {
    IBOutlet UITextView *titleLabel;
    IBOutlet UIImageView *mediaIcon1;
    IBOutlet UIImageView *mediaIcon2;
    IBOutlet UIImageView *mediaIcon3;
    IBOutlet UIImageView *mediaIcon4;
    IBOutlet UILabel *likesLbl;
    IBOutlet UILabel *commentsLbl;
    IBOutlet UILabel *holdLbl;
    Note *note;
    SCRRatingView *starView;
    int index;
    id delegate;
}
@property(nonatomic,retain)IBOutlet UITextView *titleLabel;
@property(nonatomic,retain)IBOutlet UILabel *likesLbl;
@property(nonatomic,retain)IBOutlet UILabel *commentsLbl;
@property(nonatomic,retain)IBOutlet UILabel *holdLbl;
@property(nonatomic,retain)Note *note;
@property(nonatomic,retain)id delegate;

@property(readwrite, assign)int index;

@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon1;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon2;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon3;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon4;
@property(nonatomic,retain) IBOutlet SCRRatingView *starView;

@end

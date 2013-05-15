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
    IBOutlet UILabel *likeLabel;
    
    IBOutlet UIButton *likesButton;
    IBOutlet UILabel *commentsLbl;
    IBOutlet UILabel *holdLbl;
    Note *note;
    SCRRatingView *starView;
    int index;
    id __unsafe_unretained delegate;
}
@property(nonatomic)IBOutlet UITextView *titleLabel;
@property(nonatomic)IBOutlet UILabel *likeLabel;
@property(nonatomic)IBOutlet UIButton *likesButton;
@property(nonatomic)IBOutlet UILabel *commentsLbl;
@property(nonatomic)IBOutlet UILabel *holdLbl;
@property(nonatomic)Note *note;
@property(nonatomic,unsafe_unretained)id delegate;

@property(readwrite, assign)int index;

@property(nonatomic)IBOutlet UIImageView *mediaIcon1;
@property(nonatomic)IBOutlet UIImageView *mediaIcon2;
@property(nonatomic)IBOutlet UIImageView *mediaIcon3;
@property(nonatomic)IBOutlet UIImageView *mediaIcon4;
@property(nonatomic) IBOutlet SCRRatingView *starView;
-(IBAction)likeButtonTouched;

@end

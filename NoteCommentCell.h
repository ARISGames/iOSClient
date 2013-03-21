//
//  NoteCommentCell.h
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRRatingView.h"
#import "Note.h"
#import <MediaPlayer/MediaPlayer.h>

@interface NoteCommentCell : UITableViewCell
{
    IBOutlet UITextView *titleLabel;
    IBOutlet UIImageView *mediaIcon2;
    IBOutlet UIImageView *mediaIcon3;
    IBOutlet UIImageView *mediaIcon4;
    IBOutlet UILabel *userLabel;
    IBOutlet UILabel *likeLabel;
    IBOutlet UIButton *retryButton;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIButton *likesButton;
    Note *note;
}

@property (nonatomic) IBOutlet UITextView *titleLabel;
@property (nonatomic) IBOutlet UILabel *userLabel;
@property (nonatomic) IBOutlet UILabel *likeLabel;

@property (nonatomic) IBOutlet UIButton *likesButton;
@property (nonatomic) Note *note;
@property (nonatomic) IBOutlet UIImageView *mediaIcon2;
@property (nonatomic) IBOutlet UIImageView *mediaIcon3;
@property (nonatomic) IBOutlet UIImageView *mediaIcon4;
@property (nonatomic) IBOutlet UIButton *retryButton;
@property (nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (void) checkForRetry;
- (IBAction) retryUpload;
- (IBAction) likeButtonTouched;
- (void) initCell;

@end
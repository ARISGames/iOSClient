//
//  CommentsFormCell.h
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRRatingView.h"
#import "Game.h"
#import "commentsViewController.h"

@interface CommentsFormCell : UITableViewCell <UITextViewDelegate>{
    SCRRatingView *ratingView;
    UITextView *textField;
    UIButton *saveButton;
    Game *game;

    commentsViewController *commentsVC;

    UIAlertView *alert;

}

@property (nonatomic, retain) UIAlertView *alert;
@property(nonatomic,retain) IBOutlet SCRRatingView *ratingView;
@property(nonatomic,retain) IBOutlet UITextView *textField;
@property(nonatomic,retain) IBOutlet UIButton *saveButton;
@property(nonatomic,retain) commentsViewController *commentsVC;
@property(nonatomic,retain) Game *game;

- (IBAction)saveComment:(id)sender;



@end

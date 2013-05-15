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

@property (nonatomic) UIAlertView *alert;
@property(nonatomic) IBOutlet SCRRatingView *ratingView;
@property(nonatomic) IBOutlet UITextView *textField;
@property(nonatomic) IBOutlet UIButton *saveButton;
@property(nonatomic) commentsViewController *commentsVC;
@property(nonatomic) Game *game;

- (IBAction)saveComment:(id)sender;



@end

//
//  CommentsFormCell.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "CommentsFormCell.h"
#import "AppServices.h"

@interface CommentsFormCell ()
{
    UITextView *textField;
    UIButton *saveButton;
    Game *game;

    commentsViewController *commentsVC;
}

@end

@implementation CommentsFormCell

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    //do nothing
}
/*
- (IBAction) saveComment:(id)sender {
    if(self.ratingView.userRating == 0){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ErrorKey", @"")
                                                             message: NSLocalizedString(@"CommentsFormNumberOfStarsRatingKey", @"")
                                                            delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
        [alert show];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CommentsFormSuccessKey", @"a")
                                                             message: NSLocalizedString(@"CommentsFormSuccessMessageKey", @"")
                                                            delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
        [alert show];
        [[AppServices sharedAppServices] saveGameComment:self.textField.text game:self.game.gameId starRating:self.ratingView.userRating];
        
        self.commentsVC.defaultRating = self.ratingView.userRating;
        
        //Add comment client side
        Comment *comment = [[Comment alloc]init];
        if([self.textField.text isEqualToString:@"Comment"]) comment.text = @"";
        else comment.text = self.textField.text;
        comment.rating = self.ratingView.userRating;
        self.game.rating = self.ratingView.userRating;
        comment.playerName = NSLocalizedString(@"DialogPlayerName", @"");
        [self.commentsVC addComment:comment];
        [self.commentsVC.tableView reloadData];
        //End client side manipulation
    }
}
 */

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [textView setText:@""];
}

@end

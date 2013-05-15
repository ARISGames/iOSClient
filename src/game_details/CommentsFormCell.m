//
//  CommentsFormCell.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "CommentsFormCell.h"
#import "AppServices.h"

@implementation CommentsFormCell
@synthesize ratingView;
@synthesize textField;
@synthesize saveButton;
@synthesize game,commentsVC;
@synthesize alert;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    //[super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (IBAction)saveComment:(id)sender {
/*    if([self.textField.text length] == 0){
        self.alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                message: NSLocalizedString(@"Please add a comment", @"")
                                               delegate: self cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [self.alert show];
        [self.alert release];
    }
    else*/ if(self.ratingView.userRating == 0){
        UIAlertView *alertAlloc = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ErrorKey", @"")
                                                             message: NSLocalizedString(@"CommentsFormNumberOfStarsRatingKey", @"")
                                                            delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
        self.alert = alertAlloc;
        [self.alert show];
    }
    else{
        UIAlertView *alertAlloc = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CommentsFormSuccessKey", @"a")
                                                             message: NSLocalizedString(@"CommentsFormSuccessMessageKey", @"")
                                                            delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
        self.alert = alertAlloc;
        [self.alert show];
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
-(void)textViewDidBeginEditing:(UITextView *)textView{
    [textView setText:@""];
}



@end

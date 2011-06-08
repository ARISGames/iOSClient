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
    if([self.textField.text length] == 0){
        self.alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                message: NSLocalizedString(@"Please add a comment", @"")
                                               delegate: self cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [self.alert show];
        [self.alert release];
    }
    else if(self.ratingView.userRating == 0){
        self.alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                message: NSLocalizedString(@"Please give this game a rating of one through five stars", @"")
                                               delegate: self cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [self.alert show];
        [self.alert release];
    }
    else{
        self.alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Success!", @"a")
                                                message: NSLocalizedString(@"Comment Successfully Posted", @"")
                                               delegate: self cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [self.alert show];
        [self.alert release];
        [[AppServices sharedAppServices] saveComment:self.textField.text game:self.game.gameId starRating:self.ratingView.userRating];
        
        self.commentsVC.defaultRating = self.ratingView.userRating;
        
        //Add comment client side
        Comment *comment = [[Comment alloc]init];
        comment.text = self.textField.text;
        comment.rating = self.ratingView.userRating;
        comment.playerName = @"You";
        [self.commentsVC addComment:comment];
        [self.commentsVC.tableView reloadData];
        [comment release];
        //End client side manipulation
    }
}


- (void)dealloc
{
    [ratingView release];
    [textField release];
    [saveButton release];
    [super dealloc];

}


@end

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
@synthesize game;

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
    [[AppServices sharedAppServices] saveComment:self.textField.text game:self.game.gameId starRating:self.ratingView.userRating];
}


- (void)dealloc
{
    [super dealloc];
    [ratingView release];
    [textField release];
    [saveButton release];
}


@end

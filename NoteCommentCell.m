//
//  NoteCommentCell.m
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteCommentCell.h"
#import "AppServices.h"

@implementation NoteCommentCell
@synthesize titleLabel,mediaIcon2,mediaIcon3,mediaIcon4,userLabel,likesButton,note;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}
-(void)awakeFromNib{
    likesButton.titleLabel.text = [NSString stringWithFormat:@"+%d",note.numRatings];
    if(self.note.userLiked){
        self.likesButton.selected = YES;
    }
    else{
        self.likesButton.selected = NO;
    }
}

-(void)likeButtonTouched{
    self.likesButton.selected = !self.likesButton.selected;
    self.note.userLiked = !self.note.userLiked;
    if(self.note.userLiked){
        [[AppServices sharedAppServices]likeNote:self.note.noteId];
    }
    else{
        [[AppServices sharedAppServices]unLikeNote:self.note.noteId];
    }

    //do server call here;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)dealloc
{
    [titleLabel release];
    [mediaIcon4 release];
    [mediaIcon3 release];
    [mediaIcon2 release];
    [super dealloc];
}



@end

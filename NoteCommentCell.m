//
//  NoteCommentCell.m
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteCommentCell.h"


@implementation NoteCommentCell
@synthesize titleLabel,mediaIcon2,mediaIcon3,mediaIcon4,userLabel,starView,likesLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
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
    [starView release];
    [super dealloc];
}



@end

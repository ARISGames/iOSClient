//
//  NoteCell.m
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteCell.h"


@implementation NoteCell
@synthesize titleLabel,mediaIcon1,mediaIcon2,mediaIcon3,mediaIcon4;
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
    [mediaIcon1 release];
    [super dealloc];
}



@end

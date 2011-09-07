//
//  NoteCommentCell.h
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <UIKit/UIKit.h>


@interface NoteCommentCell : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UIImageView *mediaIcon1;
    IBOutlet UIImageView *mediaIcon2;
    IBOutlet UIImageView *mediaIcon3;
    IBOutlet UIImageView *mediaIcon4;
    IBOutlet UILabel *userLabel;
}
@property(nonatomic,retain)IBOutlet UILabel *titleLabel;
@property(nonatomic,retain)IBOutlet UILabel *userLabel;

@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon1;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon2;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon3;
@property(nonatomic,retain)IBOutlet UIImageView *mediaIcon4;

@end
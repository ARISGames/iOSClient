//
//  NoteContentCell.h
//  ARIS
//
//  Created by Brian Thiel on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteContentCell : UITableViewCell<UITextViewDelegate>{
    IBOutlet UITextView *titleLbl;
    IBOutlet UILabel *detailLbl;
    IBOutlet UILabel *holdLbl;
    IBOutlet UIImageView *imageView;
    int contentId;
    int index;
    id delegate;
}
@property(readwrite, assign)int contentId;
@property(nonatomic,retain)UITextView *titleLbl;
@property(nonatomic,retain)UILabel *detailLbl;
@property(nonatomic,retain) IBOutlet UILabel *holdLbl;
@property(nonatomic,retain)UIImageView *imageView;
@property(readwrite,assign)int index;
@property(readwrite,assign)id delegate;

@end

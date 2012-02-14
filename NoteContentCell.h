//
//  NoteContentCell.h
//  ARIS
//
//  Created by Brian Thiel on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteContent.h"
@interface NoteContentCell : UITableViewCell<UITextViewDelegate>{
    IBOutlet UITextView *titleLbl;
    IBOutlet UILabel *detailLbl;
    IBOutlet UILabel *holdLbl;
    IBOutlet UIImageView *imageView;
    int contentId;
    int index;
    id delegate;
    NoteContent<NoteContentProtocol>*content;
   IBOutlet UIButton *retryButton;
    IBOutlet UIActivityIndicatorView *spinner;
}
@property(readwrite, assign)int contentId;
@property(nonatomic,retain)UITextView *titleLbl;
@property(nonatomic,retain)UILabel *detailLbl;
@property(nonatomic,retain) IBOutlet UILabel *holdLbl;
@property(nonatomic,retain)UIImageView *imageView;
@property(readwrite,assign)int index;
@property(readwrite,assign)id delegate;
@property(nonatomic, retain)NoteContent<NoteContentProtocol>*content;
@property(nonatomic,retain)IBOutlet UIButton *retryButton;
@property(nonatomic,retain)IBOutlet UIActivityIndicatorView *spinner;
-(void)checkForRetry;
-(IBAction)retryUpload;
@end

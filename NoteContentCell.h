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
    id __unsafe_unretained delegate;
    NoteContent *content;
   IBOutlet UIButton *retryButton;
    IBOutlet UIActivityIndicatorView *spinner;
    UITableView *__unsafe_unretained parentTableView;
    NSIndexPath *indexPath;
}
@property(readwrite, assign)int contentId;
@property(nonatomic)UITextView *titleLbl;
@property(nonatomic)UILabel *detailLbl;
@property(nonatomic) IBOutlet UILabel *holdLbl;
@property(nonatomic)UIImageView *imageView;
@property(readwrite,assign)int index;
@property(nonatomic, unsafe_unretained)id delegate;
@property(nonatomic)NoteContent *content;
@property(nonatomic)IBOutlet UIButton *retryButton;
@property(nonatomic)IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic,unsafe_unretained) UITableView *parentTableView;
@property(nonatomic)NSIndexPath *indexPath;
-(void)checkForRetry;
-(IBAction)retryUpload;
@end

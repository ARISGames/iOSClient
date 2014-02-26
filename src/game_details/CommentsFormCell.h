//
//  CommentsFormCell.h
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "commentsViewController.h"

@interface CommentsFormCell : UITableViewCell <UITextViewDelegate>

- (IBAction) saveComment:(id)sender;

@end

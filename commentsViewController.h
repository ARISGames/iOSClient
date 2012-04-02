//
//  MyClass.h
//  ARIS
//
//  Created by Brian Thiel on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Game.h"
#import "ARISAppDelegate.h"
#import "CommentCell.h"
#import "Comment.h"

@interface commentsViewController :UIViewController <UITableViewDelegate,UITableViewDataSource> {
	UITableView *tableView;
    int defaultRating;
    Game *game;
}
-(void)showLoadingIndicator;
-(void)addComment: (Comment *) comment;
-(int)calculateTextHeight:(NSString *)text;
@property(nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) int defaultRating;
@property(nonatomic) Game *game;
@end

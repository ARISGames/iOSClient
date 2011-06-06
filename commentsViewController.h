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

@interface commentsViewController :UIViewController <UITableViewDelegate,UITableViewDataSource> {
	UITableView *commentsTable;
	NSArray *commentsList;
    Game *game;
}
-(void)showLoadingIndicator;
@property(nonatomic, retain) IBOutlet UITableView *commentsTable;
@property(nonatomic, retain) NSArray *commentsList;
@property(nonatomic, retain) Game *game;
@end

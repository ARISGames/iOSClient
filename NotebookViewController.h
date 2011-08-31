//
//  NotebookViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Comment.h"

@interface NotebookViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *noteList;
    NSMutableArray *gameNoteList;

    IBOutlet UISegmentedControl *noteControl;
	UITableView *noteTable;
    NSInteger count;
}

-(void)refresh;
-(void)showLoadingIndicator;
-(IBAction)controlChanged:(id)sender;
- (void)refreshViewFromModel;
-(void)addNote;
@property (nonatomic, retain) NSMutableArray *noteList;
@property (nonatomic, retain) NSMutableArray *gameNoteList;

@property (nonatomic, retain) IBOutlet UITableView *noteTable;

@property(nonatomic,retain)IBOutlet UISegmentedControl *noteControl;
@end

//
//  QuestsViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "Quest.h"


@interface QuestsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIWebViewDelegate> {
	NSMutableArray *quests;
	NSMutableArray *questCells;
	int cellsLoaded;
	IBOutlet UITableView *tableView;
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *progressLabel;
    IBOutlet UISegmentedControl *activeQuestsSwitch;
    int activeSort;
	int silenceNextServerUpdateCount;
	int newItemsSinceLastView;
    BOOL isLink;
}
@property(readwrite, assign) BOOL isLink;
@property(nonatomic, retain) NSMutableArray *quests;
@property(nonatomic, retain) NSMutableArray *questCells;
@property(nonatomic, retain) UISegmentedControl *activeQuestsSwitch;
@property(readwrite, assign) int activeSort;

- (void)refresh;
- (void)showLoadingIndicator;
- (void)removeLoadingIndicator;
-(void)dismissTutorial;
- (void)constructCells;
- (UITableViewCell*) getCellContentViewForQuest:(Quest*)quest inSection:(int)section;
- (void)updateCellSize:(UITableViewCell*)cell;
- (IBAction)filterQuests;
-(void)refreshViewFromModel;




@end

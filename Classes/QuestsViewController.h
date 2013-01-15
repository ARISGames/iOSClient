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
    NSArray *sortedActiveQuests;
    NSArray *sortedCompletedQuests;
	NSMutableArray *questCells;
	int cellsLoaded;
	IBOutlet UITableView *tableView;
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *progressLabel;
    IBOutlet UISegmentedControl *activeQuestsSwitch;
	int silenceNextServerUpdateCount;
	int newItemsSinceLastView;
    BOOL isLink;
}
@property(readwrite, assign) BOOL isLink;
@property(nonatomic) NSMutableArray *quests;
@property(nonatomic) NSMutableArray *questCells;
@property(nonatomic) UISegmentedControl *activeQuestsSwitch;

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

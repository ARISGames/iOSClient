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


@interface QuestsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIWebViewDelegate>
{
    NSArray *sortedActiveQuests;
    NSArray *sortedCompletedQuests;
    NSMutableArray *activeQuestCells;
    NSMutableArray *completedQuestCells;
    int cellsLoaded;
    BOOL isLink;
    int badgeCount;
    
	IBOutlet UITableView *tableView;
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *progressLabel;
    IBOutlet UISegmentedControl *activeQuestsSwitch;
}

- (void)refresh;
- (void)refreshViewFromModel;
- (void)showLoadingIndicator;
- (void)removeLoadingIndicator;
- (void)dismissTutorial;
- (IBAction)sortQuestsButtonTouched;

@end
//
//  QuestsViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"
#import "QuestsViewControllerDelegate.h"

@interface QuestsViewController : ARISGamePlayTabBarViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
{
    NSArray *sortedActiveQuests;
    NSArray *sortedCompletedQuests;
    NSMutableArray *activeQuestCells;
    NSMutableArray *completedQuestCells;
    int cellsLoaded;
    
	IBOutlet UITableView *tableView;
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *progressLabel;
    IBOutlet UISegmentedControl *activeQuestsSwitch;
}

- (id)initWithDelegate:(id<QuestsViewControllerDelegate>)d;
- (void)refresh;
- (void)refreshViewFromModel;
- (void)showLoadingIndicator;
- (void)removeLoadingIndicator;
- (void)dismissTutorial;
- (IBAction)sortQuestsButtonTouched;

@end
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
    NSMutableArray *quests;
    NSMutableArray *questCells;
    NSArray *sortedActiveQuests;
    NSArray *sortedCompletedQuests;
	
	IBOutlet UITableView *tableView;
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *progressLabel;
    IBOutlet UISegmentedControl *activeQuestsSwitch;
    
    int newItemsSinceLastView;
    int silenceNextServerUpdateCount;
}

- (void)refresh;
- (void)refreshViewFromModel;
- (void)showLoadingIndicator;
- (void)removeLoadingIndicator;
- (void)dismissTutorial;
- (IBAction)sortQuestsButtonTouched;

@end
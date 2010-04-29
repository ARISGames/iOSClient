//
//  QuestsViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISAppDelegate.h";
#import "model/AppModel.h";


@interface QuestsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIWebViewDelegate> {
	AppModel *appModel;
	NSMutableArray *quests;
	NSMutableArray *questCells;
	int cellsLoaded;
	IBOutlet UITableView *tableView;
	BOOL silenceNextServerUpdate;
}

@property(nonatomic, retain) NSMutableArray *quests;
@property(nonatomic, retain) NSMutableArray *questCells;


- (void)refresh;


@end

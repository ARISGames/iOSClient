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


@interface QuestsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate> {
	AppModel *appModel;
	NSMutableArray *quests;
	IBOutlet UITableView *tableView;
	BOOL silenceNextServerUpdate;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) NSMutableArray *quests;


- (void)refresh;


@end

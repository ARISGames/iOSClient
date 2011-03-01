//
//  GamePickerViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"

@interface GamePickerViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>{
	AppModel *appModel;
	NSArray *gameList;
	NSMutableArray *filteredGameList;

	UITableView *gameTable;
	NSTimer *refreshTimer;

}

-(void) refresh;
-(void)showLoadingIndicator;


@property (nonatomic, retain) NSArray *gameList;
@property (nonatomic, retain) NSMutableArray *filteredGameList;
@property (nonatomic, retain) IBOutlet UITableView *gameTable;


@end

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
	NSArray *gameList;
	NSMutableArray *filteredGameList;

	UITableView *gameTable;
    UIBarButtonItem *refreshButton;

}

-(void) refresh;
-(void)showLoadingIndicator;


@property (nonatomic, retain) NSArray *gameList;
@property (nonatomic, retain) NSMutableArray *filteredGameList;
@property (nonatomic, retain) IBOutlet UITableView *gameTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;


@end

//
//  GamePickerViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"

@interface GamePickerViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>{
	NSArray *gameList;
	NSMutableArray *filteredGameList;

    UISegmentedControl *distanceControl;
    UISegmentedControl *locationalControl;
	UITableView *gameTable;
    UIBarButtonItem *refreshButton;

}

-(void) refresh;
-(void)showLoadingIndicator;


@property (nonatomic, retain) NSArray *gameList;
@property (nonatomic, retain) NSMutableArray *filteredGameList;
@property (nonatomic, retain) IBOutlet UITableView *gameTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl *distanceControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *locationalControl;



@end

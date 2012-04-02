//
//  DeveloperViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Location.h"

@interface DeveloperViewController : UIViewController {	
	UITableView *locationTable;
	NSMutableArray *locationTableData;
	UIButton *clearEventsButton;
	UIButton *clearItemsButton;
	UILabel *accuracyLabelValue;
}

@property(nonatomic) IBOutlet UITableView *locationTable;
@property(nonatomic) IBOutlet NSMutableArray *locationTableData;
@property(nonatomic) IBOutlet UIButton *clearEventsButton;
@property(nonatomic) IBOutlet UIButton *clearItemsButton;
@property(nonatomic) IBOutlet UILabel *accuracyLabelValue;

-(IBAction)clearEventsButtonTouched: (id) sender;
-(IBAction)clearItemsButtonTouched: (id) sender;

-(void) refresh;
@end

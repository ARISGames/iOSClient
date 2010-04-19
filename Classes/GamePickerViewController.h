//
//  GamePickerViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"

@interface GamePickerViewController : UITableViewController {
	AppModel *appModel;
	NSMutableArray *nearGameList;
	NSMutableArray *farGameList;
	UITableView *gameTable;
}

-(void) slideIn;
-(void) slideOut;
-(void) refresh;

@property (nonatomic, retain) NSMutableArray *nearGameList;
@property (nonatomic, retain) NSMutableArray *farGameList;
@property (nonatomic, retain) IBOutlet UITableView *gameTable;


@end

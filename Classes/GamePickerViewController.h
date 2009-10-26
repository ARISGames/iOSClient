//
//  GamePickerViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GamePickerViewController : UITableViewController {
	NSMutableArray *gameList;
	UITableView *gameTable;
}

-(void) slideIn;
-(void) slideOut;
-(void) setGameList:(NSMutableArray *)list;

@property (nonatomic, retain) IBOutlet UITableView *gameTable;

@end

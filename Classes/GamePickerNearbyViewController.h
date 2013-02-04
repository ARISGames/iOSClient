//
//  GamePickerNEarbyViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Comment.h"

@interface GamePickerNearbyViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
	NSArray *gameList;
    IBOutlet UISegmentedControl *distanceControl;
    IBOutlet UISegmentedControl *locationalControl;
	UITableView *gameTable;
    UIBarButtonItem *refreshButton;
    NSInteger count;
}

-(void)refresh;
-(void)showLoadingIndicator;
-(IBAction)controlChanged:(id)sender;
-(void)refreshViewFromModel;

@property (nonatomic, copy) NSArray *gameList;
@property (nonatomic) IBOutlet UITableView *gameTable;
@property (nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (assign) NSInteger count;

@end

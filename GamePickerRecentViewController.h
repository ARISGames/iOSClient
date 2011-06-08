//
//  GamePickerRecentViewController.h
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Comment.h"
@interface GamePickerRecentViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>{

	NSArray *gameList;
	NSMutableArray *filteredGameList;
    
    IBOutlet UISegmentedControl *distanceControl;
    IBOutlet UISegmentedControl *locationalControl;
	UITableView *gameTable;
    UIBarButtonItem *refreshButton;
    
}

-(void)refresh;
-(void)showLoadingIndicator;
-(IBAction)controlChanged:(id)sender;


@property (nonatomic, retain) NSArray *gameList;
@property (nonatomic, retain) NSMutableArray *filteredGameList;
@property (nonatomic, retain) IBOutlet UITableView *gameTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;



@end

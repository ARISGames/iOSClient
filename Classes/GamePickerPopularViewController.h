//
//  GamePickerPopularViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Comment.h"

@interface GamePickerPopularViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    
	NSArray *gameList;
    IBOutlet UISegmentedControl *timeControl;
	UITableView *gameTable;
    UIBarButtonItem *refreshButton;
    NSInteger count;
    NSArray *gameIcons;
}

-(void)refresh;
-(void)showLoadingIndicator;
-(IBAction)controlChanged:(id)sender;
- (void)refreshViewFromModel;

@property (nonatomic, copy) NSArray *gameList;
@property (nonatomic) IBOutlet UITableView *gameTable;
@property (nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic) NSArray *gameIcons;
@property (assign) NSInteger count;

@end

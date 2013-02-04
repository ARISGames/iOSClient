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

@interface GamePickerRecentViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
	NSArray *gameList;
	UITableView *gameTable;
    UIBarButtonItem *refreshButton;
}

-(void)refresh;
-(void)showLoadingIndicator;
-(void)controlChanged:(id)sender;
- (void)refreshViewFromModel;

@property (nonatomic, copy) NSArray *gameList;
@property (nonatomic) IBOutlet UITableView *gameTable;
@property (nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@end

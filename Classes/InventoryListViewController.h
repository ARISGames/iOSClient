//
//  FilesViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "Item.h"
#import "ItemDetailsViewController.h"

@interface InventoryListViewController : UIViewController {
	UITableView *inventoryTable;
	NSArray *inventory;
	NSMutableArray *iconCache;
    NSMutableArray *mediaCache;
    int silenceNextServerUpdateCount;
	int newItemsSinceLastView;
    UIProgressView *capBar;
    UILabel *capLabel;
    int weightCap;
    int currentWeight;
}

@property(readwrite, assign) int weightCap;
@property(readwrite, assign) int currentWeight;
@property(nonatomic, retain) IBOutlet UIProgressView *capBar;
@property(nonatomic, retain) IBOutlet UILabel *capLabel;
@property(nonatomic, retain) IBOutlet UITableView *inventoryTable;
@property(nonatomic, retain) NSArray *inventory;
@property(nonatomic, retain) NSMutableArray *iconCache;
@property(nonatomic, retain) NSMutableArray *mediaCache;

- (void) refresh;
- (unsigned int) indexOf:(char) searchChar inString:(NSString *)searchString;
- (void)showLoadingIndicator;
- (void)dismissTutorial;
- (void)refreshViewFromModel;


@end

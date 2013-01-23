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
    UIBarButtonItem *tradeButton;
    int silenceNextServerUpdateCount;
	int newItemsSinceLastView;
    UIProgressView *capBar;
    UILabel *capLabel;
    int weightCap;
    int currentWeight;
    
    NSMutableDictionary *iconCache;
    NSMutableDictionary *mediaCache;
}

@property(readwrite, assign) int weightCap;
@property(readwrite, assign) int currentWeight;
@property(nonatomic) IBOutlet UIProgressView *capBar;
@property(nonatomic) IBOutlet UILabel *capLabel;
@property(nonatomic) IBOutlet UITableView *inventoryTable;
@property(nonatomic) IBOutlet UIBarButtonItem *tradeButton;
@property(nonatomic) NSArray *inventory;

@property(nonatomic) NSMutableDictionary *iconCache;
@property(nonatomic) NSMutableDictionary *mediaCache;

- (void) refresh;
- (unsigned int) indexOf:(char) searchChar inString:(NSString *)searchString;
- (void)showLoadingIndicator;
- (void)dismissTutorial;
- (void)refreshViewFromModel;
-(NSString *) stringByStrippingHTML:(NSString *)stringToStrip;

@end

//
//  FilesViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "Item.h"
#import "ItemViewController.h"

@protocol StateControllerProtocol;

@protocol InventoryViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface InventoryViewController : ARISGamePlayTabBarViewController
{
	UITableView *inventoryTable;
	NSArray *inventory;
    UIBarButtonItem *tradeButton;
    UIProgressView *capBar;
    UILabel *capLabel;
    
    NSMutableDictionary *iconCache;
    NSMutableDictionary *mediaCache;
}

@property(nonatomic) IBOutlet UIProgressView *capBar;
@property(nonatomic) IBOutlet UILabel *capLabel;
@property(nonatomic) IBOutlet UITableView *inventoryTable;
@property(nonatomic) IBOutlet UIBarButtonItem *tradeButton;
@property(nonatomic) NSArray *inventory;

@property(nonatomic) NSMutableDictionary *iconCache;
@property(nonatomic) NSMutableDictionary *mediaCache;

- (id) initWithDelegate:(id<InventoryViewControllerDelegate, StateControllerProtocol>)d;
- (void) refresh;
- (unsigned int) indexOf:(char)searchChar inString:(NSString *)searchString;
- (void) showLoadingIndicator;
- (void) dismissTutorial;
- (void) refreshViewFromModel;
-(NSString *) stringByStrippingHTML:(NSString *)stringToStrip;

@end

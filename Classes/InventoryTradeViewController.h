//
//  InventoryTradeViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "AppServices.h"
#import "ARISAppDelegate.h"
#import "BumpClient.h"
#import "Item.h"

@interface InventoryTradeViewController : UIViewController {
	UITableView *tradeTableView;
	NSMutableArray *inventory;
    NSMutableArray *itemsToTrade;
	NSMutableArray *iconCache;
    NSMutableArray *mediaCache;
    BOOL isConnectedToBump;
    id delegate;
}

@property(nonatomic) IBOutlet UITableView *tradeTableView;
@property(nonatomic) NSMutableArray *inventory;
@property(nonatomic) NSMutableArray *itemsToTrade;
@property(nonatomic) NSMutableArray *iconCache;
@property(nonatomic) NSMutableArray *mediaCache;
@property(nonatomic) BOOL isConnectedToBump;
@property(nonatomic) id delegate;

- (NSString *)generateTransactionJSON;
@end

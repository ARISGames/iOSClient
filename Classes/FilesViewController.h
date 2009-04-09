//
//  FilesViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";
#import "Item.h";
#import "ItemDetailsViewController.h";

@interface FilesViewController : UIViewController {
	NSString *moduleName;
	AppModel *appModel;	
	UITableView *inventoryTable;
	NSMutableArray *inventoryTableData;
}

-(void) setModel:(AppModel *)model;
-(void) refreshInventory;

@property(copy, readwrite) NSString *moduleName;
@property(nonatomic, retain) IBOutlet UITableView *inventoryTable;
@property(nonatomic, retain) IBOutlet NSMutableArray *inventoryTableData;

@end

//
//  AttributesViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "Item.h"
#import "ItemDetailsViewController.h"

@interface AttributesViewController : UIViewController<UITableViewDataSource,UITableViewDataSource> {
    int silenceNextServerUpdateCount;
	UITableView *attributesTable;
	NSArray *attributes;
    NSMutableArray *iconCache;
    AsyncMediaView	*pcImage;
    UIButton *addGroupButton;
    UILabel *nameLabel;
    UILabel *groupLabel;

}
@property(nonatomic, retain) IBOutlet UITableView *attributesTable;
@property(nonatomic, retain) NSArray *attributes;
@property(nonatomic, retain) NSMutableArray *iconCache;
@property(nonatomic, retain) IBOutlet AsyncMediaView	*pcImage;
@property(nonatomic, retain) IBOutlet UIButton  *addGroupButton;
@property(nonatomic, retain) IBOutlet UILabel *nameLabel;
@property(nonatomic, retain) IBOutlet UILabel *groupLabel;


- (void) refresh;
- (void)showLoadingIndicator;
-(IBAction)groupButtonPressed;

@end

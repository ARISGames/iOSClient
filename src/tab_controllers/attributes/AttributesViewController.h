//
//  AttributesViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "Item.h"
#import "ItemViewController.h"

@protocol AttributesViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface AttributesViewController : ARISGamePlayTabBarViewController <UITableViewDataSource,UITableViewDataSource>
{
	UITableView *attributesTable;
	NSArray *attributes;
    NSMutableArray *iconCache;
    AsyncMediaImageView	*pcImage;
    UIButton *addGroupButton;
    UILabel *nameLabel;
    UILabel *groupLabel;
}

@property(nonatomic) IBOutlet UITableView *attributesTable;
@property(nonatomic) NSArray *attributes;
@property(nonatomic) NSMutableArray *iconCache;
@property(nonatomic) IBOutlet AsyncMediaImageView	*pcImage;
@property(nonatomic) IBOutlet UIButton  *addGroupButton;
@property(nonatomic) IBOutlet UILabel *nameLabel;
@property(nonatomic) IBOutlet UILabel *groupLabel;
@property(nonatomic) int newAttrsSinceLastView;

- (id) initWithDelegate:(id<AttributesViewControllerDelegate>)d;
- (void) refresh;
-(IBAction)groupButtonPressed;

@end

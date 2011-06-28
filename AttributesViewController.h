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

@interface AttributesViewController : UIViewController {
    int silenceNextServerUpdateCount;
	UITableView *attributesTable;
	NSArray *attributes;
    IBOutlet	AsyncImageView	*pcImage;

}
@property(nonatomic, retain) IBOutlet UITableView *attributesTable;
@property(nonatomic, retain) NSArray *attributes;
@property(nonatomic, retain) IBOutlet AsyncImageView	*pcImage;

- (void) refresh;
- (void)showLoadingIndicator;

@end

//
//  NearbyObjectsViewController.h
//  ARIS
//
//  Created by David J Gagnon on 2/13/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyObjectProtocol.h"


@interface NearbyObjectsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate> {
	NSMutableArray *oldNearbyLocationList;
	IBOutlet UITableView *nearbyTable;
}

@property(nonatomic) NSMutableArray *oldNearbyLocationList;

- (void)refreshViewFromModel;
- (void)refresh;
- (void)dismissTutorial;


@end

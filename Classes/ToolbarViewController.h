//
//  ToolbarViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyLocation.h"



@interface ToolbarViewController : UIViewController {
	UILabel *titleLabel;
	UINavigationItem *navigationItem;
	UIView *sv;
}

-(void) setToolbarTitle:(NSString *)title;
-(void) nearbyButtonAction:(id)sender;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;


@end

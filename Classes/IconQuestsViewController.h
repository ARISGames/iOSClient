//
//  IconQuestsViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "Quest.h"

@interface IconQuestsViewController : UIViewController {
	NSMutableArray *quests;
    int activeSort;
    int silenceNextServerUpdateCount;
    int newItemsSinceLastView;
    BOOL isLink;
}
@property(readwrite, assign) BOOL isLink;
@property(nonatomic) NSMutableArray *quests;
@property(readwrite, assign) int activeSort;

- (void)refresh;
- (void)showLoadingIndicator;
- (void)removeLoadingIndicator;
- (void)dismissTutorial;
- (void)refreshViewFromModel;

@end

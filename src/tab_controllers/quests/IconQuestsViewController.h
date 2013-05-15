//
//  IconQuestsViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"
#import "QuestsViewControllerDelegate.h"

#define ICONWIDTH 76
#define ICONHEIGHT 90
#define ICONSPERROW 3
#define TEXTLABELHEIGHT 10
#define TEXTLABELPADDING 7

@interface IconQuestsViewController : ARISGamePlayTabBarViewController <UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIScrollView *questIconScrollView;
    UICollectionView *questIconCollectionView;
    UICollectionViewFlowLayout *questIconCollectionViewLayout;
    
    int newItemsSinceLastView;
    int itemsPerColumnWithoutScrolling;
    int initialHeight;
    
    BOOL supportsCollectionView;
    NSArray *sortedQuests;
}
@property(nonatomic) NSMutableArray *quests;

- (id)initWithDelegate:(id<QuestsViewControllerDelegate>)d;
- (void)refresh;
- (void)showLoadingIndicator;
- (void)removeLoadingIndicator;
- (void)dismissTutorial;
- (void)refreshViewFromModel;

@end

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
#import "IconQuestsButton.h"
#import "QuestDetailsViewController.h"

#import "AppServices.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "WebPage.h"
#import "webpageViewController.h"

#define ICONWIDTH 76
#define ICONHEIGHT 90
#define ICONSPERROW 3
#define TEXTLABELHEIGHT 10
#define TEXTLABELPADDING 7

@interface IconQuestsViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate> {
    UIScrollView *questIconScrollView;
    UICollectionView *questIconCollectionView;
    UICollectionViewFlowLayout *questIconCollectionViewLayout;
    
    int newItemsSinceLastView;
}
@property(nonatomic) NSMutableArray *quests;

- (void)refresh;
- (void)showLoadingIndicator;
- (void)removeLoadingIndicator;
- (void)dismissTutorial;
- (void)refreshViewFromModel;

@end

//
//  IconQuestsViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IconQuestsViewController.h"
#import "Quest.h"
#import "QuestDetailsViewController.h"
#import "Media.h"
#import "ARISMediaView.h"
#import "AppModel.h"
#import "MediaModel.h"

@interface IconQuestsViewController() <ARISMediaViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,QuestDetailsViewControllerDelegate>
{
    Tab *tab;
    UICollectionView *questIconCollectionView;

    NSArray *activeQuests;
    NSArray *completeQuests;

    id<QuestsViewControllerDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, strong) UICollectionView *questIconCollectionView;

@end

@implementation IconQuestsViewController

@synthesize questIconCollectionView;

- (id) initWithTab:(Tab *)t delegate:(id<QuestsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tab = t;
        delegate = d;
        self.title = self.tabTitle;

        _ARIS_NOTIF_LISTEN_(@"MODEL_QUESTS_COMPLETE_NEW_AVAILABLE",self,@selector(refreshViewFromModel),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_QUESTS_COMPLETE_LESS_AVAILABLE",self,@selector(refreshViewFromModel),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_QUESTS_ACTIVE_NEW_AVAILABLE",self,@selector(refreshViewFromModel),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_QUESTS_ACTIVE_LESS_AVAILABLE",self,@selector(refreshViewFromModel),nil);
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [ARISTemplate ARISColorViewBackdrop];

    UICollectionViewFlowLayout *questIconCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    questIconCollectionViewLayout.itemSize = CGSizeMake(100, 120);
    questIconCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    questIconCollectionViewLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    questIconCollectionViewLayout.minimumLineSpacing = 5.0;
    questIconCollectionViewLayout.minimumInteritemSpacing = 5.0;

    questIconCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:questIconCollectionViewLayout];
    questIconCollectionView.backgroundColor = [UIColor clearColor];
    questIconCollectionView.dataSource = self;
    questIconCollectionView.delegate = self;
    [questIconCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:questIconCollectionView];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    //apple. so dumb.
    questIconCollectionView.frame = self.view.bounds;
    questIconCollectionView.contentInset = UIEdgeInsetsMake(64,0,0,0);
    [questIconCollectionView setContentOffset:CGPointMake(0,-64)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
    [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside];
    threeLineNavButton.accessibilityLabel = @"In-Game Menu";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshViewFromModel];
}

- (void) refreshViewFromModel
{
    activeQuests   = _ARIS_ARRAY_SORTED_ON_(_MODEL_QUESTS_.visibleActiveQuests,@"sort_index");
    completeQuests = _ARIS_ARRAY_SORTED_ON_(_MODEL_QUESTS_.visibleCompleteQuests,@"sort_index");
    [self.questIconCollectionView reloadData];
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return activeQuests.count + completeQuests.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];

    for(UIView *view in [cell.contentView subviews])
        [view removeFromSuperview];

    Quest *q;

    if(indexPath.item < activeQuests.count) q = [activeQuests   objectAtIndex:indexPath.item];
    else                                    q = [completeQuests objectAtIndex:indexPath.item-activeQuests.count];

    CGRect textFrame = CGRectMake(0, (cell.contentView.frame.size.height-20), cell.contentView.frame.size.width, 20);
    UILabel *iconTitleLabel = [[UILabel alloc] initWithFrame:textFrame];
    iconTitleLabel.text = q.name;
    iconTitleLabel.textColor = [ARISTemplate ARISColorViewText];
    iconTitleLabel.backgroundColor = [UIColor clearColor];
    iconTitleLabel.textAlignment = NSTextAlignmentCenter;
    iconTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;// NSLineBreakByTruncatingTail;
    iconTitleLabel.font = [ARISTemplate ARISSubtextFont];
    [cell.contentView addSubview:iconTitleLabel];

    ARISMediaView *icon = [[ARISMediaView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.width) delegate:self];
    [icon setDisplayMode:ARISMediaDisplayModeAspectFit];
    if(indexPath.item < activeQuests.count)
    {
        if(q.active_icon_media_id != 0) [icon setMedia:[_MODEL_MEDIA_ mediaForId:q.active_icon_media_id]];
        else                            [icon setImage:[UIImage imageNamed:@"logo_icon.png"]];
    }
    else
    {
        if(q.complete_icon_media_id != 0) [icon setMedia:[_MODEL_MEDIA_ mediaForId:q.complete_icon_media_id]];
        else                            [icon setImage:[UIImage imageNamed:@"logo_icon.png"]];
    }

    icon.layer.cornerRadius = 11.0f;
    [cell.contentView addSubview:icon];

    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Quest *q;
    if(indexPath.item < activeQuests.count) q = [activeQuests    objectAtIndex:indexPath.item];
    else                                      q = [completeQuests objectAtIndex:indexPath.item-activeQuests.count];

    [[self navigationController] pushViewController:[[QuestDetailsViewController alloc] initWithQuest:q mode:((indexPath.item < activeQuests.count) ? @"ACTIVE" : @"COMPLETE") delegate:self] animated:YES];
}

- (void) questDetailsRequestsDismissal
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"QUESTS"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; return @"Quests"; }
- (UIImage *) tabIcon { return [UIImage imageNamed:@"todo"]; }

@end

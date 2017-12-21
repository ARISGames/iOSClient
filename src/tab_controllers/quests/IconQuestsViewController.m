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
#import <Google/Analytics.h>

@interface IconQuestsViewController() <ARISMediaViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,QuestDetailsViewControllerDelegate>
{
  Tab *tab;
  UICollectionView *questIconCollectionView;
  
  NSArray *activeQuests;
  NSArray *completeQuests;
  
  NSMutableDictionary *questCategories;
  NSMutableDictionary *questCategoryTitles;
  NSMutableArray *questCategoryList;
  
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
    questIconCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
  if(_MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
  {
    questIconCollectionViewLayout.itemSize = CGSizeMake(200, 240);
    questIconCollectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    questIconCollectionViewLayout.minimumLineSpacing = 10.0;
    questIconCollectionViewLayout.minimumInteritemSpacing = 10.0;
  }
  else
  {
    questIconCollectionViewLayout.itemSize = CGSizeMake(100, 120);
    questIconCollectionViewLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    questIconCollectionViewLayout.minimumLineSpacing = 5.0;
    questIconCollectionViewLayout.minimumInteritemSpacing = 5.0;
  }
  
  questIconCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:questIconCollectionViewLayout];
  questIconCollectionView.backgroundColor = [UIColor clearColor];
  questIconCollectionView.dataSource = self;
  questIconCollectionView.delegate = self;
  [questIconCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
  [questIconCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
  [self.view addSubview:questIconCollectionView];
}

- (void) viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  //apple. so dumb.
  questIconCollectionView.frame = self.view.bounds;
  // MT: these appear to not be necessary on iOS 11
  if ( 11 > [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue] ) {
    questIconCollectionView.contentInset = UIEdgeInsetsMake(64,0,0,0);
    [questIconCollectionView setContentOffset:CGPointMake(0,-64)];
  }
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
  [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
  [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside];
  threeLineNavButton.accessibilityLabel = @"In-Game Menu";
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
  // newly required in iOS 11: https://stackoverflow.com/a/44456952
  if ([threeLineNavButton respondsToSelector:@selector(widthAnchor)] && [threeLineNavButton respondsToSelector:@selector(heightAnchor)]) {
    [[threeLineNavButton.widthAnchor constraintEqualToConstant:27.0] setActive:true];
    [[threeLineNavButton.heightAnchor constraintEqualToConstant:27.0] setActive:true];
  }
  
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName value:self.title];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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
  
  NSArray *allQuests = [activeQuests arrayByAddingObjectsFromArray:completeQuests];
  
  questCategories = [[NSMutableDictionary alloc] init];
  questCategoryTitles = [[NSMutableDictionary alloc] init];
  questCategoryList = [[NSMutableArray alloc] init];
  // first, find all the categories
  [questCategoryTitles setValue:@"" forKey:@"0"];
  [questCategoryList addObject:@"0"];
  [questCategories setValue:[[NSMutableArray alloc] init] forKey:@"0"];
  for (Quest *q in allQuests) {
    if ([q.quest_type isEqualToString:@"CATEGORY"]) {
      NSString *category_id = [NSString stringWithFormat:@"%ld", q.quest_id];
      [questCategoryTitles setValue:q.name forKey:category_id];
      [questCategoryList addObject:category_id];
      [questCategories setValue:[[NSMutableArray alloc] init] forKey:category_id];
    }
  }
  // then sort quests into categories
  for (Quest *q in allQuests) {
    if (![q.quest_type isEqualToString:@"CATEGORY"]) {
      NSString *category_id = [NSString stringWithFormat:@"%ld", q.parent_quest_id];
      NSMutableArray *category = [questCategories objectForKey:category_id];
      if (!category) {
        category = [questCategories objectForKey:@"0"];
      }
      [category addObject:q];
    }
  }
  
  [self.questIconCollectionView reloadData];
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return [questCategoryList count];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return [[questCategories objectForKey:[questCategoryList objectAtIndex:section]] count];
}

- (Quest *) getQuestAt:(NSIndexPath *)indexPath
{
  return [[questCategories objectForKey:[questCategoryList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
}

- (BOOL) isActiveQuest:(Quest *)quest
{
  return [activeQuests indexOfObject:quest] != NSNotFound;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
  cell.backgroundColor = [UIColor clearColor];
  
  for(UIView *view in [cell.contentView subviews])
    [view removeFromSuperview];
  
  Quest *q = [self getQuestAt:indexPath];
  
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
  if([self isActiveQuest:q])
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return CGSizeMake(0, 0);
  } else {
    return CGSizeMake(0, 60);
  }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [questCategoryTitles objectForKey:[questCategoryList objectAtIndex:indexPath.section]];
    label.textColor = [UIColor ARISColorBlack];
    label.backgroundColor = [UIColor ARISColorLightGray];
    label.font = [UIFont boldSystemFontOfSize:18.0];
    [reusableview addSubview:label];
    return reusableview;
  }
  return nil;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  Quest *q = [self getQuestAt:indexPath];
  
  [[self navigationController] pushViewController:[[QuestDetailsViewController alloc] initWithQuest:q mode:([self isActiveQuest:q] ? @"ACTIVE" : @"COMPLETE") delegate:self] animated:YES];
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
- (ARISMediaView *) tabIcon
{
  ARISMediaView *amv = [[ARISMediaView alloc] init];
  if(tab.icon_media_id)
    [amv setMedia:[_MODEL_MEDIA_ mediaForId:tab.icon_media_id]];
  else
    [amv setImage:[UIImage imageNamed:@"todo"]];
  return amv;
}

@end

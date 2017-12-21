//
//  QuestsViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "QuestsViewController.h"
#import "AppModel.h"
#import "Quest.h"
#import "QuestCell.h"
#import "QuestDetailsViewController.h"
#import "Media.h"
#import "WebPage.h"
#import "WebPageViewController.h"
#import "ARISWebView.h"
#import <Google/Analytics.h>


static long const ACTIVE_SECTION = 0;
static long const COMPLETE_SECTION = 1;

@interface QuestsViewController() <UITableViewDataSource, UITableViewDelegate, ARISWebViewDelegate, QuestCellDelegate, QuestDetailsViewControllerDelegate>
{
  Tab *tab;

  NSArray *sortedActiveQuests;
  NSArray *sortedCompleteQuests;
  NSMutableDictionary *activeQuestCellHeights;
  NSMutableDictionary *completeQuestCellHeights;
  
  NSMutableDictionary *activeQuestCategories;
  NSMutableDictionary *completeQuestCategories;
  NSMutableDictionary *questCategoryTitles;
  NSMutableArray *questCategoryList;

  UITableView *questsTable;
  UIButton *activeButton;
  UIButton *completeButton;

  long questTypeShown;

  id<QuestsViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation QuestsViewController

- (id) initWithTab:(Tab *)t delegate:(id<QuestsViewControllerDelegate>)d
{
  if(self = [super init])
  {
    tab = t;
    self.title = self.tabTitle;
    
    questTypeShown = ACTIVE_SECTION;
    sortedActiveQuests = [[NSArray alloc] init];
    sortedCompleteQuests = [[NSArray alloc] init];
    activeQuestCellHeights = [[NSMutableDictionary alloc] initWithCapacity:10];
    completeQuestCellHeights = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    delegate = d;
    
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
  self.view.backgroundColor = [UIColor whiteColor];
  
  questsTable = [[UITableView alloc]  init];
  questsTable.dataSource = self;
  questsTable.delegate = self;
  
  activeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [activeButton setTitle:NSLocalizedString(@"QuestsActiveTitleKey", @"") forState:UIControlStateNormal];
  [activeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  activeButton.backgroundColor = [UIColor ARISColorDarkBlue];
  activeButton.titleLabel.font = [ARISTemplate ARISButtonFont];
  [activeButton addTarget:self action:@selector(activeButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  
  completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [completeButton setTitle:NSLocalizedString(@"QuestsCompleteTitleKey", @"") forState:UIControlStateNormal];
  [completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  completeButton.backgroundColor = [UIColor ARISColorLightBlue];
  completeButton.titleLabel.font = [ARISTemplate ARISButtonFont];
  [completeButton addTarget:self action:@selector(completeButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:questsTable];
  [self.view addSubview:activeButton];
  [self.view addSubview:completeButton];
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

- (void) viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  activeButton.frame   = CGRectMake(0, 64, self.view.bounds.size.width/2, 40);
  completeButton.frame = CGRectMake(self.view.bounds.size.width/2, 64, self.view.bounds.size.width/2, 40);
  
  //apple. so dumb.
  questsTable.frame = self.view.bounds;
  // MT: these appear to be different on iOS 11 (only need to account for post-nav space)
  if ( 11 > [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue] ) {
    questsTable.contentInset = UIEdgeInsetsMake(104,0,40,0);
    [questsTable setContentOffset:CGPointMake(0,-104)];
  } else {
    questsTable.contentInset = UIEdgeInsetsMake(40,0,40,0);
    [questsTable setContentOffset:CGPointMake(0,-40)];
  }
}

- (void) viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self refreshViewFromModel];
  [self refreshModels];
}

- (void) refreshModels
{
  [_MODEL_QUESTS_ requestPlayerQuests];
  [self showLoadingIndicator];
}

-(void) refreshViewFromModel
{
  sortedActiveQuests   = _ARIS_ARRAY_SORTED_ON_(_MODEL_QUESTS_.visibleActiveQuests,   @"sort_index");
  sortedCompleteQuests = _ARIS_ARRAY_SORTED_ON_(_MODEL_QUESTS_.visibleCompleteQuests, @"sort_index");
  
  if(sortedActiveQuests.count == 0) // TODO ignore categories in this check
  {
    Quest *nullQuest = [_MODEL_QUESTS_ questForId:0];
    //nullQuest.name = @"<span style='color:#555555;'>Empty</span>";
    nullQuest.name = NSLocalizedString(@"EmptyKey", @"");
    nullQuest.active_desc = [NSString stringWithFormat:@"<span style='color:#555555;'>(%@)</span>", NSLocalizedString(@"QuestViewNoQuestsAvailableKey", @"")];
    sortedActiveQuests = [NSArray arrayWithObjects:nullQuest, nil];
  }
  if(sortedCompleteQuests.count == 0) // TODO ignore categories in this check
  {
    Quest *nullQuest = [_MODEL_QUESTS_ questForId:0];
    //nullQuest.name = @"<span style='color:#555555;'>Empty</span>";
    nullQuest.name = NSLocalizedString(@"EmptyKey", @"");
    nullQuest.complete_desc = [NSString stringWithFormat:@"<span style='color:#555555;'>(%@)</span>", NSLocalizedString(@"QuestViewNocompleteQuestsKey", @"")];
    sortedCompleteQuests = [NSArray arrayWithObjects:nullQuest, nil];
  }
  
  NSArray *allQuests = [sortedActiveQuests arrayByAddingObjectsFromArray:sortedCompleteQuests];
  
  // TODO remove categories with no quests in each of the two tabs
  activeQuestCategories = [[NSMutableDictionary alloc] init];
  completeQuestCategories = [[NSMutableDictionary alloc] init];
  questCategoryTitles = [[NSMutableDictionary alloc] init];
  questCategoryList = [[NSMutableArray alloc] init];
  // first, find all the categories
  [questCategoryTitles setValue:@"" forKey:@"0"];
  [questCategoryList addObject:@"0"];
  [activeQuestCategories setValue:[[NSMutableArray alloc] init] forKey:@"0"];
  [completeQuestCategories setValue:[[NSMutableArray alloc] init] forKey:@"0"];
  for (Quest *q in allQuests) {
    if ([q.quest_type isEqualToString:@"CATEGORY"]) {
      NSString *category_id = [NSString stringWithFormat:@"%ld", q.quest_id];
      [questCategoryTitles setValue:q.name forKey:category_id];
      [questCategoryList addObject:category_id];
      [activeQuestCategories setValue:[[NSMutableArray alloc] init] forKey:category_id];
      [completeQuestCategories setValue:[[NSMutableArray alloc] init] forKey:category_id];
    }
  }
  // then sort quests into categories
  for (Quest *q in sortedActiveQuests) {
    if (![q.quest_type isEqualToString:@"CATEGORY"]) {
      NSString *category_id = [NSString stringWithFormat:@"%ld", q.parent_quest_id];
      NSMutableArray *category = [activeQuestCategories objectForKey:category_id];
      if (!category) {
        category = [activeQuestCategories objectForKey:@"0"];
      }
      [category addObject:q];
    }
  }
  for (Quest *q in sortedCompleteQuests) {
    if (![q.quest_type isEqualToString:@"CATEGORY"]) {
      NSString *category_id = [NSString stringWithFormat:@"%ld", q.parent_quest_id];
      NSMutableArray *category = [completeQuestCategories objectForKey:category_id];
      if (!category) {
        category = [completeQuestCategories objectForKey:@"0"];
      }
      [category addObject:q];
    }
  }
  
  [questsTable reloadData];
}

-(void)showLoadingIndicator
{
  UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
  [[self navigationItem] setRightBarButtonItem:barButton];
  [activityIndicator startAnimating];
}

-(void)removeLoadingIndicator
{
  [[self navigationItem] setRightBarButtonItem:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [questCategoryList count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if(questTypeShown == ACTIVE_SECTION) {
    return [[activeQuestCategories objectForKey:[questCategoryList objectAtIndex:section]] count];
  }
  if(questTypeShown == COMPLETE_SECTION) {
    return [[completeQuestCategories objectForKey:[questCategoryList objectAtIndex:section]] count];
  }
  return 0;
}

- (Quest *) getActiveQuestAt:(NSIndexPath *)indexPath
{
  return [[activeQuestCategories objectForKey:[questCategoryList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
}

- (Quest *) getCompleteQuestAt:(NSIndexPath *)indexPath
{
  return [[activeQuestCategories objectForKey:[questCategoryList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [questCategoryTitles objectForKey:[questCategoryList objectAtIndex:section]];
}

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  QuestCell *cell = [questsTable dequeueReusableCellWithIdentifier:@"QuestCell"];
  if(!cell) cell = [[QuestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QuestCell"];
  
  if(questTypeShown == ACTIVE_SECTION)
    [cell setQuest:[self getActiveQuestAt:indexPath]];
  if(questTypeShown == COMPLETE_SECTION)
    [cell setQuest:[self getCompleteQuestAt:indexPath]];
  
  [cell setDelegate:self];
  
  return cell;
}

- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  Quest *q;
  NSArray *quests;
  NSDictionary *heights;
  if(questTypeShown == ACTIVE_SECTION)
  {
    quests = sortedActiveQuests;
    heights = activeQuestCellHeights;
  }
  if(questTypeShown == COMPLETE_SECTION)
  {
    quests = sortedCompleteQuests;
    heights = completeQuestCellHeights;
  }
  
  q = [quests objectAtIndex:indexPath.row];
  if([heights objectForKey:[q description]])
    return [((NSNumber *)[heights objectForKey:[q description]]) intValue];
  
  NSMutableParagraphStyle *paragraphStyle;
  CGRect textRect;
  paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
  textRect = [q.desc boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, 2000000)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0],NSParagraphStyleAttributeName:paragraphStyle}
                                  context:nil];
  CGSize calcSize = textRect.size;
  return calcSize.height+30;
}

- (void) heightCalculated:(long)h forQuest:(Quest *)q inCell:(QuestCell *)qc
{
  NSDictionary *heights;
  if(questTypeShown == ACTIVE_SECTION)   heights = activeQuestCellHeights;
  if(questTypeShown == COMPLETE_SECTION) heights = completeQuestCellHeights;
  
  if(![heights objectForKey:[q description]])
  {
    [heights setValue:[NSNumber numberWithLong:h] forKey:[q description]];
    [questsTable reloadData];
  }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Quest *q;
  if(questTypeShown == ACTIVE_SECTION)
    q = [sortedActiveQuests objectAtIndex:indexPath.row];
  if(questTypeShown == COMPLETE_SECTION)
    q = [sortedCompleteQuests objectAtIndex:indexPath.row];
  
  if(q.quest_id < 1) return;
  
  [[self navigationController] pushViewController:[[QuestDetailsViewController alloc] initWithQuest:q mode:((questTypeShown == ACTIVE_SECTION) ? @"ACTIVE" : @"COMPLETE") delegate:self] animated:YES];
}

- (void) questDetailsRequestsDismissal
{
  [[self navigationController] popToViewController:self animated:YES];
}

- (void) activeButtonTouched
{
  questTypeShown = ACTIVE_SECTION;
  [activeButton setBackgroundColor:[UIColor ARISColorDarkBlue]];
  [completeButton setBackgroundColor:[UIColor ARISColorLightBlue]];
  [questsTable reloadData];
}

- (void) completeButtonTouched
{
  questTypeShown = COMPLETE_SECTION;
  [completeButton setBackgroundColor:[UIColor ARISColorDarkBlue]];
  [activeButton setBackgroundColor:[UIColor ARISColorLightBlue]];
  [questsTable reloadData];
}

- (void) showNav
{
  [delegate gamePlayTabBarViewControllerRequestsNav];
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

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

//
//  AttributesViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AttributesViewController.h"
#import "User.h"
#import "Media.h"
#import "ARISMediaView.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "ARISAppDelegate.h"
#import "Item.h"
#import "ItemViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AttributesViewController() <ARISMediaViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
  Tab *tab;

  UITableView *attributesTable;
  NSMutableArray *instances;

  NSMutableArray *iconCache;
  ARISMediaView *pcImage;
  UILabel *nameLabel;

  id<AttributesViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation AttributesViewController

- (id) initWithTab:(Tab *)t delegate:(id<AttributesViewControllerDelegate>)d
{
    if(self = [super init])
    {
      tab = t;
      delegate = d;

      self.title = NSLocalizedString(@"PlayerTitleKey",@"");
      instances = [[NSMutableArray alloc] init];
      iconCache = [[NSMutableArray alloc] init];

      _ARIS_NOTIF_LISTEN_(@"MODEL_ITEMS_PLAYER_INSTANCES_AVAILABLE",self,@selector(refreshViews),nil);
    }
    return self;
}

- (void) loadView
{
  [super loadView];
  self.view.backgroundColor = [UIColor whiteColor];
  self.view.autoresizesSubviews = NO;

  int playerImageWidth = 200;
  CGRect playerImageFrame = CGRectMake((self.view.bounds.size.width / 2) - (playerImageWidth / 2), 64, playerImageWidth, 200);
  pcImage = [[ARISMediaView alloc] initWithFrame:playerImageFrame delegate:self];
  [pcImage setDisplayMode:ARISMediaDisplayModeAspectFit];

  if(_MODEL_PLAYER_.media_id != 0)
    [pcImage setMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id]];
  else [pcImage setImage:[UIImage imageNamed:@"profile.png"]];

  [self.view addSubview:pcImage];

  nameLabel = [[UILabel alloc] init];
  nameLabel.frame = CGRectMake(-1, pcImage.frame.origin.y + pcImage.frame.size.height + 20, self.view.bounds.size.width + 1, 30);

  nameLabel.text = _MODEL_PLAYER_.user_name;
  nameLabel.textAlignment = NSTextAlignmentCenter;
  nameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
  nameLabel.layer.borderWidth = 1.0f;
  [self.view addSubview:nameLabel];

  attributesTable = [[UITableView alloc] initWithFrame:CGRectMake(0,nameLabel.frame.origin.y + nameLabel.frame.size.height,self.view.bounds.size.width,self.view.bounds.size.height)];
  attributesTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
  attributesTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  attributesTable.delegate = self;
  attributesTable.dataSource = self;
  attributesTable.backgroundColor = [UIColor clearColor];
  attributesTable.opaque = NO;
  attributesTable.backgroundView = nil;
  [self.view addSubview:attributesTable];

  [self refreshViews];
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
    [self refreshViews];
}

- (void) refreshViews
{
  if(!self.view) return;

  NSArray *playerInstances = _ARIS_ARRAY_SORTED_ON_(_MODEL_ITEMS_.attributes,@"name");
  [instances removeAllObjects];

  Instance *tmp_inst;
  for(int i = 0; i < playerInstances.count; i++)
  {
    tmp_inst = playerInstances[i];
    if(tmp_inst.qty == 0) continue;
    [instances addObject:tmp_inst];
  }
  [attributesTable reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return instances.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  if(cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

  cell.backgroundColor = [UIColor clearColor];
  cell.opaque = NO;

  cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
  cell.backgroundView.backgroundColor = [UIColor clearColor];
  cell.backgroundView.opaque = NO;

  cell.contentView.backgroundColor = [UIColor ARISColorTranslucentWhite];
  cell.contentView.opaque = NO;

  cell.userInteractionEnabled = NO;

  Instance *instance = instances[indexPath.row];
  Item *attrib = (Item *)instance.object;

  UILabel *lblTemp;
  lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 20)];
  lblTemp.backgroundColor = [UIColor clearColor];
  lblTemp.font = [UIFont boldSystemFontOfSize:18.0];
  lblTemp.text = attrib.name;
  [cell.contentView addSubview:lblTemp];

  lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, 39, 240, 20)];
  lblTemp.backgroundColor = [UIColor clearColor];
  lblTemp.font = [UIFont systemFontOfSize:11];
  lblTemp.textColor = [UIColor ARISColorDarkGray];
  lblTemp.text = attrib.desc;
  [cell.contentView addSubview:lblTemp];

  ARISMediaView *iconViewTemp;
  if(attrib.icon_media_id != 0)
  {
    if(iconCache.count <= indexPath.row)
      [iconCache addObject:[_MODEL_MEDIA_ mediaForId:attrib.icon_media_id]];
    iconViewTemp = [[ARISMediaView alloc] initWithFrame:CGRectMake(5, 5, 50, 50) delegate:self];
    [iconViewTemp setDisplayMode:ARISMediaDisplayModeAspectFit];
    [iconViewTemp setMedia:[iconCache objectAtIndex:indexPath.row]];
  }
  [cell.contentView addSubview:iconViewTemp];

  lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 20)];
  lblTemp.font = [UIFont boldSystemFontOfSize:11];
  lblTemp.textColor = [UIColor ARISColorDarkGray];
  lblTemp.backgroundColor = [UIColor clearColor];
  lblTemp.textAlignment = NSTextAlignmentRight;
  if(instance.qty > 1 || attrib.max_qty_in_inventory > 1)
    lblTemp.text = [NSString stringWithFormat:@"%d",instance.qty];
  else
    lblTemp.text = nil;
  [cell.contentView addSubview:lblTemp];

  return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 60;
}

- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"PLAYER"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; return @"Attributes"; }
- (UIImage *) tabIcon { return [UIImage imageNamed:@"id_card"]; }

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

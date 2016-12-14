//
//  InventoryViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/30/13.
//
//

#import "InventoryViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "ARISMediaView.h"
#import "Media.h"
#import "Item.h"
#import <Google/Analytics.h>

@interface InventoryViewController ()<ARISMediaViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
  Tab *tab;
  
  UITableView *inventoryTable;
  //parallel arrays
  NSMutableArray *instances;
  
  UIProgressView *capBar;
  UILabel *capLabel;
  
  NSMutableDictionary *iconCache;
  NSMutableDictionary *viewedList;
  
  id<InventoryViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation InventoryViewController

- (id) initWithTab:(Tab *)t delegate:(id<InventoryViewControllerDelegate>)d
{
  if(self = [super init])
  {
    tab = t;
    delegate = d;
    
    self.title = self.tabTitle;
    
    instances = [[NSMutableArray alloc] init];
    
    iconCache  = [[NSMutableDictionary alloc] initWithCapacity:10];
    viewedList = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    _ARIS_NOTIF_LISTEN_(@"MODEL_PLAYER_INSTANCES_AVAILABLE",self,@selector(refreshViews),nil);
  }
  return self;
}

- (void) loadView
{
  [super loadView];
  self.view.autoresizesSubviews = NO;
  
  inventoryTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  inventoryTable.frame = self.view.bounds;
  inventoryTable.dataSource = self;
  inventoryTable.delegate = self;
  [self.view addSubview:inventoryTable];
  
  if(_MODEL_GAME_.inventory_weight_cap > 0)
  {
    capBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    capBar.progress = 0;
    
    capLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    capLabel.text = [NSString stringWithFormat:@"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""), 0, 0];
  }
  
  inventoryTable.contentInset = UIEdgeInsetsMake(64,0,0,0);
  inventoryTable.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
  
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
  
  if(capBar)
  {
    long currentWeight = _MODEL_PLAYER_INSTANCES_.currentWeight;
    long weightCap     = _MODEL_GAME_.inventory_weight_cap;
    capBar.progress = (float)((float)currentWeight/(float)weightCap);
    capLabel.text = [NSString stringWithFormat:@"%@: %ld/%ld", NSLocalizedString(@"WeightCapacityKey", @""),currentWeight, weightCap];
  }
  
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName value:self.title];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self refreshViews]; //For un-bolding items
  [self refetch];
}

- (void) refreshViews
{
  if(!self.view) return;
  
  NSArray *playerInstances = _ARIS_ARRAY_SORTED_ON_(_MODEL_PLAYER_INSTANCES_.inventory,@"name");
  [instances removeAllObjects];
  
  Instance *tmp_inst;
  for(long i = 0; i < playerInstances.count; i++)
  {
    tmp_inst = playerInstances[i];
    if(tmp_inst.qty == 0) continue;
    [instances addObject:tmp_inst];
  }
  
  [inventoryTable reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return instances.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(_MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return 120;
  else
    return 60;
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier
{
  CGRect cellFrame   = CGRectMake(  0,  0, 310, 60);
  CGRect iconFrame   = CGRectMake(  5,  5,  50, 50);
  CGRect label1Frame = CGRectMake( 70, 12, 180, 20); //Title
  CGRect label2Frame = CGRectMake( 70, 29, 240, 20); //Desc
  CGRect label3Frame = CGRectMake(260, 12,  50, 20); //Qty
  UILabel *lblTemp;
  ARISMediaView *iconViewTemp;
  
  if(_MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
  {
    cellFrame   = CGRectMake(cellFrame.origin.x*2.,cellFrame.origin.y*2.,cellFrame.size.width*2.,cellFrame.size.height*2.);
    iconFrame   = CGRectMake(iconFrame.origin.x*2.,iconFrame.origin.y*2.,iconFrame.size.width*2.,iconFrame.size.height*2.);
    label1Frame = CGRectMake(label1Frame.origin.x*2.,label1Frame.origin.y*2.,label1Frame.size.width*2.,label1Frame.size.height*2.);
    label2Frame = CGRectMake(label2Frame.origin.x*2.,label2Frame.origin.y*2.,label2Frame.size.width*2.,label2Frame.size.height*2.);
    label3Frame = CGRectMake(label3Frame.origin.x*2.,label3Frame.origin.y*2.,label3Frame.size.width*2.,label3Frame.size.height*2.);
  }
  
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  cell.frame = cellFrame;
  
  //Initialize Label with tag 1.
  lblTemp = [[UILabel alloc] initWithFrame:label1Frame];
  lblTemp.tag = 1;
  lblTemp.font = [ARISTemplate ARISCellTitleFont];
  lblTemp.backgroundColor = [UIColor clearColor];
  [cell.contentView addSubview:lblTemp];
  
  //Initialize Label with tag 2.
  lblTemp = [[UILabel alloc] initWithFrame:label2Frame];
  lblTemp.tag = 2;
  lblTemp.font = [ARISTemplate ARISCellSubtextFont];
  lblTemp.textColor = [UIColor darkGrayColor];
  lblTemp.backgroundColor = [UIColor clearColor];
  [cell.contentView addSubview:lblTemp];
  
  //Init Icon with tag 3
  iconViewTemp = [[ARISMediaView alloc] initWithFrame:iconFrame];
  [iconViewTemp setDisplayMode:ARISMediaDisplayModeAspectFit];
  iconViewTemp.tag = 3;
  iconViewTemp.backgroundColor = [UIColor clearColor];
  [cell.contentView addSubview:iconViewTemp];
  
  //Init Icon with tag 4
  lblTemp = [[UILabel alloc] initWithFrame:label3Frame];
  lblTemp.tag = 4;
  lblTemp.font = [ARISTemplate ARISCellSubtextFont];
  lblTemp.numberOfLines = 2;
  lblTemp.textColor = [UIColor darkGrayColor];
  lblTemp.backgroundColor = [UIColor clearColor];
  
  [cell.contentView addSubview:lblTemp];
  
  return cell;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  if(cell == nil) cell = [self getCellContentView:@"cell"];
  
  cell.contentView.backgroundColor = [UIColor ARISColorWhite];
  
  long i = indexPath.row;
  Instance *instance = instances[i];
  Item *item = (Item *)instance.object;
  
  ((UILabel *)[cell viewWithTag:1]).text = item.name;
  ((UILabel *)[cell viewWithTag:2]).text = [self stringByStrippingHTML:item.desc];
  ((UILabel *)[cell viewWithTag:4]).text = [self getQtyLabelStringForQty:instance.qty maxQty:item.max_qty_in_inventory weight:item.weight];
  
  NSNumber *viewed;
  if(!(viewed = viewedList[[NSNumber numberWithLong:item.item_id]]) || [viewed isEqualToNumber:[NSNumber numberWithLong:0]])
    [viewedList setObject:[NSNumber numberWithLong:0] forKey:[NSNumber numberWithLong:item.item_id]];
  else
    [viewedList setObject:[NSNumber numberWithLong:1] forKey:[NSNumber numberWithLong:item.item_id]];
  
  ARISMediaView *iconView = (ARISMediaView *)[cell viewWithTag:3];
  Media *iconMedia;
  if(!(iconMedia = [iconCache objectForKey:[NSNumber numberWithLong:item.item_id]]))
  {
    if (item.icon_media_id != 0) iconMedia = [_MODEL_MEDIA_ mediaForId:item.icon_media_id];
    else if(item.media_id != 0) iconMedia = [_MODEL_MEDIA_ mediaForId:item.media_id];
  }
  if(iconMedia && [iconMedia.type isEqualToString:@"IMAGE"])
  {
    [iconCache setObject:iconMedia forKey:[NSNumber numberWithLong:item.item_id]];
    [iconView setMedia:iconMedia];
  }
  else if(iconMedia)
  {
    if([iconMedia.type isEqualToString:@"AUDIO"]) [iconView setImage:[UIImage imageNamed:@"defaultAudioIcon.png"]];
    if([iconMedia.type isEqualToString:@"VIDEO"]) [iconView setImage:[UIImage imageNamed:@"defaultVideoIcon.png"]];
  }
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  long i = indexPath.row;
  Instance *instance = instances[i];
  Item *item = (Item *)instance.object;

  [_MODEL_DISPLAY_QUEUE_ enqueueInstance:instance];
  [viewedList setObject:[NSNumber numberWithLong:1] forKey:[NSNumber numberWithLong:item.item_id]];
}

//Removes all content after first <br> or </br> or <br /> tags, then removes all html
- (NSString *) stringByStrippingHTML:(NSString *)stringToStrip
{
  //PHIL- probably could convert this into a pretty simple regex. but it works for now...
  NSRange range;
  range = [stringToStrip rangeOfString:@"<br>"];   if(range.length != 0) stringToStrip = [stringToStrip substringToIndex:range.location];
  range = [stringToStrip rangeOfString:@"</br>"];  if(range.length != 0) stringToStrip = [stringToStrip substringToIndex:range.location];
  range = [stringToStrip rangeOfString:@"<br/>"];  if(range.length != 0) stringToStrip = [stringToStrip substringToIndex:range.location];
  range = [stringToStrip rangeOfString:@"<br />"]; if(range.length != 0) stringToStrip = [stringToStrip substringToIndex:range.location];

  while((range = [stringToStrip rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    stringToStrip = [stringToStrip stringByReplacingCharactersInRange:range withString:@""];
  return stringToStrip;
}

- (NSString *) getQtyLabelStringForQty:(long)qty maxQty:(long)maxQty weight:(long)weight
{
  NSString *qtyString = @"";
  NSString *weightString = @"";
  if(qty > 1 || maxQty != 1) qtyString    = [NSString stringWithFormat:@"x%ld",  qty];
  if(weight > 1)             weightString = [NSString stringWithFormat:@"\n%@ %ld",NSLocalizedString(@"WeightKey", @""), weight];
  return [NSString stringWithFormat:@"%@%@", qtyString, weightString];
}

- (void) refetch
{
}

- (void) tagTapped:(UITapGestureRecognizer *)r
{
  [self refreshViews];
}

- (void) showNav
{
  [delegate gamePlayTabBarViewControllerRequestsNav];
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"INVENTORY"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; return @"Inventory"; }
- (ARISMediaView *) tabIcon
{
  ARISMediaView *amv = [[ARISMediaView alloc] init];
  if(tab.icon_media_id) [amv setMedia:[_MODEL_MEDIA_ mediaForId:tab.icon_media_id]];
  else                  [amv setImage:[UIImage imageNamed:@"toolbox"]];
  return amv;
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

//
//  InventoryTagViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/30/13.
//
//

#import "InventoryTagViewController.h"
#import "StateControllerProtocol.h"
#import "InventoryTradeViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "AppModel.h"
#import "ARISMediaView.h"
#import "Media.h"
#import "Item.h"
#import "UIColor+ARISColors.h"

@interface InventoryTagViewController ()<ARISMediaViewDelegate, InventoryTradeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIView *tagView;
    NSMutableArray *sortableTags;
    
    UITableView *inventoryTable;
    NSArray *inventory;
    
    UIButton *tradeButton;
    UIProgressView *capBar;
    UILabel *capLabel;
    
    NSMutableDictionary *iconCache;
    NSMutableDictionary *viewedList;
    
    id<GamePlayTabBarViewControllerDelegate, InventoryTradeViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@property (nonatomic, strong) UIView *tagView;
@property (nonatomic, strong) NSMutableArray *sortableTags;

@property (nonatomic, strong) UITableView *inventoryTable;
@property (nonatomic, strong) NSArray *inventory;

@property (nonatomic, strong) UIButton *tradeButton;
@property (nonatomic, strong) UIProgressView *capBar;
@property (nonatomic, strong) UILabel *capLabel;

@property (nonatomic, strong) NSMutableDictionary *iconCache;
@property (nonatomic, strong) NSMutableDictionary *viewedList;

@end

@implementation InventoryTagViewController

@synthesize tagView;
@synthesize sortableTags;
@synthesize inventoryTable;
@synthesize inventory;
@synthesize tradeButton;
@synthesize capBar;
@synthesize capLabel;
@synthesize iconCache;
@synthesize viewedList;

- (id) initWithDelegate:(id<GamePlayTabBarViewControllerDelegate, InventoryTradeViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"INVENTORY";
        delegate = d;
        
        self.title = NSLocalizedString(@"InventoryViewTitleKey",@"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"toolboxTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"toolboxTabBarSelected"]];
        
        self.sortableTags = [[NSMutableArray alloc] initWithCapacity:10];
        self.iconCache  = [[NSMutableDictionary alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
        self.viewedList = [[NSMutableDictionary alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable)   name:@"NewlyAcquiredItemsAvailable"           object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable)   name:@"NewlyLostItemsAvailable"               object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge) name:@"NewlyChangedItemsGameNotificationSent" object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    self.tagView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,0)];
    [self.view addSubview:self.tagView];
    
    self.inventoryTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.inventoryTable.frame = self.view.bounds;
    self.inventoryTable.delegate = self;
    
    if([AppModel sharedAppModel].currentGame.allowTrading)
    {
        self.tradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.tradeButton.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
        [self.tradeButton setTitle:NSLocalizedString(@"InventoryTradeViewTitleKey", @"") forState:UIControlStateNormal];
        [self.tradeButton addTarget:self action:@selector(tradeButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if([AppModel sharedAppModel].currentGame.inventoryModel.weightCap > 0)
    {
        self.capBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        self.capBar.progress = 0;
        
        self.capLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        self.capLabel.text = [NSString stringWithFormat:@"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""), 0, 0];
    }
    
    [self sizeViewsWithoutTagView];
    [self.view addSubview:self.tagView];
    [self.view addSubview:self.inventoryTable];
    [self.view addSubview:self.tradeButton];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.capBar)
    {
        int currentWeight = [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight;
        int weightCap     = [AppModel sharedAppModel].currentGame.inventoryModel.weightCap;
        self.capBar.progress = (float)((float)currentWeight/(float)weightCap);
        self.capLabel.text = [NSString stringWithFormat:@"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""),currentWeight, weightCap];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppServices sharedAppServices] updateServerInventoryViewed];
    [self refreshTable]; //For un-bolding items
    [self refetch];
}

- (void) sizeViewsForTagView
{
    self.tagView.frame = CGRectMake(0,0,self.view.bounds.size.width,100);
    if([AppModel sharedAppModel].currentGame.allowTrading)
        self.inventoryTable.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-100-44);
    else
        self.inventoryTable.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-100);
}
    
- (void) sizeViewsWithoutTagView
{
    self.tagView.frame = CGRectMake(0,0,self.view.bounds.size.width,0);
    if([AppModel sharedAppModel].currentGame.allowTrading)
        self.inventoryTable.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-44);
    else
        self.inventoryTable.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
}

- (void) tradeDidComplete
{
    [self refetch];
}

- (void) tradeCancelled
{
    [self refetch];
}

- (void) refetch
{
    [[AppServices sharedAppServices] fetchPlayerInventory];
}

- (void) refreshTable
{
    NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES], nil];
    self.inventory = [[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory sortedArrayUsingDescriptors:sortDescriptors];
    [self.sortableTags removeAllObjects];
    [inventoryTable reloadData];
}

- (void) tradeButtonTouched
{
    InventoryTradeViewController *tradeVC = [[InventoryTradeViewController alloc] initWithDelegate:self];
    tradeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tradeVC animated:YES];
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

- (NSString *) getQtyLabelStringForQty:(int)qty maxQty:(int)maxQty weight:(int)weight
{
    NSString *qtyString = @"";
    NSString *weightString = @"";
    if(qty > 1 || maxQty != 1) qtyString    = [NSString stringWithFormat:@"x%d",  qty];
    if(weight > 1)             weightString = [NSString stringWithFormat:@"\n%@ %d",NSLocalizedString(@"WeightKey", @""), weight];
    return [NSString stringWithFormat:@"%@%@", qtyString, weightString];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.inventory count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.frame = cellFrame;
    
    //Initialize Label with tag 1.
    lblTemp = [[UILabel alloc] initWithFrame:label1Frame];
    lblTemp.tag = 1;
    lblTemp.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    lblTemp.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:lblTemp];
    
    //Initialize Label with tag 2.
    lblTemp = [[UILabel alloc] initWithFrame:label2Frame];
    lblTemp.tag = 2;
    lblTemp.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
    lblTemp.textColor = [UIColor darkGrayColor];
    lblTemp.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:lblTemp];
    
    //Init Icon with tag 3
    iconViewTemp = [[ARISMediaView alloc] initWithFrame:iconFrame];
    iconViewTemp.tag = 3;
    iconViewTemp.backgroundColor = [UIColor clearColor]; 
    [cell.contentView addSubview:iconViewTemp];
    
    //Init Icon with tag 4
    lblTemp = [[UILabel alloc] initWithFrame:label3Frame];
    lblTemp.tag = 4;
    lblTemp.numberOfLines = 2;
    lblTemp.textColor = [UIColor darkGrayColor];
    lblTemp.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:lblTemp];
    
    return cell;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) cell = [self getCellContentView:CellIdentifier];
    
    if(indexPath.row % 2 == 0) cell.contentView.backgroundColor = [UIColor ARISColorWhite];
    else                       cell.contentView.backgroundColor = [UIColor ARISColorOffWhite];
    
    Item *item = [self.inventory objectAtIndex:[indexPath row]];
    
    ((UILabel *)[cell viewWithTag:1]).text = item.name;
    ((UILabel *)[cell viewWithTag:2]).text = [self stringByStrippingHTML:item.idescription];
    ((UILabel *)[cell viewWithTag:4]).text = [self getQtyLabelStringForQty:item.qty maxQty:item.maxQty weight:item.weight];
    
    NSNumber *viewed;
    if(!(viewed = [self.viewedList objectForKey:[NSNumber numberWithInt:item.itemId]]) || [viewed isEqualToNumber:[NSNumber numberWithInt:0]])
        [self.viewedList setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:item.itemId]];
    else
        [self.viewedList setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:item.itemId]];
    
    ARISMediaView *iconView = (ARISMediaView *)[cell viewWithTag:3];
    Media *iconMedia;
    if(!(iconMedia = [self.iconCache objectForKey:[NSNumber numberWithInt:item.itemId]]))
    {
        if (item.iconMediaId != 0) iconMedia = [[AppModel sharedAppModel] mediaForMediaId:item.iconMediaId ofType:@"PHOTO"];
        else if(item.mediaId != 0) iconMedia = [[AppModel sharedAppModel] mediaForMediaId:item.mediaId     ofType:@"PHOTO"];
    }
    if(iconMedia && [iconMedia.type isEqualToString:@"PHOTO"])
    {
        [self.iconCache setObject:iconMedia forKey:[NSNumber numberWithInt:item.itemId]];
        [iconView refreshWithFrame:iconView.frame media:iconMedia mode:ARISMediaDisplayModeAspectFit delegate:self];
    }
    else if(iconMedia)
    {
        if([iconMedia.type isEqualToString:@"AUDIO"]) [iconView refreshWithFrame:iconView.frame image:[UIImage imageNamed:@"defaultAudioIcon.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
        if([iconMedia.type isEqualToString:@"VIDEO"]) [iconView refreshWithFrame:iconView.frame image:[UIImage imageNamed:@"defaultVideoIcon.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"swish" shouldVibrate:NO];
    [delegate displayGameObject:[self.inventory objectAtIndex:[indexPath row]] fromSource:self];
    
    [self.viewedList setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:((Item *)[self.inventory objectAtIndex:[indexPath row]]).itemId]];
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  InventoryTagViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/30/13.
//
//

#import "InventoryTagViewController.h"
#import "StateControllerProtocol.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "ARISMediaView.h"
#import "Media.h"
#import "Item.h"
#import "ARISTemplate.h"

@interface InventoryTagViewController ()<ARISMediaViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIScrollView *tagView;
    NSMutableArray *sortableTags;
    int currentTagIndex;
    
    UITableView *inventoryTable;
    NSArray *inventory;
    
    UIProgressView *capBar;
    UILabel *capLabel;
    
    NSMutableDictionary *iconCache;
    NSMutableDictionary *viewedList;
    
    id<GamePlayTabBarViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) UIScrollView *tagView;
@property (nonatomic, strong) NSMutableArray *sortableTags;
@property (nonatomic, assign) int currentTagIndex;
@property (nonatomic, strong) UITableView *inventoryTable;
@property (nonatomic, strong) NSArray *inventory;
@property (nonatomic, strong) UIProgressView *capBar;
@property (nonatomic, strong) UILabel *capLabel;
@property (nonatomic, strong) NSMutableDictionary *iconCache;
@property (nonatomic, strong) NSMutableDictionary *viewedList;

@end

@implementation InventoryTagViewController

@synthesize tagView;
@synthesize sortableTags;
@synthesize currentTagIndex;
@synthesize inventoryTable;
@synthesize inventory;
@synthesize capBar;
@synthesize capLabel;
@synthesize iconCache;
@synthesize viewedList;

- (id) initWithDelegate:(id<GamePlayTabBarViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"INVENTORY";
        self.tabIconName = @"toolbox";
        delegate = d;
        
        self.title = NSLocalizedString(@"InventoryViewTitleKey",@"");
        
        self.sortableTags = [[NSMutableArray alloc] initWithCapacity:10];
        self.iconCache  = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.viewedList = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.currentTagIndex = 0;
        
  _ARIS_NOTIF_LISTEN_(@"NewlyAcquiredItemsAvailable",self,@selector(refreshViews),nil);
  _ARIS_NOTIF_LISTEN_(@"NewlyLostItemsAvailable",self,@selector(refreshViews),nil);
  _ARIS_NOTIF_LISTEN_(@"NewlyChangedItemsGameNotificationSent",self,@selector(incrementBadge),nil);
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.autoresizesSubviews = NO;
    
    self.tagView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,64,self.view.bounds.size.width,100)];
    self.tagView.backgroundColor = [UIColor ARISColorDarkGray];
    self.tagView.scrollEnabled = YES;
    self.tagView.bounces = YES;
    [self.view addSubview:self.tagView];
    
    self.inventoryTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.inventoryTable.frame = self.view.bounds;
    self.inventoryTable.dataSource = self;
    self.inventoryTable.delegate = self;
    [self.view addSubview:self.inventoryTable];
    
    if(_MODEL_ITEMS_.weightCap > 0)
    {
        self.capBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        self.capBar.progress = 0;
        
        self.capLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        self.capLabel.text = [NSString stringWithFormat:@"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""), 0, 0];
    }
    
    [self sizeViewsWithoutTagView];
    
    [self refreshViews];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.capBar)
    {
        int currentWeight = _MODEL_ITEMS_.currentWeight;
        int weightCap     = _MODEL_ITEMS_.weightCap;
        self.capBar.progress = (float)((float)currentWeight/(float)weightCap);
        self.capLabel.text = [NSString stringWithFormat:@"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""),currentWeight, weightCap];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppServices sharedAppServices] updateServerInventoryViewed];
    [self refreshViews]; //For un-bolding items
    [self refetch];
}

- (void) sizeViewsForTagView
{
    self.tagView.frame = CGRectMake(0,64,self.view.bounds.size.width,100);
    self.inventoryTable.contentInset = UIEdgeInsetsMake(0,0,0,0);
    self.inventoryTable.frame = CGRectMake(0,100+64,self.view.bounds.size.width,self.view.bounds.size.height-100-44);
    
}
    
- (void) sizeViewsWithoutTagView
{
    self.tagView.frame = CGRectMake(0,0,self.view.bounds.size.width,0);
    self.inventoryTable.contentInset = UIEdgeInsetsMake(64,0,0,0);
    self.inventoryTable.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    
    self.currentTagIndex = 0;
}

- (void) refreshViews
{
    /*
    if(!self.view) return;
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES], nil];
    self.inventory = [_MODEL_GAME_.inventoryModel.currentInventory sortedArrayUsingDescriptors:sortDescriptors];
    [self.sortableTags removeAllObjects];
    
    //populate sortableTags with all available tags (obnoxiously complex...)
    BOOL match;
    for(int i = 0; i < self.inventory.count; i++)
    {
        for(int j = 0; j < ((Item *)[self.inventory objectAtIndex:i]).tags.count; j++)
        {
            match = NO;
            for(int k = 0; k < self.sortableTags.count; k++)
            {
                if([((ItemTag *)[((Item *)[self.inventory objectAtIndex:i]).tags objectAtIndex:j]).name isEqualToString:((ItemTag *)[self.sortableTags objectAtIndex:k]).name])
                    match = YES;
            }
            if(!match) [self.sortableTags addObject:[((Item *)[self.inventory objectAtIndex:i]).tags objectAtIndex:j]];
        }
        if(((Item *)[self.inventory objectAtIndex:i]).tags.count == 0)
        {
            match = NO;
            for(int k = 0; k < self.sortableTags.count; k++)
            {
                if([@"untagged" isEqualToString:((ItemTag *)[self.sortableTags objectAtIndex:k]).name])
                    match = YES;
            }
            if(!match) { ItemTag *t = [[ItemTag alloc] init]; t.name = @"untagged"; t.media_id = 0; [self.sortableTags insertObject:t atIndex:0]; }
        }
    }
        
    if(self.sortableTags.count > 1) [self sizeViewsForTagView];
    else                              [self sizeViewsWithoutTagView];
    
    
    [self loadTagViewData];
    [inventoryTable reloadData];
    
    //Apple is for some reason competing over the control of this view. Without this constantly being called, it messes everything up.
    self.tagView.contentSize = CGSizeMake(self.sortableTags.count*100,0);
    self.tagView.contentOffset = CGPointMake(0,0);    
     */
}

- (void) loadTagViewData
{
    /*
    while(self.tagView.subviews.count > 0)
        [[self.tagView.subviews objectAtIndex:0] removeFromSuperview];
    
    UIView *tag;
    UILabel *label;
    for(int i = 0; i < self.sortableTags.count; i++)
    {
        tag = [[UIView alloc] initWithFrame:CGRectMake(i*100+10,10,80,80)];
        tag.backgroundColor = [UIColor ARISColorLightGray];
        tag.tag = i;
        [tag addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagTapped:)]];
        label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        label.textColor = [UIColor ARISColorWhite];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.opaque = NO;
        label.text = ((ItemTag *)[self.sortableTags objectAtIndex:i]).name;
        if(((ItemTag *)[self.sortableTags objectAtIndex:i]).media_id != 0)
        {
            tag.backgroundColor = [UIColor clearColor]; 
            ARISMediaView *amv = [[ARISMediaView alloc] initWithFrame:CGRectMake(0, 0, 80, 80) delegate:self];
            [amv setDisplayMode:ARISMediaDisplayModeAspectFit]; 
            [amv setMedia:[_MODEL_MEDIA_ mediaForId:((ItemTag *)[self.sortableTags objectAtIndex:i]).media_id]];
            [tag addSubview:amv];
        }
        [tag addSubview:label];
        [self.tagView addSubview:tag];
    }
    self.tagView.contentSize = CGSizeMake(self.sortableTags.count*100,0);// self.tagView.frame.size.height);
     */
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
    int rows = 0;
    for(int i = 0; i < self.inventory.count; i++)
    {
        for(int j = 0; j < ((Item *)[self.inventory objectAtIndex:i]).tags.count; j++)
        {
            if([((ItemTag *)[((Item *)[self.inventory objectAtIndex:i]).tags objectAtIndex:j]).name isEqualToString:((ItemTag *)[self.sortableTags objectAtIndex:self.currentTagIndex]).name])
                rows++;
        }
        if(self.currentTagIndex == 0 && ((Item *)[self.inventory objectAtIndex:i]).tags.count == 0)
            rows++; //untagged selected, has no tags
    }
    return rows;
     */
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
    /*
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) cell = [self getCellContentView:CellIdentifier];
    
    cell.contentView.backgroundColor = [UIColor ARISColorWhite];
    
    Item *item;
    int tagItemIndex = -1;//-1 so first item found will be index 0  //also, yes, this is dumb and n^2, and could be n if I just saved state. chill.
    for(int i = 0; i < self.inventory.count; i++)
    {
        for(int j = 0; j < ((Item *)[self.inventory objectAtIndex:i]).tags.count; j++)
        {
            if([((ItemTag *)[((Item *)[self.inventory objectAtIndex:i]).tags objectAtIndex:j]).name isEqualToString:((ItemTag *)[self.sortableTags objectAtIndex:self.currentTagIndex]).name])
                tagItemIndex++;
        }
        if(self.currentTagIndex == 0 && ((Item *)[self.inventory objectAtIndex:i]).tags.count == 0)
            tagItemIndex++; //untagged selected, and current item has no tags
        
        if(tagItemIndex == indexPath.row) { item = [self.inventory objectAtIndex:i]; break; }
    }
    
    ((UILabel *)[cell viewWithTag:1]).text = item.name;
    ((UILabel *)[cell viewWithTag:2]).text = [self stringByStrippingHTML:item.desc];
    ((UILabel *)[cell viewWithTag:4]).text = [self getQtyLabelStringForQty:item.qty maxQty:item.maxQty weight:item.weight];
    
    NSNumber *viewed;
    if(!(viewed = [self.viewedList objectForKey:[NSNumber numberWithInt:item.item_id]]) || [viewed isEqualToNumber:[NSNumber numberWithInt:0]])
        [self.viewedList setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:item.item_id]];
    else
        [self.viewedList setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:item.item_id]];
    
    ARISMediaView *iconView = (ARISMediaView *)[cell viewWithTag:3];
    Media *iconMedia;
    if(!(iconMedia = [self.iconCache objectForKey:[NSNumber numberWithInt:item.item_id]]))
    {
        if (item.icon_media_id != 0) iconMedia = [_MODEL_MEDIA_ mediaForId:item.icon_media_id];
        else if(item.media_id != 0) iconMedia = [_MODEL_MEDIA_ mediaForId:item.media_id];
    }
    if(iconMedia && [iconMedia.type isEqualToString:@"IMAGE"])
    {
        [self.iconCache setObject:iconMedia forKey:[NSNumber numberWithInt:item.item_id]];
        [iconView setMedia:iconMedia];
    }
    else if(iconMedia)
    {
        if([iconMedia.type isEqualToString:@"AUDIO"]) [iconView setImage:[UIImage imageNamed:@"defaultAudioIcon.png"]];
        if([iconMedia.type isEqualToString:@"VIDEO"]) [iconView setImage:[UIImage imageNamed:@"defaultVideoIcon.png"]];
    }
    
    return cell;
     */
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"swish" shouldVibrate:NO];
 
    Item *item;
    int tagItemIndex = -1;//-1 so first item found will be index 0  //also, yes, this is dumb and n^2, and could be n if I just saved state. chill.
    for(int i = 0; i < self.inventory.count; i++)
    {
        for(int j = 0; j < ((Item *)[self.inventory objectAtIndex:i]).tags.count; j++)
        {
            if([((ItemTag *)[((Item *)[self.inventory objectAtIndex:i]).tags objectAtIndex:j]).name isEqualToString:((ItemTag *)[self.sortableTags objectAtIndex:self.currentTagIndex]).name])
                tagItemIndex++;
        }
        if(self.currentTagIndex == 0 && ((Item *)[self.inventory objectAtIndex:i]).tags.count == 0)
            tagItemIndex++; //untagged selected, and current item has no tags
        
        if(tagItemIndex == indexPath.row) { item = [self.inventory objectAtIndex:i]; break; }
    }
    
    [delegate displayGameObject:item fromSource:self];
    
    [self.viewedList setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:((Item *)[self.inventory objectAtIndex:[indexPath row]]).item_id]];
     */
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

- (void) refetch
{
    [[AppServices sharedAppServices] fetchPlayerInventory];
}

- (void) tagTapped:(UITapGestureRecognizer *)r
{
    self.currentTagIndex = r.view.tag;
    [self refreshViews];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);              
}

@end

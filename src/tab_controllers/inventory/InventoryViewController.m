//
//  InventoryViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/30/13.
//
//

#import "InventoryViewController.h"
#import "StateControllerProtocol.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "ARISMediaView.h"
#import "Media.h"
#import "Item.h"

@interface InventoryViewController ()<ARISMediaViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIScrollView *tagsView;
    NSMutableArray *sortableTags;
    int currentTagIndex;
    
    UITableView *inventoryTable;
    //parallel arrays
    NSMutableArray *instances;
    NSMutableArray *items;
    NSMutableArray *tags;
    
    UIProgressView *capBar;
    UILabel *capLabel;
    
    NSMutableDictionary *iconCache;
    NSMutableDictionary *viewedList;
    
    id<GamePlayTabBarViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@end

@implementation InventoryViewController

- (id) initWithDelegate:(id<GamePlayTabBarViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"INVENTORY";
        self.tabIconName = @"toolbox";
        delegate = d;
        
        self.title = NSLocalizedString(@"InventoryViewTitleKey",@"");
        
        sortableTags = [[NSMutableArray alloc] init];
        [sortableTags addObject:[_MODEL_TAGS_ tagForId:0]]; //null tag always exists
        
        instances = [[NSMutableArray alloc] init];
        items = [[NSMutableArray alloc] init];
        tags = [[NSMutableArray alloc] init];
        
        iconCache  = [[NSMutableDictionary alloc] initWithCapacity:10];
        viewedList = [[NSMutableDictionary alloc] initWithCapacity:10];
        currentTagIndex = 0;
        
        _ARIS_NOTIF_LISTEN_(@"MODEL_ITEMS_PLAYER_INSTANCES_AVAILABLE",self,@selector(incrementBadge),nil);
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.autoresizesSubviews = NO;
    
    tagsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,64,self.view.bounds.size.width,100)];
    tagsView.backgroundColor = [UIColor ARISColorDarkGray];
    tagsView.scrollEnabled = YES;
    tagsView.bounces = YES;
    [self.view addSubview:tagsView];
    
    inventoryTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    inventoryTable.frame = self.view.bounds;
    inventoryTable.dataSource = self;
    inventoryTable.delegate = self;
    [self.view addSubview:inventoryTable];
    
    if(_MODEL_ITEMS_.weightCap > 0)
    {
        capBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        capBar.progress = 0;
        
        capLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        capLabel.text = [NSString stringWithFormat:@"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""), 0, 0];
    }
    
    [self sizeViewsWithoutTagView];
    
    [self refreshViews];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(capBar)
    {
        int currentWeight = _MODEL_ITEMS_.currentWeight;
        int weightCap     = _MODEL_ITEMS_.weightCap;
        capBar.progress = (float)((float)currentWeight/(float)weightCap);
        capLabel.text = [NSString stringWithFormat:@"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""),currentWeight, weightCap];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshViews]; //For un-bolding items
    [self refetch];
}

- (void) sizeViewsForTagView
{
    tagsView.frame = CGRectMake(0,64,self.view.bounds.size.width,100);
    inventoryTable.contentInset = UIEdgeInsetsMake(0,0,0,0);
    inventoryTable.frame = CGRectMake(0,100+64,self.view.bounds.size.width,self.view.bounds.size.height-100-44);
}
    
- (void) sizeViewsWithoutTagView
{
    tagsView.frame = CGRectMake(0,0,self.view.bounds.size.width,0);
    inventoryTable.contentInset = UIEdgeInsetsMake(64,0,0,0);
    inventoryTable.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    
    currentTagIndex = 0;
}

- (int) listIndexForTableIndex:(int)table_index
{
    NSArray *inst_tags;
    Tag *tag;
    Tag *sortedTag = sortableTags[currentTagIndex];
    
    int filteredCount = -1;
    for(int i = 0; i < instances.count; i++)
    {
        inst_tags = tags[i];
        for(int j = 0; j < inst_tags.count; j++)
        {
            tag = inst_tags[j];
            if([tag.tag isEqualToString:sortedTag.tag])
                filteredCount++;
        }
        if(currentTagIndex == 0 && inst_tags.count == 0)
            filteredCount++; //untagged selected, and current item has no tags
        
        if(filteredCount == table_index) return i;
    }
    return 0; //really shouldn't get here
}

- (void) refreshViews
{
    if(!self.view) return;
    
    NSArray *playerInstances = _ARIS_ARRAY_SORTED_ON_(_MODEL_INSTANCES_.playerInstances,@"name");
    [instances removeAllObjects];
    [items removeAllObjects];
    [tags removeAllObjects];
    
    Instance *tmp_inst;
    for(int i = 0; i < playerInstances.count; i++)
    {
        tmp_inst = playerInstances[i];
        if(![tmp_inst.object_type isEqualToString:@"ITEM"] || tmp_inst.qty == 0) continue;
        [instances addObject:tmp_inst];
        [items addObject:[_MODEL_ITEMS_ itemForId:tmp_inst.object_id]];
        [tags addObject:[_MODEL_TAGS_ tagsForObjectType:tmp_inst.object_type id:tmp_inst.object_id]];
    }
    
    NSArray *allTags = _ARIS_ARRAY_SORTED_ON_(_MODEL_TAGS_.tags,@"sort_index");
    [sortableTags removeAllObjects];
    [sortableTags addObject:[_MODEL_TAGS_ tagForId:0]]; //null tag always exists
    
    Tag* tmp_tag;
    for(int i = 0; i < allTags.count; i++)
    {
        tmp_tag = allTags[i];
        if(tmp_tag.visible) [sortableTags addObject:tmp_tag];
    }
    
    if(sortableTags.count > 1) [self sizeViewsForTagView];
    else                       [self sizeViewsWithoutTagView];
    
    [self refreshTagsView];
    [inventoryTable reloadData];
    
    //Apple is for some reason competing over the control of this view. Without this constantly being called, it messes everything up.
    tagsView.contentSize = CGSizeMake(sortableTags.count*100,0);
    tagsView.contentOffset = CGPointMake(0,0);    
}

- (void) refreshTagsView
{
    while(tagsView.subviews.count > 0) [[tagsView.subviews objectAtIndex:0] removeFromSuperview];
    
    Tag *tag;
    UIView *tagv;
    UILabel *label;
    for(int i = 0; i < sortableTags.count; i++)
    {
        tag = sortableTags[i];
        tagv = [[UIView alloc] initWithFrame:CGRectMake(i*100+10,10,80,80)];
        tagv.backgroundColor = [UIColor ARISColorLightGray];
        tagv.tag = i;
        [tagv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagTapped:)]];
        label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        label.textColor = [UIColor ARISColorWhite];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.opaque = NO;
        label.text = tag.tag;
        if(tag.media_id != 0)
        {
            tagv.backgroundColor = [UIColor clearColor]; 
            ARISMediaView *amv = [[ARISMediaView alloc] initWithFrame:CGRectMake(0, 0, 80, 80) delegate:self];
            [amv setDisplayMode:ARISMediaDisplayModeAspectFit]; 
            [amv setMedia:[_MODEL_MEDIA_ mediaForId:tag.media_id]];
            [tagv addSubview:amv];
        }
        [tagv addSubview:label];
        [tagsView addSubview:tagv];
    }
    tagsView.contentSize = CGSizeMake(sortableTags.count*100,0);// tagsView.frame.size.height);
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    NSArray *instTags;
    Tag *tag;
    Tag *sortedTag = sortableTags[currentTagIndex];
    for(int i = 0; i < instances.count; i++)
    {
        instTags = tags[i];
        for(int j = 0; j < instTags.count; j++)
        {
            tag = instTags[j];
            if([tag.tag isEqualToString:sortedTag.tag])
                rows++;
        }
        if(currentTagIndex == 0 && instTags.count == 0)
            rows++; //untagged selected, and item has no tags
    }
    return rows;
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
    [iconViewTemp setDisplayMode:ARISMediaDisplayModeAspectFit];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil) cell = [self getCellContentView:@"cell"];
    
    cell.contentView.backgroundColor = [UIColor ARISColorWhite];
    
    int i = [self listIndexForTableIndex:indexPath.row];
    Instance *instance = instances[i];
    Item *item = items[i];
    
    ((UILabel *)[cell viewWithTag:1]).text = item.name;
    ((UILabel *)[cell viewWithTag:2]).text = [self stringByStrippingHTML:item.desc];
    ((UILabel *)[cell viewWithTag:4]).text = [self getQtyLabelStringForQty:instance.qty maxQty:item.max_qty_in_inventory weight:item.weight];
    
    NSNumber *viewed;
    if(!(viewed = viewedList[[NSNumber numberWithInt:item.item_id]]) || [viewed isEqualToNumber:[NSNumber numberWithInt:0]])
        [viewedList setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:item.item_id]];
    else
        [viewedList setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:item.item_id]];
    
    ARISMediaView *iconView = (ARISMediaView *)[cell viewWithTag:3];
    Media *iconMedia;
    if(!(iconMedia = [iconCache objectForKey:[NSNumber numberWithInt:item.item_id]]))
    {
        if (item.icon_media_id != 0) iconMedia = [_MODEL_MEDIA_ mediaForId:item.icon_media_id];
        else if(item.media_id != 0) iconMedia = [_MODEL_MEDIA_ mediaForId:item.media_id];
    }
    if(iconMedia && [iconMedia.type isEqualToString:@"IMAGE"])
    {
        [iconCache setObject:iconMedia forKey:[NSNumber numberWithInt:item.item_id]];
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
    
    int i = [self listIndexForTableIndex:indexPath.row];
    Item *item = items[i];
    Instance *instance = instances[i];
    
    [delegate displayInstance:instance];
    [viewedList setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:item.item_id]];
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
}

- (void) tagTapped:(UITapGestureRecognizer *)r
{
    currentTagIndex = r.view.tag;
    [self refreshViews];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);              
}

@end

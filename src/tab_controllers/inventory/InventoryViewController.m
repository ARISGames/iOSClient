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

@interface InventoryViewController ()<ARISMediaViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    Tab *tab;

    /* TAG TRASH
    UIScrollView *tagsView;
    NSMutableArray *sortableTags;
    long currentTagIndex;
     */

    UITableView *inventoryTable;
    //parallel arrays
    NSMutableArray *instances;
    /* TAG TRASH
    NSMutableArray *tags;
     */

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

        /* TAG TRASH
        sortableTags = [[NSMutableArray alloc] init];
        [sortableTags addObject:[_MODEL_TAGS_ tagForId:0]]; //null tag always exists
         */

        instances = [[NSMutableArray alloc] init];
        /* TAG TRASH
        tags = [[NSMutableArray alloc] init];
         */

        iconCache  = [[NSMutableDictionary alloc] initWithCapacity:10];
        viewedList = [[NSMutableDictionary alloc] initWithCapacity:10];
        /* TAG TRASH
        currentTagIndex = 0;
         */

        _ARIS_NOTIF_LISTEN_(@"MODEL_PLAYER_INSTANCES_AVAILABLE",self,@selector(refreshViews),nil);
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.autoresizesSubviews = NO;

    /* TAG TRASH
    tagsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,64,self.view.bounds.size.width,100)];
    tagsView.contentInset = UIEdgeInsetsMake(0,0,0,0);
    tagsView.backgroundColor = [UIColor ARISColorDarkGray];
    tagsView.scrollEnabled = YES;
    tagsView.bounces = YES;
    [self.view addSubview:tagsView];
     */

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

    [self sizeViewsWithoutTagView];

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
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshViews]; //For un-bolding items
    [self refetch];
}

/* TAG TRASH
- (void) sizeViewsForTagView
{
    tagsView.frame = CGRectMake(0,64,self.view.bounds.size.width,100);
    tagsView.contentInset = UIEdgeInsetsMake(0,0,0,0);
    inventoryTable.contentInset = UIEdgeInsetsMake(0,0,0,0);
    inventoryTable.frame = CGRectMake(0,100+64,self.view.bounds.size.width,self.view.bounds.size.height-100-44);
}
 */

- (void) sizeViewsWithoutTagView
{
    /* TAG TRASH
    tagsView.frame = CGRectMake(0,0,self.view.bounds.size.width,0);
    tagsView.contentInset = UIEdgeInsetsMake(0,0,0,0);
     */
    inventoryTable.contentInset = UIEdgeInsetsMake(64,0,0,0);
    inventoryTable.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);

    /* TAG TRASH
    currentTagIndex = 0;
     */
}

/*
- (long) listIndexForTableIndex:(long)table_index
{
    NSArray *inst_tags;
    Tag *tag;
    Tag *sortedTag = sortableTags[currentTagIndex];

    long filteredCount = -1;
    for(long i = 0; i < instances.count; i++)
    {
        inst_tags = tags[i];
        for(long j = 0; j < inst_tags.count; j++)
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
 */

- (void) refreshViews
{
    if(!self.view) return;

    NSArray *playerInstances = _ARIS_ARRAY_SORTED_ON_(_MODEL_PLAYER_INSTANCES_.inventory,@"name");
    [instances removeAllObjects];
    /* TAG TRASH
    [tags removeAllObjects];
     */

    Instance *tmp_inst;
    for(long i = 0; i < playerInstances.count; i++)
    {
        tmp_inst = playerInstances[i];
        if(tmp_inst.qty == 0) continue;
        [instances addObject:tmp_inst];
        /* TAG TRASH
        [tags addObject:[_MODEL_TAGS_ tagsForObjectType:tmp_inst.object_type id:tmp_inst.object_id]];
         */
    }

    /* TAG TRASH
    NSArray *allTags = _ARIS_ARRAY_SORTED_ON_(_MODEL_TAGS_.tags,@"sort_index");
    [sortableTags removeAllObjects];
    [sortableTags addObject:[_MODEL_TAGS_ tagForId:0]]; //null tag always exists

    // Only display tags if you have an item with that tag
    Tag* tmp_tag;
    NSArray *inst_tags;
    for(long i = 0; i < allTags.count; i++)
    {
        tmp_tag = allTags[i];
        if(tmp_tag.visible && tmp_tag.curated)
        {
            bool found = false;
            for(long i = 0; i < instances.count && !found; i++)
            {
                inst_tags = tags[i];
                for(long j = 0; j < inst_tags.count && !found; j++)
                {
                    if([((Tag *)inst_tags[j]).tag isEqualToString:tmp_tag.tag])
                    {
                        [sortableTags addObject:tmp_tag];
                        found = true;
                    }
                }
            }

        }
    }
     
    // Display all curated tags
    Tag* tmp_tag;
    for(long i = 0; i < allTags.count; i++)
    {
        tmp_tag = allTags[i];
        if(tmp_tag.visible && tmp_tag.curated)
            [sortableTags addObject:tmp_tag];
    }

    if(sortableTags.count > 1) [self sizeViewsForTagView];
    else                       [self sizeViewsWithoutTagView];

    [self refreshTagsView];
     */
    [inventoryTable reloadData];

    /* TAG TRASH
    //Apple is for some reason competing over the control of this view. Without this constantly being called, it messes everything up.
    tagsView.contentSize = CGSizeMake(sortableTags.count*100,tagsView.bounds.size.height);
     */
}

/* TAG TRASH
- (void) refreshTagsView
{
    while(tagsView.subviews.count > 0) [[tagsView.subviews objectAtIndex:0] removeFromSuperview];

    Tag *tag;
    UIView *tagv;
    UILabel *label;
    for(long i = 0; i < sortableTags.count; i++)
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
    tagsView.contentSize = CGSizeMake(sortableTags.count*100,tagsView.bounds.size.height);
}
 */

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /* TAG TRASH
    long rows = 0;
    NSArray *instTags;
    Tag *tag;
    Tag *sortedTag = sortableTags[currentTagIndex];
    for(long i = 0; i < instances.count; i++)
    {
        instTags = tags[i];
        for(long j = 0; j < instTags.count; j++)
        {
            tag = instTags[j];
            if([tag.tag isEqualToString:sortedTag.tag])
                rows++;
        }
        if(currentTagIndex == 0 && instTags.count == 0)
            rows++; //untagged selected, and item has no tags
    }
    return rows;
     */
  return instances.count;
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

    /* TAG TRASH
    long i = [self listIndexForTableIndex:indexPath.row];
     */
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

    /* TAG TRASH
    long i = [self listIndexForTableIndex:indexPath.row];
     */
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
    /* TAG TRASH
    currentTagIndex = r.view.tag;
     */
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
    if(tab.icon_media_id)
        [amv setMedia:[_MODEL_MEDIA_ mediaForId:tab.icon_media_id]];
    else
        [amv setImage:[UIImage imageNamed:@"toolbox"]];
    return amv;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

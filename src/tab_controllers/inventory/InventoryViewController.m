//
//  FilesViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "InventoryViewController.h"
#import "StateControllerProtocol.h"
#import "AppServices.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "AppModel.h"
#import "InventoryTradeViewController.h"

@interface InventoryViewController() <InventoryTradeViewControllerDelegate, GameObjectViewControllerDelegate>
{
    id<InventoryViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@end

@implementation InventoryViewController

@synthesize inventoryTable;
@synthesize inventory;
@synthesize tradeButton;
@synthesize capBar;
@synthesize capLabel;

@synthesize iconCache;
@synthesize mediaCache;

- (id)initWithDelegate:(id<InventoryViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithNibName:@"InventoryViewController" bundle:nil])
    {
        delegate = d;
        
        self.title = NSLocalizedString(@"InventoryViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"36-toolbox"];

        self.mediaCache = [[NSMutableDictionary alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
        self.iconCache  = [[NSMutableDictionary alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedInventory"           object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"              object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyAcquiredItemsAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyLostItemsAvailable"     object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge)         name:@"NewlyChangedItemsGameNotificationSent"    object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    if([AppModel sharedAppModel].currentGame.allowTrading)
    {
        self.tradeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"InventoryTradeViewTitleKey", @"") style:UIBarButtonItemStyleDone target:self action:@selector(tradeButtonTouched)];
        
        [self.navigationItem setRightBarButtonItem:self.tradeButton];
    }
    
    if([AppModel sharedAppModel].currentGame.inventoryModel.weightCap <= 0)
    {
        self.capBar.progress = 0;
        self.capBar.hidden = YES;
        self.capLabel.hidden = YES;
        self.inventoryTable.frame = CGRectMake(0, 0, 320, 367);
    }
    else
    {
        self.capBar.progress = 0;
        self.capLabel.text = [NSString stringWithFormat:@"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""), 0, 0];
        self.capBar.hidden = NO;
        self.capLabel.hidden = NO;
        self.inventoryTable.frame = CGRectMake(0, 42, 320, 325);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int currentWeight = [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight;
    int weightCap     = [AppModel sharedAppModel].currentGame.inventoryModel.weightCap;
    self.capBar.progress = (float)((float)currentWeight/(float)weightCap);
    self.capLabel.text = [NSString stringWithFormat:@"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""),currentWeight, weightCap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AppServices sharedAppServices] updateServerInventoryViewed];
	[self refresh];				
}

- (void) tradeDidComplete
{
    [self refresh];
}

- (void) tradeCancelled
{
    [self refresh];
}

-(void)tradeButtonTouched
{
    InventoryTradeViewController *tradeVC = [[InventoryTradeViewController alloc] initWithDelegate:self];
    tradeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tradeVC animated:YES];
}

-(void)dismissTutorial
{
    if(delegate) [delegate dismissTutorial];
}

-(void)refresh
{
	[[AppServices sharedAppServices] fetchPlayerInventory];
	[self showLoadingIndicator];
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
	[[self navigationItem] setRightBarButtonItem:self.tradeButton]; //self.tradeButton will be 'nil' if trading not allowed, so this should be safe
}

-(void)refreshViewFromModel
{
    NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES], nil];
    self.inventory = [[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory sortedArrayUsingDescriptors:sortDescriptors];
    [inventoryTable reloadData];
    
    if(![AppModel sharedAppModel].hasSeenInventoryTabTutorial)
    {
        [delegate showTutorialPopupPointingToTabForViewController:self title:NSLocalizedString(@"InventoryNewItemKey", @"") message:NSLocalizedString(@"InventoryNewItemMessageKey", @"")];
        
        [AppModel sharedAppModel].hasSeenInventoryTabTutorial = YES;
        [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
    }
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier
{
	CGRect cellFrame = CGRectMake(0, 0, 310, 60);
	CGRect iconFrame = CGRectMake(5, 5, 50, 50);
	CGRect label1Frame = CGRectMake(70, 12, 180, 20); //Title
	CGRect label2Frame = CGRectMake(70, 29, 240, 20); //Desc
    CGRect label3Frame = CGRectMake(260, 12, 50, 20); //Qty
	UILabel *lblTemp;
	UIImageView *iconViewTemp;
	
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.frame = cellFrame;
	
	//Initialize Label with tag 1.
	lblTemp = [[UILabel alloc] initWithFrame:label1Frame];
	lblTemp.tag = 1;
    lblTemp.font = [UIFont systemFontOfSize:18];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:label2Frame];
	lblTemp.tag = 2;
	lblTemp.font = [UIFont systemFontOfSize:11];
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Init Icon with tag 3
	iconViewTemp = [[AsyncMediaImageView alloc] initWithFrame:iconFrame];
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

#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [inventory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) cell = [self getCellContentView:CellIdentifier];
    
    if(indexPath.row % 2 == 0) cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    else                       cell.contentView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    
	Item *item = [inventory objectAtIndex: [indexPath row]];
	    
	((UILabel *)[cell viewWithTag:1]).text = item.name;
    ((UILabel *)[cell viewWithTag:2]).text = [self stringByStrippingHTML:item.text];
    ((UILabel *)[cell viewWithTag:4]).text = [self getQtyLabelStringForQty:item.qty maxQty:item.maxQty weight:item.weight];
    
    Media *media;
    if(item.mediaId != 0 && !(media = [self.mediaCache objectForKey:[NSNumber numberWithInt:item.itemId]]))
    {
        media = [[AppModel sharedAppModel] mediaForMediaId: item.mediaId];
        [self.mediaCache setObject:media forKey:[NSNumber numberWithInt:item.itemId]];
	}
    
    AsyncMediaImageView *iconView = (AsyncMediaImageView *)[cell viewWithTag:3];    
    Media *iconMedia;
	if(item.iconMediaId != 0)
    {
        if(!(iconMedia = [self.iconCache objectForKey:[NSNumber numberWithInt:item.itemId]]))
        {
            iconMedia = [[AppModel sharedAppModel] mediaForMediaId:item.iconMediaId];
            [self.iconCache setObject:iconMedia forKey:[NSNumber numberWithInt:item.itemId]];
        }
        
        if(iconView.isLoading) //throw out old asyncview, add in new one
        {
            [iconView removeFromSuperview];
            iconView = [[AsyncMediaImageView alloc] initWithFrame:iconView.frame andMedia:iconMedia];
            [cell addSubview:iconView];
        }
        else
            [iconView loadMedia:iconMedia];
	}
    else
    {
		if([media.type isEqualToString:@"PHOTO"]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultImageIcon.png"]];
		if([media.type isEqualToString:@"AUDIO"]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultAudioIcon.png"]];
		if([media.type isEqualToString:@"VIDEO"]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultVideoIcon.png"]];
    }
        
	return cell;
}

//Removes all content after first <br> or </br> or <br /> tags, then removes all html
-(NSString *) stringByStrippingHTML:(NSString *)stringToStrip
{
    //PHIL- probably could convert this into a pretty simple regex. but it works for now...
    NSRange range;
    range = [stringToStrip rangeOfString:@"<br>"];   if(range.length != 0) stringToStrip = [stringToStrip substringToIndex:range.location];
    range = [stringToStrip rangeOfString:@"</br>"];  if(range.length != 0) stringToStrip = [stringToStrip substringToIndex:range.location];
    range = [stringToStrip rangeOfString:@"<br/>"];  if(range.length != 0) stringToStrip = [stringToStrip substringToIndex:range.location];
    range = [stringToStrip rangeOfString:@"<br />"]; if(range.length != 0) stringToStrip = [stringToStrip substringToIndex:range.location];

    while ((range = [stringToStrip rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        stringToStrip = [stringToStrip stringByReplacingCharactersInRange:range withString:@""];
    return stringToStrip;
}

- (NSString *) getQtyLabelStringForQty:(int)qty maxQty:(int)maxQty weight:(int)weight
{
    NSString *qtyString = @"";
    NSString *weightString = @"";
    if(qty > 1 || maxQty != 1) qtyString    = [NSString stringWithFormat:@"x%d",  qty];
    if(weight > 1)             weightString = [NSString stringWithFormat:@"\n%@ %d",NSLocalizedString(@"WeightKey", @""), weight];
    return [NSString stringWithFormat:@"%@%@",qtyString, weightString];
}

- (unsigned int) indexOf:(char)searchChar inString:(NSString *)searchString
{
	NSRange searchRange;
	searchRange.location = (unsigned int) searchChar;
	searchRange.length = 1;
	NSRange foundRange = [searchString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithRange:searchRange]];
	return foundRange.location;	
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"swish" shouldVibrate:NO];
    [delegate displayGameObject:[inventory objectAtIndex:[indexPath row]] fromSource:self];

    //[self.navigationController pushViewController:[((Item *)[inventory objectAtIndex:[indexPath row]]) viewControllerForDelegate:self] animated:YES];
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark Memory Management
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

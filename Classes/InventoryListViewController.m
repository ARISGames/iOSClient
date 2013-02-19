//
//  FilesViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "InventoryListViewController.h"
#import "AppServices.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "AppModel.h"
#import "NoteDetailsViewController.h"
#import "InventoryTradeViewController.h"

int badgeCount;

@implementation InventoryListViewController

@synthesize inventoryTable;
@synthesize inventory;
@synthesize tradeButton;
@synthesize capBar;
@synthesize capLabel;

@synthesize iconCache;
@synthesize mediaCache;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"InventoryViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"36-toolbox"];
        
        //Alloc caches
        self.mediaCache = [[NSMutableDictionary alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
        self.iconCache  = [[NSMutableDictionary alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
        
		//register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedInventory"           object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"              object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyAcquiredItemsAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyLostItemsAvailable"     object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge)         name:@"NewlyChangedItemsGameNotificationSent"    object:nil];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	[super viewDidLoad];
    
    if([AppModel sharedAppModel].currentGame.allowTrading)
    {
        UIBarButtonItem *tradeButtonAlloc = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"InventoryTradeViewTitleKey", @"") style:UIBarButtonItemStyleDone target:self action:@selector(tradeButtonTouched)];
        self.tradeButton = tradeButtonAlloc;
        [self.navigationItem setRightBarButtonItem:self.tradeButton];
    }
    
	NSLog(@"Inventory View Loaded");
}

- (void)viewWillAppear:(BOOL)animated
{
    int currentWeight = [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight;
    int weightCap     = [AppModel sharedAppModel].currentGame.inventoryModel.weightCap;
    if(weightCap <= 0)
    {
        self.capBar.progress = 0;
        self.capBar.hidden = YES;
        self.capLabel.hidden = YES;
        self.inventoryTable.frame = CGRectMake(0, 0, 320, 367);
    }
    else
    {
        self.capBar.progress = (float)((float)currentWeight/(float)weightCap);
        self.capLabel.text = [NSString stringWithFormat: @"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""),currentWeight, weightCap];
        self.capBar.hidden = NO;
        self.capLabel.hidden = NO;
        self.inventoryTable.frame = CGRectMake(0, 42, 320, 325);
    }
    
    if([AppModel sharedAppModel].currentGame.allowTrading)
    {
        UIBarButtonItem *tradeButtonAlloc = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"InventoryTradeViewTitleKey", @"") style:UIBarButtonItemStyleDone target:self action:@selector(tradeButtonTouched)];
        self.tradeButton = tradeButtonAlloc;
        [self.navigationItem setRightBarButtonItem:self.tradeButton];
    }
    else if(self.tradeButton != nil)
    {
        // remove trade button if it shouldn't be there
        self.navigationItem.rightBarButtonItem = nil;
        self.tradeButton = nil;
    }

}
- (void)viewDidAppear:(BOOL)animated
{
    badgeCount = 0;
    self.tabBarItem.badgeValue = nil;
    
    [[AppServices sharedAppServices] updateServerInventoryViewed];
	[self refresh];				
}

-(void)tradeButtonTouched{
    InventoryTradeViewController *tradeVC = [[InventoryTradeViewController alloc] initWithNibName:@"InventoryTradeViewController" bundle:nil];
    tradeVC.delegate = self;
    tradeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tradeVC animated:YES];
}

-(void)dismissTutorial{
	[[RootViewController sharedRootViewController].tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindInventoryTab];
}

-(void)refresh
{
	NSLog(@"InventoryListViewController: Refresh Requested");
	[[AppServices sharedAppServices] fetchPlayerInventory];
	[self showLoadingIndicator];
}

-(void)showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator
{
	[[self navigationItem] setRightBarButtonItem:self.tradeButton];
}

-(void)incrementBadge
{
    badgeCount++;
    self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeCount];
}

-(void)refreshViewFromModel
{
	NSLog(@"InventoryListViewController: Refresh View from Model");
    
    if (![AppModel sharedAppModel].hasSeenInventoryTabTutorial)
    {
        [[RootViewController sharedRootViewController].tutorialViewController showTutorialPopupPointingToTabForViewController:self.navigationController
                                                                                                                         type:tutorialPopupKindInventoryTab
                                                                                                                        title:NSLocalizedString(@"InventoryNewItemKey", @"")
                                                                                                                      message:NSLocalizedString(@"InventoryNewItemMessageKey", @"")];
        [AppModel sharedAppModel].hasSeenInventoryTabTutorial = YES;
        [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
    }
	
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name"      ascending:YES];
    NSSortDescriptor *sortDescriptorNew  = [[NSSortDescriptor alloc] initWithKey:@"hasViewed" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorNew, sortDescriptorName, nil];
    self.inventory = [AppModel sharedAppModel].currentGame.inventoryModel.currentInventory;
    self.inventory = [self.inventory sortedArrayUsingDescriptors:sortDescriptors];
    [inventoryTable reloadData];
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier
{
	CGRect CellFrame = CGRectMake(0, 0, 310, 60);
	CGRect IconFrame = CGRectMake(5, 5, 50, 50);
    //CGRect NewBannerFrame = CGRectMake(2, 2, 55, 55);
	CGRect Label1Frame = CGRectMake(70, 12, 180, 20); //Title
	CGRect Label2Frame = CGRectMake(70, 29, 240, 20); //Desc
    CGRect Label3Frame = CGRectMake(260, 12, 50, 20); //Qty
	UILabel *lblTemp;
	UIImageView *iconViewTemp;
    UIImageView *newBannerViewTemp;
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:cellIdentifier];	
	//Setup Cell
	UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.backgroundView = transparentBackground;
	
	//Initialize Label with tag 1.
	lblTemp = [[UILabel alloc] initWithFrame:Label1Frame];
	lblTemp.tag = 1;
	//lblTemp.textColor = [UIColor whiteColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:Label2Frame];
	lblTemp.tag = 2;
	lblTemp.font = [UIFont systemFontOfSize:11];
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Init Icon with tag 3
	iconViewTemp = [[AsyncMediaImageView alloc] initWithFrame:IconFrame];
	iconViewTemp.tag = 3;
	iconViewTemp.backgroundColor = [UIColor clearColor]; 
	[cell.contentView addSubview:iconViewTemp];
    
    //Init Icon with tag 5
	/*newBannerViewTemp = [[AsyncMediaImageView alloc] initWithFrame:NewBannerFrame];
	newBannerViewTemp.tag = 5;
	newBannerViewTemp.backgroundColor = [UIColor clearColor]; 
	[cell.contentView addSubview:newBannerViewTemp];*/
    
    //Init Icon with tag 4
    lblTemp = [[UILabel alloc] initWithFrame:Label3Frame];
	lblTemp.tag = 4;
    //lblTemp.font = [UIFont systemFontOfSize:11];
    
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
    //lblTemp.textAlignment = UITextAlignmentRight;
	[cell.contentView addSubview:lblTemp];
    
	return cell;
}


#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [inventory count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) cell = [self getCellContentView:CellIdentifier];
    
    cell.textLabel.backgroundColor = [UIColor clearColor]; 
    cell.detailTextLabel.backgroundColor = [UIColor clearColor]; 
    
    if (indexPath.row % 2 == 0)
        cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0  
                                                           green:233.0/255.0  
                                                            blue:233.0/255.0  
                                                           alpha:1.0];  
    else
        cell.contentView.backgroundColor = [UIColor colorWithRed:200.0/255.0
                                                           green:200.0/255.0  
                                                            blue:200.0/255.0  
                                                           alpha:1.0];
    
	Item *item = [inventory objectAtIndex: [indexPath row]];
	
	UILabel *lblTemp1 = (UILabel *)[cell viewWithTag:1];
	lblTemp1.text = item.name;	
    if (item.hasViewed == NO) 
        lblTemp1.font = [UIFont boldSystemFontOfSize:18];
    else 
        lblTemp1.font = [UIFont systemFontOfSize:18];
    
    UILabel *lblTemp2 = (UILabel *)[cell viewWithTag:2];
    
    // if description has html tags in it, take first line (up until <br>) and display unformatted text for decription
    NSRange range = [item.description rangeOfString:@"<br>"];
    NSString *shortDescription;
    if (range.length != 0)
       shortDescription = [item.description substringToIndex:range.location];
    else
        shortDescription = item.description;
    range = [shortDescription rangeOfString:@"</br>"];
    if (range.length != 0)
        shortDescription = [shortDescription substringToIndex:range.location];
    else
        shortDescription = shortDescription;
    
    NSString *strippedDescriptionString = [self stringByStrippingHTML:shortDescription];
    lblTemp2.text = strippedDescriptionString;

    //AsyncMediaImageView *newBannerView = (AsyncMediaImageView *)[cell viewWithTag:5];
    
    UILabel *lblTemp3 = (UILabel *)[cell viewWithTag:4];
    lblTemp3.numberOfLines = 2;
    if(item.qty >1 && item.weight > 1)
        lblTemp3.text = [NSString stringWithFormat:@"%@: %d/n%@ %d",NSLocalizedString(@"QuantityKey", @""),item.qty,NSLocalizedString(@"WeightKey", @""),item.weight];
    else if(item.weight > 1)
        lblTemp3.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"WeightKey", @""),item.weight];
    else if(item.qty > 1)
        lblTemp3.text = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"x", @""),item.qty];
    else
        lblTemp3.text = nil;
    //newBannerView.hidden = NO;
    
    Media *media;
    if (item.mediaId != 0 && ![item.type isEqualToString:@"NOTE"])
    {
        if(!(media = [self.mediaCache objectForKey:[NSNumber numberWithInt:item.itemId]]))
        {
            media = [[AppModel sharedAppModel] mediaForMediaId: item.mediaId];
            [self.mediaCache setObject:media forKey:[NSNumber numberWithInt:item.itemId]];
        }
	}
    
    AsyncMediaImageView *iconView = (AsyncMediaImageView *)[cell viewWithTag:3];
    iconView.hidden = NO;
    
    Media *iconMedia;
	if (item.iconMediaId != 0)
    {
        if(!(iconMedia = [self.iconCache objectForKey:[NSNumber numberWithInt:item.itemId]]))
        {
            iconMedia = [[AppModel sharedAppModel] mediaForMediaId:item.iconMediaId];
            [self.iconCache setObject:iconMedia forKey:[NSNumber numberWithInt:item.itemId]];
        }
        
        if(iconView.isLoading)
        {
            CGRect oldFrame = iconView.frame;
            iconView = [[AsyncMediaImageView alloc] initWithFrame:oldFrame andMedia:iconMedia];
        }
        [iconView loadImageFromMedia:iconMedia];
	}
    else
    {
		//Load the Default
		if ([media.type isEqualToString: kMediaTypeImage])
            [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultImageIcon.png"]];
		if ([media.type isEqualToString: kMediaTypeAudio])
            [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultAudioIcon.png"]];
		if ([media.type isEqualToString: kMediaTypeVideo]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultVideoIcon.png"]];
    }
        
    // if new item, show new banner
   /* if (item.hasViewed == NO) {
        UIImage *newBannerImage = [UIImage imageNamed:@"newBanner.png"];
        [newBannerView updateViewWithNewImage:newBannerImage];
        newBannerView.hidden = NO;
    } else {
        newBannerView.hidden = YES;   
    }*/
        
    
	return cell;
}


-(NSString *) stringByStrippingHTML: (NSString *)stringToStrip{
    NSRange r;
    NSString *s = stringToStrip;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

- (unsigned int) indexOf:(char) searchChar inString:(NSString *)searchString {
	NSRange searchRange;
	searchRange.location = (unsigned int) searchChar;
	searchRange.length = 1;
	NSRange foundRange = [searchString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithRange:searchRange]];
	return foundRange.location;	
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    
	Item *selectedItem = [inventory objectAtIndex:[indexPath row]];
	NSLog(@"Displaying Detail View: %@", selectedItem.name);
    
	[((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"swish" shouldVibrate:NO];
	
	ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] 
															initWithNibName:@"ItemDetailsView" bundle:[NSBundle mainBundle]];
	itemDetailsViewController.item = selectedItem;
	itemDetailsViewController.navigationItem.title = selectedItem.name;
	itemDetailsViewController.inInventory = YES;
	itemDetailsViewController.hidesBottomBarWhenPushed = YES;
    
	//Put the view on the screen
	[[self navigationController] pushViewController:itemDetailsViewController animated:YES];
	
}

#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

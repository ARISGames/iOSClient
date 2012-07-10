//
//  InventoryTradeViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InventoryTradeViewController.h"

@implementation InventoryTradeViewController

@synthesize tradeTableView;
@synthesize inventory;
@synthesize itemsToTrade;
@synthesize iconCache;
@synthesize mediaCache;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"InventoryTradeViewTitleKey",@"");
        NSMutableArray *iconCacheAlloc = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].inventory count]];
        self.iconCache = iconCacheAlloc;
        NSMutableArray *mediaCacheAlloc = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].inventory count]];
        self.mediaCache = mediaCacheAlloc;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent = YES;
    NSMutableArray *inventoryAlloc = [[[AppModel sharedAppModel].inventory allValues] mutableCopy];
	self.inventory = inventoryAlloc;
    NSMutableArray *itemsToTradeAlloc = [[NSMutableArray alloc] init];
    self.itemsToTrade = itemsToTradeAlloc;
    [self.tradeTableView reloadData];
    
    //Create a close button
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"")
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tradeTableView reloadData];
}

- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"ItemTradeViewController: Dismiss Item Trade View");
	
	[self.navigationController popToRootViewControllerAnimated:YES];
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent=NO;
    [appDelegate dismissNearbyObjectView:self];		
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	CGRect CellFrame = CGRectMake(0, 0, 320, 60);
	CGRect IconFrame = CGRectMake(5, 5, 50, 50);
	CGRect Label1Frame = CGRectMake(70, 22, 240, 20);
	CGRect Label2Frame = CGRectMake(70, 39, 240, 20);
    CGRect Label3Frame = CGRectMake(70, 5, 240, 20);
	UILabel *lblTemp;
	UIImageView *iconViewTemp;
	
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
    
    //Init Icon with tag 4
    lblTemp = [[UILabel alloc] initWithFrame:Label3Frame];
	lblTemp.tag = 4;
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
    //lblTemp.textAlignment = UITextAlignmentRight;
	[cell.contentView addSubview:lblTemp];
    
	return cell;
}


#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) return [self.itemsToTrade count];
	return [self.inventory count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0) return NSLocalizedString(@"InventoryTradeViewToTradeKey", @"");
    
    return NSLocalizedString(@"InventoryViewTitleKey",@""); 
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"GamePickerVC: Cell requested for section: %d row: %d",indexPath.section,indexPath.row);
    
	NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if(cell == nil) cell = [self getCellContentView:CellIdentifier];
    
    cell.textLabel.backgroundColor = [UIColor clearColor]; 
    cell.detailTextLabel.backgroundColor = [UIColor clearColor]; 
    
    if (indexPath.row % 2 == 0){  
        cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0  
                                                           green:233.0/255.0  
                                                            blue:233.0/255.0  
                                                           alpha:1.0];  
    } 
    else {  
        cell.contentView.backgroundColor = [UIColor colorWithRed:200.0/255.0  
                                                           green:200.0/255.0  
                                                            blue:200.0/255.0  
                                                           alpha:1.0];  
    } 
	
	Item *item = [self.inventory objectAtIndex: [indexPath row]];
	
	UILabel *lblTemp1 = (UILabel *)[cell viewWithTag:1];
	lblTemp1.text = item.name;	
    lblTemp1.font = [UIFont boldSystemFontOfSize:18.0];
    
    UILabel *lblTemp2 = (UILabel *)[cell viewWithTag:2];
    lblTemp2.text = item.description;
	AsyncMediaImageView *iconView = (AsyncMediaImageView *)[cell viewWithTag:3];
    
    UILabel *lblTemp3 = (UILabel *)[cell viewWithTag:4];
    if(item.qty >1 && item.weight > 1)
        lblTemp3.text = [NSString stringWithFormat:@"%@: %d, %@: %d",NSLocalizedString(@"QuantityKey", @""),item.qty,NSLocalizedString(@"WeightKey", @""),item.weight];
    else if(item.weight > 1)
        lblTemp3.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"WeightKey", @""),item.weight];
    else if(item.qty > 1)
        lblTemp3.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"QuantityKey", @""),item.qty];
    else
        lblTemp3.text = nil;
    iconView.hidden = NO;
    Media *media;
    if (item.mediaId != 0 && ![item.type isEqualToString:@"NOTE"]) {
        if([self.mediaCache count] > indexPath.row){
            media = [self.mediaCache objectAtIndex:indexPath.row];
        }
        else{
            
            media = [[AppModel sharedAppModel] mediaForMediaId: item.mediaId];
            if(media)
                [self.mediaCache  addObject:media];
        }
	}
    
	if (item.iconMediaId != 0) {
        Media *iconMedia;
        if([self.iconCache count] < indexPath.row){
            iconMedia = [self.iconCache objectAtIndex:indexPath.row];
            [iconView updateViewWithNewImage:[UIImage imageWithData:iconMedia.image]];
        }
        else{
            iconMedia = [[AppModel sharedAppModel] mediaForMediaId: item.iconMediaId];
            [self.iconCache  addObject:iconMedia];
            [iconView loadImageFromMedia:iconMedia];
        }
	}
	else {
		//Load the Default
		if ([media.type isEqualToString: kMediaTypeImage]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultImageIcon.png"]];
		if ([media.type isEqualToString: kMediaTypeAudio]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultAudioIcon.png"]];
		if ([media.type isEqualToString: kMediaTypeVideo]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultVideoIcon.png"]];	}
    
	return cell;
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
    
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
	
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

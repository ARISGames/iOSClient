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

@implementation InventoryListViewController

@synthesize inventoryTable;
@synthesize inventory;
@synthesize iconCache;
@synthesize mediaCache;
@synthesize capBar;
@synthesize capLabel;
@synthesize weightCap, currentWeight;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"InventoryViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"36-toolbox"];
        NSMutableArray *iconCacheAlloc = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].inventory count]];
        self.iconCache = iconCacheAlloc;
         NSMutableArray *mediaCacheAlloc = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].inventory count]];
        self.mediaCache = mediaCacheAlloc;
        
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedInventory" object:nil];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewInventoryReady" object:nil];
        [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost" object:nil];

		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
    }
    return self;
}

- (void)silenceNextUpdate {
	silenceNextServerUpdateCount++;
	NSLog(@"InventoryListViewController: silenceNextUpdate. Count is %d",silenceNextServerUpdateCount);

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	[super viewDidLoad];
    
    UIBarButtonItem *tradeButtonAlloc = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"InventoryTradeViewTitleKey", @"") style:UIBarButtonItemStyleDone target:self action:@selector(tradeButtonTouched)];
    self.tradeButton = tradeButtonAlloc;
    [self.navigationItem setRightBarButtonItem:self.tradeButton];
    
	NSLog(@"Inventory View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {

    [[AppServices sharedAppServices] updateServerInventoryViewed];
	[self refresh];		
	
	self.tabBarItem.badgeValue = nil;
	newItemsSinceLastView = 0;
	silenceNextServerUpdateCount = 0;
	
	NSLog(@"InventoryListViewController: view did appear");
	
	
}

-(void)tradeButtonTouched{
    InventoryTradeViewController *tradeVC = [[InventoryTradeViewController alloc] initWithNibName:@"InventoryTradeViewController" bundle:nil];
  //  tradeVC.delegate = self;
    [self.navigationController pushViewController:tradeVC animated:YES];
}

-(void)dismissTutorial{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindInventoryTab];
}

-(void)refresh {
	NSLog(@"InventoryListViewController: Refresh Requested");
    self.weightCap = [AppModel sharedAppModel].currentGame.inventoryWeightCap;
    self.currentWeight = [AppModel sharedAppModel].currentGame.currentWeight;
    if(self.weightCap == 0){
        [capBar setHidden:YES];
        [capLabel setHidden:YES];
        inventoryTable.frame = CGRectMake(0, 0, 320, 367);
    }
    else {
        [capBar setHidden:NO];
        [capLabel setHidden:NO];
        inventoryTable.frame = CGRectMake(0, 42, 320, 325);
            capBar.progress = (float)((float) currentWeight/(float)weightCap);
            capLabel.text = [NSString stringWithFormat: @"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""), currentWeight, weightCap];
    }
    [capBar setProgress:0];
	[[AppServices sharedAppServices] fetchInventory];
    [self refreshViewFromModel];
	[self showLoadingIndicator];
}

-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator{
	//Do this now in case refreshViewFromModel isn't called due to == hash
	[[self navigationItem] setRightBarButtonItem:self.tradeButton];
	NSLog(@"InventoryListViewController: removeLoadingIndicator. silenceCount = %d",silenceNextServerUpdateCount);
}

-(void)refreshViewFromModel {
	NSLog(@"InventoryListViewController: Refresh View from Model");
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Calculate current Weight
    self.currentWeight = 0;
    for (Item *item in [[AppModel sharedAppModel].inventory allValues]){
    self.currentWeight += item.weight*item.qty;
    }
    [AppModel sharedAppModel].currentGame.currentWeight = self.currentWeight;
    capBar.progress = (float)((float)currentWeight/(float)weightCap);
    capLabel.text = [NSString stringWithFormat: @"%@: %d/%d", NSLocalizedString(@"WeightCapacityKey", @""),currentWeight, weightCap];
    
	if (silenceNextServerUpdateCount < 1) {		
		NSArray *newInventory = [[AppModel sharedAppModel].inventory allValues];
		//Check if anything is new since last time
		int newItems = 0;
        UIViewController *topViewController =  [[self navigationController] topViewController];
		for (Item *item in newInventory) {	


			BOOL match = NO;
			for (Item *existingItem in self.inventory) {
				if (existingItem.itemId == item.itemId) match = YES;	
                if ((existingItem.itemId == item.itemId) && (existingItem.qty < item.qty)){
                   if([topViewController respondsToSelector:@selector(updateQuantityDisplay)])
                       [[[self navigationController] topViewController] respondsToSelector:@selector(updateQuantityDisplay)];
                    
                   NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item Received",@"title",[NSString stringWithFormat:@"%d %@ %@",item.qty - existingItem.qty,item.name,NSLocalizedString(@"InventoryAddedToKey", @"")],@"prompt", nil];
                    [appDelegate.notifArray addObject:dict];
                    [appDelegate showNotifications];
                    //[appDelegate performSelector:@selector(displayNotificationTitle:) withObject:dict afterDelay:.1];
                 
                }
                              
			}

			if (match == NO) {
                if([AppModel sharedAppModel].profilePic)
                {
                    [AppModel sharedAppModel].profilePic = NO;
                    [AppModel sharedAppModel].currentGame.pcMediaId = item.mediaId;
                }
                if([topViewController respondsToSelector:@selector(updateQuantityDisplay)])
                    [[[self navigationController] topViewController] respondsToSelector:@selector(updateQuantityDisplay)];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item Received",@"title",[NSString stringWithFormat:@"%d %@ %@",item.qty,item.name,NSLocalizedString(@"InventoryAddedToKey", @"")],@"prompt", nil];
              [appDelegate.notifArray addObject:dict];
                [appDelegate showNotifications];

                //[appDelegate performSelector:@selector(displayNotificationTitle:) withObject:dict afterDelay:.1];
				newItems ++;;
			}
		}
		if (newItems > 0) {
			newItemsSinceLastView += newItems;
			self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newItemsSinceLastView];
						
			//Vibrate and Play Sound
			[appDelegate playAudioAlert:@"inventoryChange" shouldVibrate:YES];
			
			//Put up the tutorial tab
			if (![AppModel sharedAppModel].hasSeenInventoryTabTutorial){
				[appDelegate.tutorialViewController showTutorialPopupPointingToTabForViewController:self.navigationController  
                        type:tutorialPopupKindInventoryTab
                            title:NSLocalizedString(@"InventoryNewItemKey", @"")  
                            message:NSLocalizedString(@"InventoryNewItemMessageKey", @"")];						
				[AppModel sharedAppModel].hasSeenInventoryTabTutorial = YES;
                [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
			}
				
			
		}
		else if (newItemsSinceLastView < 1) self.tabBarItem.badgeValue = nil;
		
	}
	else {
		newItemsSinceLastView = 0;
		self.tabBarItem.badgeValue = nil;
	}
	
	self.inventory = [[AppModel sharedAppModel].inventory allValues];
	[inventoryTable reloadData];
	
	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hasViewed"
                                                  ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.inventory = [self.inventory sortedArrayUsingDescriptors:sortDescriptors];

	
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
    
    if (indexPath.row % 2 == 0){  
        cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0  
                                                           green:233.0/255.0  
                                                            blue:233.0/255.0  
                                                           alpha:1.0];  
    } else {  
        cell.contentView.backgroundColor = [UIColor colorWithRed:200.0/255.0  
                                                           green:200.0/255.0  
                                                            blue:200.0/255.0  
                                                           alpha:1.0];  
    } 

    
	
	Item *item = [inventory objectAtIndex: [indexPath row]];
	
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
@end

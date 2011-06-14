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
#import "AsyncImageView.h"


@implementation InventoryListViewController

@synthesize inventoryTable;
@synthesize inventory;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"InventoryViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"inventory.png"];
		
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedInventory" object:nil];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewInventoryReady" object:nil];
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

-(void)dismissTutorial{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindInventoryTab];
}

-(void)refresh {
	NSLog(@"InventoryListViewController: Refresh Requested");
	[[AppServices sharedAppServices] fetchInventory];
	[self showLoadingIndicator];
}

-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[barButton release];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator{
	//Do this now in case refreshViewFromModel isn't called due to == hash

	[[self navigationItem] setRightBarButtonItem:nil];
	NSLog(@"InventoryListViewController: removeLoadingIndicator. silenceCount = %d",silenceNextServerUpdateCount);
}

-(void)refreshViewFromModel {
	NSLog(@"InventoryListViewController: Refresh View from Model");
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];

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
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item Recieved",@"title",[NSString stringWithFormat:@"%d %@ added to inventory",item.qty - existingItem.qty,item.name],@"prompt", nil];
                    
                    [appDelegate performSelector:@selector(displayNotificationTitle:) withObject:dict afterDelay:.1];
                 
                }
                /*if ((existingItem.itemId == item.itemId) && (existingItem.qty > item.qty)){
                    if([topViewController respondsToSelector:@selector(updateQuantityDisplay)])
                        [[[self navigationController] topViewController] respondsToSelector:@selector(updateQuantityDisplay)];

                    [appDelegate displayNotificationTitle:@"Lost Item!" andPrompt:[NSString stringWithFormat:@"%d %@ removed from inventory",existingItem.qty - item.qty,item.name]];
                    
                }*/
                
			}
			if (match == NO) {
                if([topViewController respondsToSelector:@selector(updateQuantityDisplay)])
                    [[[self navigationController] topViewController] respondsToSelector:@selector(updateQuantityDisplay)];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Item Recieved",@"title",[NSString stringWithFormat:@"%d %@ added to inventory",item.qty,item.name],@"prompt", nil];
                
                [appDelegate performSelector:@selector(displayNotificationTitle:) withObject:dict afterDelay:.1];

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
																							  title:@"New Item"  
																							message:@"You have a new Item in your Inventory! Touch below to view your items now."];						
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

	
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	CGRect CellFrame = CGRectMake(0, 0, 320, 60);
	CGRect IconFrame = CGRectMake(5, 5, 50, 50);
	CGRect Label1Frame = CGRectMake(70, 10, 240, 25);
	CGRect Label2Frame = CGRectMake(70, 33, 240, 25);
	UILabel *lblTemp;
	UIImageView *iconViewTemp;
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:cellIdentifier] autorelease];
	
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
	[lblTemp release];
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:Label2Frame];
	lblTemp.tag = 2;
	lblTemp.font = [UIFont boldSystemFontOfSize:12];
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Init Icon with tag 3
	iconViewTemp = [[AsyncImageView alloc] initWithFrame:IconFrame];
	iconViewTemp.tag = 3;
	iconViewTemp.backgroundColor = [UIColor clearColor]; 
	[cell.contentView addSubview:iconViewTemp];
	[iconViewTemp release];

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
	
	Item *item = [inventory objectAtIndex: [indexPath row]];
	
	UILabel *lblTemp1 = (UILabel *)[cell viewWithTag:1];
	lblTemp1.text = item.name;	
	
	UILabel *lblTemp2 = (UILabel *)[cell viewWithTag:2];
	if (item.qty > 1) lblTemp2.text = [NSString stringWithFormat:@"x %d ",item.qty];
	else lblTemp2.text = @"";
	
	AsyncImageView *iconView = (AsyncImageView *)[cell viewWithTag:3];
	
	Media *media = [[AppModel sharedAppModel] mediaForMediaId: item.mediaId];

	if (item.iconMediaId != 0) {
		Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId: item.iconMediaId];
		[iconView loadImageFromMedia:iconMedia];
	}
	else {
		//Load the Default
		if ([media.type isEqualToString: @"Image"]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultImageIcon.png"]];
		if ([media.type isEqualToString: @"Audio"]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultAudioIcon.png"]];
		if ([media.type isEqualToString: @"Video"]) [iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultVideoIcon.png"]];
	}
    
    
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
	
	[itemDetailsViewController release];
	
}

#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}
@end

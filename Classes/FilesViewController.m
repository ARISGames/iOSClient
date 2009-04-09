//
//  FilesViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "FilesViewController.h"


@implementation FilesViewController

@synthesize moduleName;
@synthesize inventoryTable;
@synthesize inventoryTableData;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	moduleName = @"RESTInventory";
	
	//register for notifications
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(refreshInventory) name:@"ReceivedInventory" object:nil];
	
	NSLog(@"Inventory View Loaded");
}

- (void)viewDidAppear {
}


-(void) setModel:(AppModel *)model {
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	
	//Populate inventory
	[appModel fetchInventory];
	inventoryTableData = appModel.inventory;
	[inventoryTable reloadData];
		
	NSLog(@"model set for Inventory");
}

-(void)refreshInventory {
	NSLog(@"Inventory Recieved message recieved in FilesViewController");
	[inventoryTable reloadData];
	
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	
	CGRect CellFrame = CGRectMake(0, 0, 300, 60);
	CGRect IconFrame = CGRectMake(10, 10, 50, 50);
	CGRect Label1Frame = CGRectMake(70, 10, 290, 25);
	CGRect Label2Frame = CGRectMake(70, 33, 290, 25);
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
	lblTemp.textColor = [UIColor whiteColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:Label2Frame];
	lblTemp.tag = 2;
	lblTemp.font = [UIFont boldSystemFontOfSize:12];
	lblTemp.textColor = [UIColor lightGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Init Icon with tag 3
	iconViewTemp = [[UIImageView alloc] initWithFrame:IconFrame];
	iconViewTemp.tag = 3;
	iconViewTemp.backgroundColor = [UIColor blackColor];
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
	return [inventoryTableData count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil)
		cell = [self getCellContentView:CellIdentifier];
	
	UILabel *lblTemp1 = (UILabel *)[cell viewWithTag:1];
	lblTemp1.text = [[inventoryTableData objectAtIndex: [indexPath row]] name];
	
	UILabel *lblTemp2 = (UILabel *)[cell viewWithTag:2];
	lblTemp2.text = [[inventoryTableData objectAtIndex: [indexPath row]] description];
	
	UIImageView *iconView = (UIImageView *)[cell viewWithTag:3];
	NSString* iconURL = [[[inventoryTableData objectAtIndex: [indexPath row]] iconURL] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSData* iconData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:iconURL]];
	UIImage* icon = [[UIImage alloc] initWithData:iconData];
	[iconView setImage:icon];
	[iconURL release];
	[iconData release];
	[icon release];
			
	return cell;	
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	Item *selectedItem = [inventoryTableData objectAtIndex:[indexPath row]];
	NSLog(@"Displaying Detail View: %@", selectedItem.name);
	
	ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] initWithNibName:@"ItemDetailsView" bundle:[NSBundle mainBundle]];
	[itemDetailsViewController setModel:appModel];
	[itemDetailsViewController setItem:selectedItem];
	[self presentModalViewController:itemDetailsViewController animated:NO];
	[itemDetailsViewController release];
}








#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[appModel release];
	[moduleName release];
    [super dealloc];
}


@end

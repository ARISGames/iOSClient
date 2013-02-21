//
//  DeveloperViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "DeveloperViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"

@implementation DeveloperViewController

@synthesize locationTable;
@synthesize locationTableData;
@synthesize clearEventsButton;
@synthesize clearItemsButton;
@synthesize accuracyLabelValue;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"DeveloperTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"developer.png"];
		
		//register for notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAccuracy) name:@"PlayerMoved" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewLocationListReady" object:nil];	
	
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self refresh];
	
	NSLog(@"DeveloperViewController: view loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	[self refresh];		
	NSLog(@"DeveloperViewController: view did appear");
}


-(void) refresh {	
	NSLog(@"DeveloperViewController: Refresh Began");

	//[[AppModel sharedAppModel] fetchLocationList];
}

-(void) refreshViewFromModel {
	NSLog(@"DeveloperViewController: Model Updated, refreshing view");
	
	locationTableData = [AppModel sharedAppModel].currentGame.locationsModel.currentLocations;
	[locationTable reloadData];
	
	//Init Accuracy Label
	accuracyLabelValue.text = [NSString stringWithFormat:@"+/-%1.2f %@", 
							   [AppModel sharedAppModel].playerLocation.horizontalAccuracy], NSLocalizedString(@"DevelopersMetersKey", @""); 
}

-(void) updateAccuracy{
	accuracyLabelValue.text = [NSString stringWithFormat:@"+/-%1.2f %@",[AppModel sharedAppModel].playerLocation.horizontalAccuracy], NSLocalizedString(@"DevelopersMetersKey", @""); 
}

#pragma mark IB Button Actions

-(IBAction)clearEventsButtonTouched: (id) sender{
	/*
	//Fire off a request to the REST Module and display an alert when it is successfull
	NSString *baseURL = [[AppModel sharedAppModel] getURLStringForModule:moduleName];
	NSString *URLparams = @"&event=deleteAllEvents";
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
	
	NSLog([NSString stringWithFormat:@"Deleting all Events for this Player on server: %@", fullURL ]);
	
	NSString *result = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fullURL]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success" message: result delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[result release];
	[alert release];
	 */
	
}

-(IBAction)clearItemsButtonTouched: (id) sender{
	/*
	//Fire off a request to the REST Module and display an alert when it is successfull
	NSString *baseURL = [[AppModel sharedAppModel] getURLStringForModule:moduleName];
	NSString *URLparams = @"&event=deleteAllItems";
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];

	NSLog([NSString stringWithFormat:@"Deleting all Items for this Player on server: %@", fullURL ]);
	
	NSString *result = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fullURL]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success" message: result delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[result release];
	[alert release];
	 */
}


#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == locationTable) return [locationTableData count];
	else return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//Set up the cell
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    }
	cell.textLabel.textColor = [[UIColor alloc] initWithWhite:1.0 alpha:1.0]; 	

	//Set the text based on who's asking
	if (tableView == locationTable) cell.textLabel.text = [[locationTableData objectAtIndex: [indexPath row]] name];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (tableView == locationTable) {
		Location *selectedLocation = [locationTableData objectAtIndex:[indexPath row]];
		NSLog(@"DeveloperViewController: Location Selected. Forcing AppModel to Latitude: %1.2f Longitude: %1.2f", selectedLocation.location.coordinate.latitude, selectedLocation.location.coordinate.longitude);
		[AppModel sharedAppModel].playerLocation = [selectedLocation.location copy];
	}
}


#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



@end

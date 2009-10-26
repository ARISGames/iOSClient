//
//  DeveloperViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "DeveloperViewController.h"

@implementation DeveloperViewController

@synthesize moduleName;
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
        self.title = @"Developer";
        self.tabBarItem.image = [UIImage imageNamed:@"Developer.png"];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	moduleName = @"RESTDeveloper";
	
	//register for notifications
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(updateAccuracy) name:@"PlayerMoved" object:nil];	
	
	NSLog(@"Developer loaded");
}

- (void)viewDidAppear {	
	
}


-(void) setModel:(AppModel *)model {
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	
	//Populate locations array
	[appModel fetchLocationList];
	locationTableData = appModel.locationList;
	[locationTable reloadData];
	
	//Init Accuracy Label
	accuracyLabelValue.text = [NSString stringWithFormat:@"+/-%1.2f Meters", appModel.lastLocation.horizontalAccuracy]; 
		
	NSLog(@"model set for DEV");
}

-(void) updateAccuracy{
	accuracyLabelValue.text = [NSString stringWithFormat:@"+/-%1.2f Meters",appModel.lastLocation.horizontalAccuracy]; 
}

#pragma mark IB Button Actions

-(IBAction)clearEventsButtonTouched: (id) sender{
	//Fire off a request to the REST Module and display an alert when it is successfull
	NSString *baseURL = [appModel getURLStringForModule:moduleName];
	NSString *URLparams = @"&event=deleteAllEvents";
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
	
	NSLog([NSString stringWithFormat:@"Deleting all Events for this Player on server: %@", fullURL ]);
	
	NSString *result = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fullURL]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success" message: result delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[result release];
	[alert release];
	
}

-(IBAction)clearItemsButtonTouched: (id) sender{
	//Fire off a request to the REST Module and display an alert when it is successfull
	NSString *baseURL = [appModel getURLStringForModule:moduleName];
	NSString *URLparams = @"&event=deleteAllItems";
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];

	NSLog([NSString stringWithFormat:@"Deleting all Items for this Player on server: %@", fullURL ]);
	
	NSString *result = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fullURL]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success" message: result delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[result release];
	[alert release];

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
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.textColor = [[UIColor alloc] initWithWhite:1.0 alpha:1.0]; 	

	//Set the text based on who's asking
	if (tableView == locationTable) cell.text = [[locationTableData objectAtIndex: [indexPath row]] name];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (tableView == locationTable) {
		Location *selectedLocation = [locationTableData objectAtIndex:[indexPath row]];
		NSLog([NSString stringWithFormat:@"Location Selected. Forcing appModel to Latitude: %1.2f Longitude: %1.2f", selectedLocation.latitude, selectedLocation.longitude]);
		
		CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:selectedLocation.latitude longitude:selectedLocation.longitude];

		appModel.lastLocation = newLocation;
		[appModel updateServerLocationAndfetchNearbyLocationList];
	}
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

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
@synthesize serverTable;
@synthesize serverTableData;
@synthesize clearEventsButton;
@synthesize clearItemsButton;
@synthesize accuracyLabelValue;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	moduleName = @"RESTDeveloper";
	
	//register for notifications
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(updateAccuracy) name:@"PlayerMoved" object:nil];	
	
	//Populate server array
	serverTableData = [[NSMutableArray alloc] init];
    [self.serverTableData addObject: @"http://davembp.local/engine/index.php"];
    [self.serverTableData addObject: @"http://atsosxdev.doit.wisc.edu/aris/games/index.php"];
	//Add more debugging servers here
	[self.serverTable reloadData];	
	
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
	accuracyLabelValue.text = [NSString stringWithFormat:@"+/-%1.2f Meters", appModel.lastLocationAccuracy]; 
		
	NSLog(@"model set for DEV");
}

-(void) updateAccuracy{
	accuracyLabelValue.text = [NSString stringWithFormat:@"+/-%1.2f Meters", appModel.lastLocationAccuracy]; 
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
	else if (tableView == serverTable) return [serverTableData count];
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
	else if (tableView == serverTable) cell.text = [self.serverTableData objectAtIndex: [indexPath row]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (tableView == locationTable) {
		Location *selectedLocation = [locationTableData objectAtIndex:[indexPath row]];
		NSLog([NSString stringWithFormat:@"Location Selected. Forcing appModel to Latitude: %@ Longitude: %@", selectedLocation.latitude, selectedLocation.longitude]);
		appModel.lastLatitude = selectedLocation.latitude;
		appModel.lastLongitude = selectedLocation.longitude;
		NSLog(@"Updating Server Location and Fetching Nearby Location List");
		[appModel updateServerLocationAndfetchNearbyLocationList];
	}
	
	else if (tableView == serverTable) {
		//change model's URL
		appModel.baseAppURL = [serverTableData objectAtIndex:[indexPath row]];
		//Logout the user
		NSNotification *logoutRequestNotification = [NSNotification notificationWithName:@"LogoutRequested" object:self];
		[[NSNotificationCenter defaultCenter] postNotification:logoutRequestNotification];
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

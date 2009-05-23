//
//  GPSViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GPSViewController.h"
#import "model/AppModel.h"
#import "RMMapView.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "Location.h"
#import "ARISAppDelegate.h"

@implementation GPSViewController

@synthesize mapView;
@synthesize moduleName;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"GPS";
        self.tabBarItem.image = [UIImage imageNamed:@"GPS.png"];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																							   target:self action:@selector(refresh:)] autorelease];
	}
    return self;
}
		
- (IBAction)refresh: (id) sender{

	NSLog(@"GPS: Refresh Requested");
	
	//Center the Map
	[[mapView contents] moveToLatLong:appModel.lastLocation.coordinate];
	
	//Force a location update
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate.myCLController.locationManager stopUpdatingLocation];
	[appDelegate.myCLController.locationManager startUpdatingLocation];


}
		
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	moduleName = @"RESTMap";
	
	NSLog(@"Begin Loading GPS View");
	
	//register for notifications
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(refreshPlayerMarker) name:@"PlayerMoved" object:nil];
	[dispatcher addObserver:self selector:@selector(refreshMarkers) name:@"ReceivedLocationList" object:nil];


	//Setup the Map
	CGFloat tableViewHeight = 416; // todo: get this from const
	CGRect mainViewBounds = self.view.bounds;
	CGRect tableFrame;
	tableFrame = CGRectMake(CGRectGetMinX(mainViewBounds),
							CGRectGetMinY(mainViewBounds),
							CGRectGetWidth(mainViewBounds),
							tableViewHeight);
	mapView = [[RMMapView alloc] initWithFrame:tableFrame];    
	[self.view addSubview:mapView];
	
	markerManager = [mapView markerManager];
	
	//Set up the Player Marker and Center the Map on them
	//Since we arn't ABSOLUTLY sure we have a valid playerLocation in the Model, make a fake one and let CLCController update later
	
	
	CLLocationCoordinate2D playerPosition;
	playerMarker = [[RMMarker alloc]initWithCGImage:[RMMarker loadPNGFromBundle:@"marker-player"]];
	[markerManager addMarker:playerMarker AtLatLong:playerPosition];
	
	
	NSLog(@"GPS View Loaded");
}





-(void) setModel:(AppModel *)model {
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	NSLog(@"model set for GPS");
	
	[self refreshMap];
}




// Updates the map to current data for player and locations from the server
- (void) refreshMap {
	NSLog(@"GPS refreshMap requested");
	
	//Move the player marker
	[self refreshPlayerMarker];
		
	//Ask for the Locations to be loaded into the model, which will trigger a notification to refreshMarkers here
	[appModel fetchLocationList];
}

- (void)refreshPlayerMarker {
	NSLog(@"PlayerMoved notification recieved by GPS controller, running refreshPlayerMarker");
	
	//Move the player marker

	[markerManager moveMarker:playerMarker AtLatLon: appModel.lastLocation.coordinate];
	
	if (appModel.lastLocation.horizontalAccuracy > 0 && appModel.lastLocation.horizontalAccuracy < 100)
		[playerMarker replaceImage:[RMMarker loadPNGFromBundle:@"marker-player"] anchorPoint:CGPointMake(.5, .6)];
	else [playerMarker replaceImage:[RMMarker loadPNGFromBundle:@"marker-player-lqgps"] anchorPoint:CGPointMake(.5, .6)];

	
	[[mapView contents] moveToLatLong:appModel.lastLocation.coordinate];
}

- (void)refreshMarkers {
	NSLog(@"Refreshing Map Markers");
	
	//Blow away the old markers in the markerManager
	[markerManager removeMarkers];
	
	//Add the player marker back in
	[markerManager addMarker:playerMarker];
	
	//Add the freshly loaded locations from the notification
	for ( Location* location in appModel.locationList ) {
		if (location.hidden == YES) continue;
		CLLocationCoordinate2D locationLatLong;
		locationLatLong.latitude = location.latitude;
		locationLatLong.longitude = location.longitude;

		RMMarker *locationMarker = [[RMMarker alloc]initWithCGImage:[RMMarker loadPNGFromBundle:@"marker-blue"]];
		[locationMarker setTextLabel:location.name];
		[markerManager addMarker:locationMarker AtLatLong:locationLatLong];
		[locationMarker release];
		
	}
	
}


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

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
#import "Player.h"
#import "ARISAppDelegate.h"


static int DEFAULT_ZOOM = 16;

@implementation GPSViewController

@synthesize mapView;
@synthesize moduleName;
@synthesize autoCenter;

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
	
	autoCenter = YES;
    return self;
}
		
- (IBAction)refresh: (id) sender{

	NSLog(@"GPS: Refresh Button Touched");
	
	//Center the Map
	[[mapView contents] moveToLatLong:appModel.lastLocation.coordinate];
	
	//Force a location update
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate.myCLController.locationManager stopUpdatingLocation];
	[appDelegate.myCLController.locationManager startUpdatingLocation];

	//Rerfresh all contents
	[self refreshMap];
	
	//Zoom and Center
	[self zoomAndCenterMap];

}
		
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	moduleName = @"RESTMap";
	
	NSLog(@"Begin Loading GPS View");
	
	//register for notifications
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(refreshMap) name:@"PlayerMoved" object:nil];
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
	//[NSThread detachNewThreadSelector: @selector(fetchLocationList) toTarget:appModel withObject: nil];	
	[appModel fetchLocationList];

}

-(void) zoomAndCenterMap {
	
	//Center the map on the player
	[[mapView contents] moveToLatLong:appModel.lastLocation.coordinate];
	
	//Set to default zoom
	mapView.contents.zoom = DEFAULT_ZOOM;
}

- (void)refreshPlayerMarker {
	//Move the player marker

	[markerManager moveMarker:playerMarker AtLatLon: appModel.lastLocation.coordinate];
	
	if (appModel.lastLocation.horizontalAccuracy > 0 && appModel.lastLocation.horizontalAccuracy < 100)
		[playerMarker replaceImage:[RMMarker loadPNGFromBundle:@"marker-player"] anchorPoint:CGPointMake(.5, .6)];
	else [playerMarker replaceImage:[RMMarker loadPNGFromBundle:@"marker-player-lqgps"] anchorPoint:CGPointMake(.5, .6)];

	//Center the first time
	if (autoCenter == YES) [self zoomAndCenterMap];
	autoCenter = NO;
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
		NSString *label;
		if (location.qty > 0) label = [[NSString alloc] initWithFormat:@"%@ (%d)",location.name, location.qty];
		else label = location.name;
		[locationMarker setTextLabel:label];
		[markerManager addMarker:locationMarker AtLatLong:locationLatLong];
		[locationMarker release];
		
	}
	
	//Add the freshly loaded players from the notification
	for ( Player* player in appModel.playerList ) {
		if (player.hidden == YES) continue;
		CLLocationCoordinate2D locationLatLong;
		locationLatLong.latitude = player.latitude;
		locationLatLong.longitude = player.longitude;
		
		RMMarker *marker = [[RMMarker alloc]initWithCGImage:[RMMarker loadPNGFromBundle:@"marker-other-player"]];
		[marker setTextLabel:player.name];
		[markerManager addMarker:marker AtLatLong:locationLatLong];
		[marker release];
		
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

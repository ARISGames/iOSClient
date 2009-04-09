//
//  GPSViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GPSViewController.h"
#import "RMMapView.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "Location.h"

@implementation GPSViewController

@synthesize mapView;
@synthesize moduleName;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	moduleName = @"RESTMap";
	
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
	CLLocationCoordinate2D playerPosition;
	playerPosition.latitude = [appModel.lastLatitude floatValue];
	playerPosition.longitude = [appModel.lastLongitude floatValue];
	
	playerMarker = [[RMMarker alloc]initWithCGImage:[RMMarker loadPNGFromBundle:@"marker-player"]];
	[markerManager addMarker:playerMarker AtLatLong:playerPosition];
	[[mapView contents] moveToLatLong:playerPosition];
	
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
	CLLocationCoordinate2D playerPosition;
	playerPosition.latitude = [appModel.lastLatitude floatValue];
	playerPosition.longitude = [appModel.lastLongitude floatValue];
	[markerManager moveMarker:playerMarker AtLatLon: playerPosition];
	
	if (appModel.lastLocationAccuracy > 0 && appModel.lastLocationAccuracy < 100)
		[playerMarker replaceImage:[RMMarker loadPNGFromBundle:@"marker-player"] anchorPoint:CGPointMake(.5, .6)];
	else [playerMarker replaceImage:[RMMarker loadPNGFromBundle:@"marker-player-lqgps"] anchorPoint:CGPointMake(.5, .6)];

	
	[[mapView contents] moveToLatLong:playerPosition];
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
		locationLatLong.latitude = [location.latitude floatValue];
		locationLatLong.longitude = [location.longitude floatValue];

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

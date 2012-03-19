//
//  DropOnMapViewController.m
//  ARIS
//
//  Created by Brian Thiel on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DropOnMapViewController.h"
#import "ARISAppDelegate.h"
#import "AnnotationView.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"
#import "AppServices.h"

static float INITIAL_SPAN = 0.001;


@implementation DropOnMapViewController
@synthesize mapView,mapTypeButton,dropButton,locations,tracking,toolBar,noteId,myAnnotation,delegate,pickupButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Place Note On Map";
        self.hidesBottomBarWhenPushed = YES;
        tracking = YES;
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refresh) name:@"PlayerMoved" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [mapTypeButton release];
    [dropButton release];
    [pickupButton release];
    [locations release];
    [toolBar release];
    [myAnnotation release];
    [mapView release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSLog(@"Begin Loading DropOnMap View");
	mapView.showsUserLocation = YES;
	[mapView setDelegate:self];
	[self.view addSubview:mapView];
	NSLog(@"DropOnMapViewController: Mapview inited and added to view");

	DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:[AppModel sharedAppModel].playerLocation.coordinate addressDictionary:nil] autorelease];
	annotation.title = @"Drag to Move Note";
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	self.myAnnotation = annotation;
	[self.mapView addAnnotation:annotation];	

    //Setup the buttons
	mapTypeButton.target = self; 
	mapTypeButton.action = @selector(changeMapType:);
	
	dropButton.target = self; 
	dropButton.action = @selector(dropButtonAction:);
        
    pickupButton.target = self; 
	pickupButton.action = @selector(pickupButtonAction:);
}
-(void)viewDidAppear:(BOOL)animated{
    
    if (![AppModel sharedAppModel].loggedIn || [AppModel sharedAppModel].currentGame.gameId==0) {
        NSLog(@"DropOnMapViewController: Player is not logged in, don't refresh");
        return;
    }
    	
	[self refresh];		
}
- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"DropOnMapViewController: Stopping Refresh Timer");
	if (refreshTimer) {
		[refreshTimer invalidate];
		refreshTimer = nil;
	}
}
- (void) refresh {
	if (mapView) {
		NSLog(@"DropOnMapViewController: refresh requested");	
   
		//Zoom and Center
		if (tracking) [self zoomAndCenterMap];
        
	} else {
		NSLog(@"DropOnMapViewController: refresh requested but ignored, as mapview is nil");	
		
	}
}

-(void) zoomAndCenterMap {
	
	appSetNextRegionChange = YES;
	
	//Center the map on the player
	MKCoordinateRegion region = mapView.region;
	region.center = [AppModel sharedAppModel].playerLocation.coordinate;
	region.span = MKCoordinateSpanMake(INITIAL_SPAN, INITIAL_SPAN);
    
	[mapView setRegion:region animated:YES];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (IBAction)changeMapType: (id) sender {
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	switch (mapView.mapType) {
		case MKMapTypeStandard:
			mapView.mapType=MKMapTypeSatellite;
			break;
		case MKMapTypeSatellite:
			mapView.mapType=MKMapTypeHybrid;
			break;
		case MKMapTypeHybrid:
			mapView.mapType=MKMapTypeStandard;
			break;
	}
}
/*
- (IBAction)refreshButtonAction: (id) sender{
	NSLog(@"GPSViewController: Refresh Button Touched");
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	//resume auto centering
	tracking = YES;
    
	
	//Force a location update
	[appDelegate.myCLController.locationManager stopUpdatingLocation];
	[appDelegate.myCLController.locationManager startUpdatingLocation];
    
	//Rerfresh all contents
	[self refresh];
    
}
*/
-(void)pickupButtonAction:(id)sender{
    [[self.delegate note] setDropped:NO];
    //do server call to update dropped val of note
    //do server call to deleteLocation of Note
        Note *note = [[AppModel sharedAppModel] noteForNoteId:self.noteId playerListYesGameListNo:![AppModel sharedAppModel].isGameNoteList];
    [note setDropped:NO];
    [[AppServices sharedAppServices]deleteNoteLocationWithNoteId:self.noteId];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)dropButtonAction:(id)sender{
    [[AppServices sharedAppServices]updateServerDropNoteHere:self.noteId atCoordinate:self.myAnnotation.coordinate];
    [[self.delegate note] setDropped:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	//User must have moved the map. Turn off Tracking
	NSLog(@"GPSVC: regionDidChange delegate metohd fired");
    
	if (!appSetNextRegionChange) {
		NSLog(@"GPSVC: regionDidChange without appSetNextRegionChange, it must have been the user");
		tracking = NO;
	}
	
	appSetNextRegionChange = NO;
    
    
}

/*- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view {
	Location *location = ((Annotation*)view.annotation).location;
    if(view.annotation == aMapView.userLocation) return;
	NSLog(@"GPSViewController: didSelectAnnotationView for location: %@",location.name);
	
	
}*/

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
	if (oldState == MKAnnotationViewDragStateDragging) {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
		annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];		
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) {
		draggablePinView.annotation = annotation;
	} else {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
        
		if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) {
			// draggablePinView is DDAnnotationView on iOS 3.
		} else {
			// draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
		}
	}		
	
	return draggablePinView;
}
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
    if([mp isKindOfClass:[DDAnnotation class]]){
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
	[mv setRegion:region animated:YES];
	[mv selectAnnotation:mp animated:YES];
    }
}


@end

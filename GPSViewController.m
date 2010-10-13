//
//  GPSViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GPSViewController.h"
#import "AppModel.h"
#import "Location.h"
#import "Player.h"
#import "ARISAppDelegate.h"
#import "AnnotationView.h"
#import "Media.h"
#import "Annotation.h"
#import <UIKit/UIActionSheet.h>


static float INITIAL_SPAN = 0.001;

@implementation GPSViewController

@synthesize locations;
@synthesize mapView;
@synthesize tracking;
@synthesize mapTypeButton;
@synthesize playerTrackingButton;
@synthesize toolBar;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"MapViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"gps.png"];
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
		silenceNextServerUpdate = YES;
		tracking = YES;
		playerTrackingButton.style = UIBarButtonItemStyleDone;

		
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refresh) name:@"PlayerMoved" object:nil];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedLocationList" object:nil];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewLocationListReady" object:nil];
		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
		
	}
	
    return self;
}

- (void)silenceNextUpdate {
	silenceNextServerUpdate = YES;
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

- (IBAction)refreshButtonAction: (id) sender{
	NSLog(@"GPSViewController: Refresh Button Touched");
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	//resume auto centering
	tracking = YES;
	playerTrackingButton.style = UIBarButtonItemStyleDone;

	
	//Force a location update
	[appDelegate.myCLController.locationManager stopUpdatingLocation];
	[appDelegate.myCLController.locationManager startUpdatingLocation];

	//Rerfresh all contents
	[self refresh];

}
		
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"Begin Loading GPS View");
	mapView.showsUserLocation = YES;
	[mapView setDelegate:self];
	[self.view addSubview:mapView];
	NSLog(@"GPSViewController: Mapview inited and added to view");
	
	
	//Setup the buttons
	mapTypeButton.target = self; 
	mapTypeButton.action = @selector(changeMapType:);
	mapTypeButton.title = NSLocalizedString(@"MapTypeKey",@"");
	
	playerTrackingButton.target = self; 
	playerTrackingButton.action = @selector(refreshButtonAction:);
	playerTrackingButton.style = UIBarButtonItemStyleDone;

	
	//Force an update of the locations
	[appModel forceUpdateOnNextLocationListFetch];
	
	[self refresh];	
	
	

	NSLog(@"GPSViewController: View Loaded");
}

- (void)viewDidAppear:(BOOL)animated {
	[appModel updateServerMapViewed];
	
	[self refresh];		
	
	//remove any existing badge
	self.tabBarItem.badgeValue = nil;
	
	//create a time for automatic map refresh
	NSLog(@"GPSViewController: Starting Refresh Timer");
	if (refreshTimer != nil && [refreshTimer isValid]) [refreshTimer invalidate];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refresh) userInfo:nil repeats:YES];

	
	NSLog(@"GPSViewController: view did appear");
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"GPSViewController: Stopping Refresh Timer");
	if (refreshTimer) {
		[refreshTimer invalidate];
		refreshTimer = nil;
	}
}


// Updates the map to current data for player and locations from the server
- (void) refresh {
	if (mapView) {
		NSLog(@"GPSViewController: refresh requested");	
	
		if (appModel.loggedIn) [appModel fetchLocationList];
		[self showLoadingIndicator];

		//Zoom and Center
		if (tracking) [self zoomAndCenterMap];

	} else {
		NSLog(@"GPSViewController: refresh requested but ignored, as mapview is nil");	
		
	}
}

-(void) zoomAndCenterMap {
	
	appSetNextRegionChange = YES;
	
	//Center the map on the player
	MKCoordinateRegion region = mapView.region;
	region.center = appModel.playerLocation.coordinate;
	region.span = MKCoordinateSpanMake(INITIAL_SPAN, INITIAL_SPAN);

	[mapView setRegion:region animated:YES];
		
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
	[[self navigationItem] setRightBarButtonItem:nil];
}


- (void)refreshViewFromModel {
	if (mapView) {
		//only refresh if there's a mapview
		NSLog(@"GPSViewController: Refreshing view from model");
	
	
		//Add a badge if this is NOT the first time data has been loaded
		if (silenceNextServerUpdate == NO) {
			self.tabBarItem.badgeValue = @"!";
			
			//ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
			//[appDelegate playAudioAlert:@"mapChange" shouldVibrate:YES]; //this is a little annoying becasue it happens even when players move
			
		}
		else silenceNextServerUpdate = NO;
	
		//Blow away the old markers except for the player marker
		NSEnumerator *existingAnnotationsEnumerator = [[[mapView annotations] copy] objectEnumerator];
		NSObject <MKAnnotation> *annotation;
		while (annotation = [existingAnnotationsEnumerator nextObject]) {
			if (annotation != mapView.userLocation) [mapView removeAnnotation:annotation];
		}
	
		locations = appModel.locationList;
	
		//Add the freshly loaded locations from the notification
		for ( Location* location in locations ) {
			NSLog(@"GPSViewController: Adding location annotation for:%@ id:%d", location.name, location.locationId);
			if (location.hidden == YES) 
			{
				NSLog(@"No I'm not, because this location is hidden.");
				continue;
			}
			CLLocationCoordinate2D locationLatLong = location.location.coordinate;
			
			Annotation *annotation = [[Annotation alloc]initWithCoordinate:locationLatLong];
			annotation.location = location;
			
			
			annotation.title = location.name;
			if (location.kind == NearbyObjectItem && location.qty > 1) 
				annotation.subtitle = [NSString stringWithFormat:@"x %d",location.qty];
			annotation.iconMediaId = location.iconMediaId;
			annotation.kind = location.kind;

			[mapView addAnnotation:annotation];
			if (!mapView) {
				NSLog(@"GPSViewController: Just added an annotation to a null mapview!");
			}
			
			[annotation release];
		}
		
		//Add the freshly loaded players from the notification
		for ( Player *player in appModel.playerList ) {
			if (player.hidden == YES) continue;
			CLLocationCoordinate2D locationLatLong = player.location.coordinate;

			Annotation *aPlayer = [[Annotation alloc]initWithCoordinate:locationLatLong];
			aPlayer.title = player.name;
			[mapView addAnnotation:aPlayer];
			[aPlayer release];
		} 
	} else {
		NSLog(@"GPSViewController: Refresh requested but ignored, as mapview is nil.");
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[mapView release];
    [super dealloc];
}

-(UIImage *)addTitle:(NSString *)imageTitle quantity:(int)quantity toImage:(UIImage *)img {
	
	NSString *calloutString;
	if (quantity > 1) {
		calloutString = [NSString stringWithFormat:@"%@:%d",imageTitle, quantity];
	} else {
		calloutString = imageTitle;
	}
 	UIFont *myFont = [UIFont fontWithName:@"Arial" size:12];
	CGSize textSize = [calloutString sizeWithFont:myFont];
	CGRect textRect = CGRectMake(0, 0, textSize.width + 10, textSize.height);
	
	//callout path
	CGMutablePathRef calloutPath = CGPathCreateMutable();
	CGPoint pointerPoint = CGPointMake(textRect.origin.x + 0.6 * textRect.size.width,  textRect.origin.y + textRect.size.height + 5);
	CGPathMoveToPoint(calloutPath, NULL, textRect.origin.x, textRect.origin.y);
	CGPathAddLineToPoint(calloutPath, NULL, textRect.origin.x, textRect.origin.y + textRect.size.height);
	CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x - 5.0, textRect.origin.y + textRect.size.height);
	CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x, pointerPoint.y);
	CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x + 5.0, textRect.origin.y+ textRect.size.height);
	CGPathAddLineToPoint(calloutPath, NULL, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height);
	CGPathAddLineToPoint(calloutPath, NULL, textRect.origin.x + textRect.size.width, textRect.origin.y);
	CGPathAddLineToPoint(calloutPath, NULL, textRect.origin.x, textRect.origin.y);
	
	
	
	CGRect imageRect = CGRectMake(0, textSize.height + 10.0, img.size.width, img.size.height);
	CGRect backgroundRect = CGRectUnion(textRect, imageRect);
	if (backgroundRect.size.width > img.size.width) {
		imageRect.origin.x = (backgroundRect.size.width - img.size.width) / 2.0;
	}
	
	CGSize contextSize = backgroundRect.size;
	UIGraphicsBeginImageContext(contextSize);
	CGContextAddPath(UIGraphicsGetCurrentContext(), calloutPath);
	[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] set];
	CGContextFillPath(UIGraphicsGetCurrentContext());
	[[UIColor blackColor] set];
	CGContextAddPath(UIGraphicsGetCurrentContext(), calloutPath);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
	[img drawAtPoint:imageRect.origin];
	[calloutString drawInRect:textRect withFont:myFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
	CGPathRelease(calloutPath);
	UIGraphicsEndImageContext();
	
	return returnImage;
}



#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	//User must have moved the map. Turn off Tracking
	NSLog(@"GPSVC: regionDidChange delegate metohd fired");

	if (!appSetNextRegionChange) {
		NSLog(@"GPSVC: regionDidChange without appSetNextRegionChange, it must have been the user");
		tracking = NO;
		playerTrackingButton.style = UIBarButtonItemStyleBordered;
	}
	
	appSetNextRegionChange = NO;


}

- (MKAnnotationView *)mapView:(MKMapView *)myMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	NSLog(@"GPSViewController: In viewForAnnotation");

	
	//Player
	if (annotation == mapView.userLocation)
	{
		NSLog(@"GPSViewController: Getting the annotation view for the user's location");
		 return nil; //Let it do it's own thing
	}
	
	//Everything else
	else {
		NSLog(@"GPSViewController: Getting the annotation view for a game object: %@", annotation.title);
		AnnotationView *annotationView=[[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
		return annotationView;
	}
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	Location *location = ((Annotation*)view.annotation).location;
	NSLog(@"GPSViewController: didSelectAnnotationView for location: %@",location.name);
	
	//Set up buttons
	NSMutableArray *buttonTitles = [NSMutableArray arrayWithCapacity:1];
	int cancelButtonIndex = 0;
	if (location.allowsQuickTravel)	{
		[buttonTitles addObject: @"Quick Travel"];
		cancelButtonIndex = 1;
	}
	[buttonTitles addObject: @"Cancel"];
	
	
	
	
	//Create and Display Action Sheet
	UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:location.name 
															delegate:self 
												   cancelButtonTitle:nil 
											  destructiveButtonTitle:nil 
												   otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.cancelButtonIndex = cancelButtonIndex;
	
	for (NSString *title in buttonTitles) {
		[actionSheet addButtonWithTitle:title];
	}
	
	[actionSheet showInView:view];
	
	
	
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSLog(@"GPSViewController: action sheet button %d was clicked",buttonIndex);
	
	Annotation *currentAnnotation = [mapView.selectedAnnotations lastObject];
	
	if (buttonIndex == actionSheet.cancelButtonIndex) [mapView deselectAnnotation:currentAnnotation animated:YES]; 
	else [currentAnnotation.location display];

}



@end

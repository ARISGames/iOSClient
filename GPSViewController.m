//
//  GPSViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GPSViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Location.h"
#import "Player.h"
#import "ARISAppDelegate.h"
#import "AnnotationView.h"
#import "Media.h"
#import "Annotation.h"
#import <UIKit/UIActionSheet.h>
#import "NoteDetailsViewController.h"
#import "NoteEditorViewController.h"

static float INITIAL_SPAN = 0.001;
@implementation GPSViewController

@synthesize locations, route;
@synthesize mapView;
@synthesize tracking,mapTrace;
@synthesize mapTypeButton;
@synthesize playerTrackingButton;
@synthesize toolBar,addMediaButton;
@synthesize playerButton;
@synthesize overlay;
@synthesize overlayArray;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"MapViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"103-map"];
        
		tracking = YES;
		playerTrackingButton.style = UIBarButtonItemStyleDone;
        route = [[NSMutableArray alloc]initWithCapacity:10];
		
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost" object:nil];
        
		[dispatcher addObserver:self selector:@selector(playerMoved) name:@"PlayerMoved" object:nil];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedLocationList" object:nil];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewLocationListReady" object:nil];
		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
        [dispatcher addObserver:self selector:@selector(updateOverlays) name:@"NewOverlayListReady" object:nil];
	}
    return self;
}

- (void)silenceNextUpdate {
	silenceNextServerUpdateCount++;
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

- (IBAction)refreshButtonAction{
	NSLog(@"GPSViewController: Refresh Button Touched");
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	//resume auto centering
	tracking = YES;
	playerTrackingButton.style = UIBarButtonItemStyleDone;
    
	
	//Force a location update
	[[[MyCLController sharedMyCLController] locationManager] stopUpdatingLocation];
	[[[MyCLController sharedMyCLController]locationManager] startUpdatingLocation];
    
	//Rerfresh all contents
	[self refresh];
}

-(void)playerButtonTouch{
    [AppModel sharedAppModel].hidePlayers = ![AppModel sharedAppModel].hidePlayers;
    if([AppModel sharedAppModel].hidePlayers){
        [playerButton setStyle:UIBarButtonItemStyleBordered];
        if (mapView) {
            NSEnumerator *existingAnnotationsEnumerator = [[[mapView annotations] copy] objectEnumerator];
            Annotation *annotation;
            while (annotation = [existingAnnotationsEnumerator nextObject]) {
                if (annotation != mapView.userLocation && annotation.kind == NearbyObjectPlayer) [mapView removeAnnotation:annotation];
            }
        }
    }
    else{
        [playerButton setStyle:UIBarButtonItemStyleDone];
    }
	[[[MyCLController sharedMyCLController] locationManager] stopUpdatingLocation];
	[[[MyCLController sharedMyCLController]locationManager] startUpdatingLocation];
    
	//Refresh all contents
    tracking = NO;
	[self refresh];
}

- (IBAction)addMediaButtonAction: (id) sender{
    NoteEditorViewController *noteVC = [[NoteEditorViewController alloc] initWithNibName:@"NoteEditorViewController" bundle:nil];
    noteVC.delegate = self;
    [self.navigationController pushViewController:noteVC animated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"Begin Loading GPS View");
	mapView.showsUserLocation = YES;
	[mapView setDelegate:self];
    mapView.mapType=MKMapTypeHybrid;
	[self.view addSubview:mapView];
	NSLog(@"GPSViewController: Mapview inited and added to view");
	
	//Setup the buttons
	mapTypeButton.target = self;
	mapTypeButton.action = @selector(changeMapType:);
	mapTypeButton.title = NSLocalizedString(@"MapTypeKey",@"");
	
	playerTrackingButton.target = self;
	playerTrackingButton.action = @selector(refreshButtonAction);
	playerTrackingButton.style = UIBarButtonItemStyleDone;
    
    addMediaButton.target = self;
    addMediaButton.action = @selector(addMediaButtonAction:);
	
    
	//Force an update of the locations
	//[[AppServices sharedAppServices] forceUpdateOnNextLocationListFetch];
    
    [self updateOverlays];
    [self refresh];
    
	NSLog(@"GPSViewController: View Loaded");
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)ovrlay
{
    
    TileOverlayView *view = [[TileOverlayView alloc] initWithOverlay:ovrlay];
    Overlay *ovrly =  [[AppModel sharedAppModel].overlayList objectAtIndex:0]; //GWS: need to fix this?
    //view.tileAlpha =  ovrly.alpha;
    view.tileAlpha = 1;
    
    [AppModel sharedAppModel].overlayIsVisible = true;
    
    return view;
}

- (void) updateOverlays{
    
    
    // remove all overlays
    [overlayArray removeAllObjects];
    [mapView removeOverlays:[mapView overlays]];
    
    
    // add all current overlays to display
    int iOverlays = [[AppModel sharedAppModel].overlayList count];
    
    for (int i = 0; i < iOverlays; i++) {
        overlay = [[TileOverlay alloc] initWithIndex: i];
        if (overlay != NULL) {
            [overlayArray addObject:overlay];
            [mapView addOverlay:overlay];
        }
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"GPSViewController: view did appear");
    
    
    if (![AppModel sharedAppModel].loggedIn || [AppModel sharedAppModel].currentGame.gameId==0) {
        NSLog(@"GPSViewController: Player is not logged in, don't refresh");
        return;
    }
    
	[[AppServices sharedAppServices] updateServerMapViewed];
	
	[self refresh];
	
	self.tabBarItem.badgeValue = nil;
	newItemsSinceLastView = 0;
	silenceNextServerUpdateCount = 0;
    [AppModel sharedAppModel].hidePlayers = ![AppModel sharedAppModel].hidePlayers;
    [self playerButtonTouch];
	//create a time for automatic map refresh
	NSLog(@"GPSViewController: Starting Refresh Timer");
	if (refreshTimer != nil && [refreshTimer isValid]) [refreshTimer invalidate];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
}

-(void)dismissTutorial{
	[[RootViewController sharedRootViewController].tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindMapTab];
}

// Updates the map to current data for player and locations from the server
- (void) refresh {
    if([AppModel sharedAppModel].inGame){
        if (mapView) {
            NSLog(@"GPSViewController: refresh requested");
            
            if ([AppModel sharedAppModel].loggedIn && ([AppModel sharedAppModel].currentGame.gameId != 0 && [AppModel sharedAppModel].playerId != 0)) {
                [[AppServices sharedAppServices] fetchLocationList];
                [[AppServices sharedAppServices] fetchOverlayListAsynchronously:YES];
                [self showLoadingIndicator];
            }
            
            //Zoom and Center
            if (tracking) [self zoomAndCenterMap];
            /* if(mapTrace){
             [self.route addObject:[AppModel sharedAppModel].playerLocation];
             MKPolyline *line = [[MKPolyline alloc]init];
             line
             
             }*/
            
        }
        else {
            NSLog(@"GPSViewController: refresh requested but ignored, as mapview is nil");
            
        }
    }
}

- (void) playerMoved {
    if([AppModel sharedAppModel].inGame) {
        if (mapView && [AppModel sharedAppModel].loggedIn && [AppModel sharedAppModel].currentGame.gameId != 0 && [AppModel sharedAppModel].playerId != 0) {
            NSLog(@"GPSViewController: player moved");
            
            //Zoom and Center
            if (tracking) [self zoomAndCenterMap];
        }
        else {
            NSLog(@"GPSViewController: player moved, but mapview is nil");
            
        }
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

-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator =
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator{
	[[self navigationItem] setRightBarButtonItem:nil];
	NSLog(@"GPSViewController: removeLoadingIndicator: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
}


- (void)refreshViewFromModel {
    if (mapView) {
        NSMutableArray *newLocationsArray;
        Annotation *annotation;
        NSLog(@"GPSViewController: Refreshing view from model");
        
        NSLog(@"GPSViewController: refreshViewFromModel: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
        
        if (silenceNextServerUpdateCount < 1) {
            //Check if anything is new since last time or item has disappeared
            newItemsSinceLastView = 0;
            newLocationsArray = [[NSMutableArray alloc] initWithArray:[AppModel sharedAppModel].locationList];
            for (int i = 0; i < [[mapView annotations] count]; i++) {
                BOOL match = NO;
                NSObject <MKAnnotation>  *testAnnotation = [[mapView annotations] objectAtIndex:i];
                if([testAnnotation respondsToSelector:@selector(title)] && ![testAnnotation.title isEqualToString:@"Current Location"]){
                    annotation = (Annotation *)testAnnotation;
                    if([[RootViewController sharedRootViewController].tabBarController.selectedViewController.title isEqualToString:@"Map"] &&[annotation.location respondsToSelector:@selector(hasBeenViewed)]) {
                        annotation.location.hasBeenViewed = YES;
                    }
                    else{
                        if([annotation.location respondsToSelector:@selector(hasBeenViewed)]) {
                            if(!annotation.location.hasBeenViewed){
                                newItemsSinceLastView++;
                            }
                        }
                    }
                    for (int j = 0; j < [newLocationsArray count]; j++) {
                        Location *newLocation = [newLocationsArray objectAtIndex:j];
                        if ([annotation.location compareTo:newLocation]){
                            [newLocationsArray removeObjectAtIndex:j];
                            j--;
                            match = YES;
                        }
                    }
                    if(!match){
                        [mapView removeAnnotation:annotation];
                        i--;
                    }
                }
            }
            
            if (newItemsSinceLastView > 0 && ![[RootViewController sharedRootViewController].tabBarController.selectedViewController.title isEqualToString:@"Map"])
            {
                self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newItemsSinceLastView];
                if (![AppModel sharedAppModel].hasSeenMapTabTutorial)
                {
                    //Put up the tutorial tab
                    [[RootViewController sharedRootViewController].tutorialViewController showTutorialPopupPointingToTabForViewController:self.navigationController
                                                                                                                                     type:tutorialPopupKindMapTab
                                                                                                                                    title:@"New GPS Location"
                                                                                                                                  message:@"You have a new place of interest on your GPS! Touch below to view the Map."];
                    [AppModel sharedAppModel].hasSeenMapTabTutorial = YES;
                    [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
                }
            }
            else{
                newItemsSinceLastView = 0;
                self.tabBarItem.badgeValue = nil;
            }
        }
        
        self.locations = [AppModel sharedAppModel].locationList;
        
		//Add the freshly loaded locations from the notification
		for ( Location* location in newLocationsArray ) {
			NSLog(@"GPSViewController: Adding location annotation for:%@ id:%d", location.name, location.locationId);
			if (location.hidden == YES || (location.kind == NearbyObjectPlayer && [AppModel sharedAppModel].hidePlayers))
			{
				NSLog(@"No I'm not, because this location is hidden.");
				continue;
			}
			CLLocationCoordinate2D locationLatLong = location.location.coordinate;
			
			Annotation *annotation = [[Annotation alloc]initWithCoordinate:locationLatLong];
			annotation.location = location;
			annotation.title = location.name;
            annotation.kind = location.kind;
			if (location.kind == NearbyObjectItem && location.qty > 1 && annotation.title != nil)
				annotation.subtitle = [NSString stringWithFormat:@"x %d",location.qty];
			annotation.iconMediaId = location.iconMediaId;
            
			[mapView addAnnotation:annotation];
            
			if (!mapView) {
				NSLog(@"GPSViewController: Just added an annotation to a null mapview!");
			}
        }
     	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
    
    NSLog(@"GPSViewController: Releasing Memory");
    //Blow away the old markers except for the player marker
    NSEnumerator *existingAnnotationsEnumerator = [[[mapView annotations] copy] objectEnumerator];
    NSObject <MKAnnotation> *annotation;
    while (annotation = [existingAnnotationsEnumerator nextObject]) {
        if (annotation != mapView.userLocation) [mapView removeAnnotation:annotation];
    }
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}


-(UIImage *)addTitle:(NSString *)imageTitle quantity:(int)quantity toImage:(UIImage *)img {
    //I don't think this ever gets called... Might be depricated in favor of AnnotationView.drawRect. Then again, might not. just FYI. Phil 7/6/12
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

- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view {
	Location *location = ((Annotation*)view.annotation).location;
    if(view.annotation == aMapView.userLocation) return;
	NSLog(@"GPSViewController: didSelectAnnotationView for location: %@",location.name);
	
	//Set up buttons
	NSMutableArray *buttonTitles = [NSMutableArray arrayWithCapacity:1];
	int cancelButtonIndex = 0;
	if (location.allowsQuickTravel)	{
		[buttonTitles addObject: NSLocalizedString(@"GPSViewQuickTravelKey", @"")];
		cancelButtonIndex = 1;
	}
	[buttonTitles addObject: NSLocalizedString(@"CancelKey", @"")];
	
	
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


- (void)mapView:(MKMapView *)mV didAddAnnotationViews:(NSArray *)views {
    for (AnnotationView *aView in views) {
        // prepare drop animation
        CGRect endFrame = aView.frame;
        aView.frame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y - 230.0, aView.frame.size.width, aView.frame.size.height);
        [UIView animateWithDuration:0.45 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{[aView setFrame: endFrame];} completion:^(BOOL finished) {}];
    }
}

- (double)getZoomLevel:(MKMapView *) mV {
    // Helper function to get the current zoom level of the mapView.
    double MERCATOR_RADIUS = 85445659.44705395;
    double MAX_GOOGLE_LEVELS  = 20;
    CLLocationDegrees longitudeDelta = mV.region.span.longitudeDelta;
    CGFloat mapWidthInPixels = mV.bounds.size.width;
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = MAX_GOOGLE_LEVELS - log2( zoomScale );
    if ( zoomer < 0 ) zoomer = 0;
    return zoomer;
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSLog(@"GPSViewController: action sheet button %d was clicked",buttonIndex);
	
	Annotation *currentAnnotation = [mapView.selectedAnnotations lastObject];
	
	if (buttonIndex == actionSheet.cancelButtonIndex) [mapView deselectAnnotation:currentAnnotation animated:YES];
	else {
        [currentAnnotation.location display];
        [mapView deselectAnnotation:currentAnnotation animated:YES];
    }
}


@end

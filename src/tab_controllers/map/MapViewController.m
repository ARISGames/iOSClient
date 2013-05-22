//
//  MapViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIActionSheet.h>
#import "MapViewController.h"
#import "StateControllerProtocol.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Location.h"
#import "Player.h"
#import "ARISAppDelegate.h"
#import "AnnotationView.h"
#import "Media.h"
#import "NoteDetailsViewController.h"
#import "NoteEditorViewController.h"

#define INITIAL_SPAN 0.001f

@interface MapViewController()
{
    id<MapViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
    NSMutableArray *locationsToAdd;
    NSMutableArray *locationsToRemove;
}
@end

@implementation MapViewController

@synthesize locations, route;
@synthesize mapView;
@synthesize tracking,mapTrace;
@synthesize mapTypeButton;
@synthesize playerTrackingButton;
@synthesize toolBar;
@synthesize playerButton;
@synthesize overlay;
@synthesize overlayArray;

- (id) initWithDelegate:(id<MapViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithNibName:@"MapViewController" bundle:nil])
    {
        delegate = d;
        
        self.title = NSLocalizedString(@"MapViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"103-map"];
        
		tracking = YES;
		playerTrackingButton.style = UIBarButtonItemStyleDone;
        route = [[NSMutableArray alloc]initWithCapacity:10];
        
        locationsToAdd    = [[NSMutableArray alloc] initWithCapacity:10];
        locationsToRemove = [[NSMutableArray alloc] initWithCapacity:10];
		
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator)     name:@"ConnectionLost"                               object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerMoved)                name:@"PlayerMoved"                                  object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator)     name:@"ReceivedLocationList"                         object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOverlays)             name:@"NewOverlayListReady"                          object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLocationsToNewQueue:)    name:@"NewlyAvailableLocationsAvailable"             object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLocationsToRemoveQueue:) name:@"NewlyUnavailableLocationsAvailable"           object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge)             name:@"NewlyChangedLocationsGameNotificationSent"    object:nil];
	}
    return self;
}

- (IBAction) changeMapType:(id)sender
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	switch (mapView.mapType)
    {
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

- (IBAction) refreshButtonAction
{
	NSLog(@"MapViewController: Refresh Button Touched");
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	tracking = YES;
	playerTrackingButton.style = UIBarButtonItemStyleDone;
    
	[[[MyCLController sharedMyCLController] locationManager] stopUpdatingLocation];
	[[[MyCLController sharedMyCLController] locationManager] startUpdatingLocation];
    
	[self refresh];
}

- (void)playerButtonTouch
{
    [AppModel sharedAppModel].hidePlayers = ![AppModel sharedAppModel].hidePlayers;
    [self hideOrShowPlayerLocations];
}

- (void)hideOrShowPlayerLocations
{
    if([AppModel sharedAppModel].hidePlayers)
    {
        [playerButton setStyle:UIBarButtonItemStyleBordered];
        if (mapView)
        {
            NSEnumerator *existingAnnotationsEnumerator = [[mapView annotations] objectEnumerator];
            id<MKAnnotation> annotation;
            while(annotation = [existingAnnotationsEnumerator nextObject])
            {
                if (annotation != mapView.userLocation)
                    [mapView removeAnnotation:annotation];
            }
        }
    }
    else
        [playerButton setStyle:UIBarButtonItemStyleDone];
    
	[[[MyCLController sharedMyCLController] locationManager] stopUpdatingLocation];
	[[[MyCLController sharedMyCLController] locationManager] startUpdatingLocation];
    
    tracking = NO;
	[self refresh];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	[mapView setDelegate:self];
    [self.view addSubview:mapView];
	
	mapTypeButton.target = self;
	mapTypeButton.action = @selector(changeMapType:);
	mapTypeButton.title = NSLocalizedString(@"MapTypeKey",@"");
	
	playerTrackingButton.target = self;
	playerTrackingButton.action = @selector(refreshButtonAction);
	playerTrackingButton.style = UIBarButtonItemStyleDone;
	
    [self updateOverlays];
    [self refresh];
}

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id)ovrlay
{
    TileOverlayView *view = [[TileOverlayView alloc] initWithOverlay:ovrlay];
    view.tileAlpha = 1;
    
    [AppModel sharedAppModel].overlayIsVisible = true;
    
    return view;
}

- (void) updateOverlays
{
    [overlayArray removeAllObjects];
    [mapView removeOverlays:[mapView overlays]];
    
    for(int i = 0; i < [[AppModel sharedAppModel].overlayList count]; i++)
    {
        overlay = [[TileOverlay alloc] initWithIndex: i];
        if(overlay != NULL)
        {
            [overlayArray addObject:overlay];
            [mapView addOverlay:overlay];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    if     ([[AppModel sharedAppModel].currentGame.mapType isEqualToString:@"SATELLITE"]) mapView.mapType = MKMapTypeSatellite;
    else if([[AppModel sharedAppModel].currentGame.mapType isEqualToString:@"HYBRID"])    mapView.mapType = MKMapTypeHybrid;
    else                                                                                  mapView.mapType = MKMapTypeStandard;
    
    if([AppModel sharedAppModel].currentGame.showPlayerLocation) [mapView setShowsUserLocation:YES];
    else [mapView setShowsUserLocation:NO];
    
    [self hideOrShowPlayerLocations];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	[[AppServices sharedAppServices] updateServerMapViewed];
	
    [self refreshViewFromModel];
	[self refresh];
	
	if (refreshTimer && [refreshTimer isValid]) [refreshTimer invalidate];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
}

- (void) dismissTutorial
{
    if(delegate) [delegate dismissTutorial];
}

- (void) refresh
{
    if (mapView)
    {
        if ([AppModel sharedAppModel].player && ([AppModel sharedAppModel].currentGame.gameId != 0 && [AppModel sharedAppModel].player.playerId != 0))
        {
            [[AppServices sharedAppServices] fetchPlayerLocationList];
            [[AppServices sharedAppServices] fetchPlayerOverlayList];
            [self showLoadingIndicator];
        }
            
        if (tracking) [self zoomAndCenterMap];
    }
}

- (void) playerMoved
{
    if (mapView && tracking && [AppModel sharedAppModel].player && [AppModel sharedAppModel].currentGame.gameId != 0 && [AppModel sharedAppModel].player.playerId != 0)
        [self zoomAndCenterMap];
}

- (void) zoomAndCenterMap
{	
	appSetNextRegionChange = YES;
	
	//Center the map on the player
	MKCoordinateRegion region = mapView.region;
	region.center = [AppModel sharedAppModel].player.location.coordinate;
	region.span = MKCoordinateSpanMake(INITIAL_SPAN, INITIAL_SPAN);
    
	[mapView setRegion:region animated:YES];
}

- (void) showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[activityIndicator startAnimating];
}

- (void) removeLoadingIndicator
{
	[[self navigationItem] setRightBarButtonItem:nil];
}

- (void) addLocationsToNewQueue:(NSNotification *)notification
{
    //Quickly make sure we're not re-adding any info (let the 'newly' added ones take over)
    NSArray *newLocations = (NSArray *)[notification.userInfo objectForKey:@"newlyAvailableLocations"];
    for(int i = 0; i < [newLocations count]; i++)
    {
        for(int j = 0; j < [locationsToAdd count]; j++)
        {
            if([((Location *)[newLocations objectAtIndex:i]) compareTo:((Location *)[locationsToAdd objectAtIndex:j])])
                [locationsToAdd removeObjectAtIndex:j];
        }
    }
    [locationsToAdd addObjectsFromArray:newLocations];
    
    if(self.tabBarController.tabBar.selectedItem == self.tabBarItem) [self refreshViewFromModel];
}

- (void) addLocationsToRemoveQueue:(NSNotification *)notification
{
    //Quickly make sure we're not re-adding any info (let the 'newly' added ones take over)
    NSArray *lostLocations = (NSArray *)[notification.userInfo objectForKey:@"newlyUnavailableLocations"];
    for(int i = 0; i < [lostLocations count]; i++)
    {
        for(int j = 0; j < [locationsToRemove count]; j++)
        {
            if([((Location *)[lostLocations objectAtIndex:i]) compareTo:((Location *)[locationsToRemove objectAtIndex:j])])
                [locationsToRemove removeObjectAtIndex:j];
        }
    }
    [locationsToRemove addObjectsFromArray:lostLocations];
    
    //If told to remove something that is in queue to add, remove takes precedence 
    for(int i = 0; i < [locationsToRemove count]; i++)
    {
        for(int j = 0; j < [locationsToAdd count]; j++)
        {
            if([((Location *)[locationsToRemove objectAtIndex:i]) compareTo:((Location *)[locationsToAdd objectAtIndex:j])])
                [locationsToAdd removeObjectAtIndex:j];
        }
    }
    
    if(self.tabBarController.tabBar.selectedItem == self.tabBarItem) [self refreshViewFromModel];
}

- (void)refreshViewFromModel
{
    if(!mapView) return;
    
    //Remove old locations first
    id<MKAnnotation> annotation;
    for (int i = 0; i < [[mapView annotations] count]; i++)
    {
        if(![[[mapView annotations] objectAtIndex:i] isKindOfClass:[Location class]]) continue;
        annotation = [[mapView annotations] objectAtIndex:i];
        for(int j = 0; j < [locationsToRemove count]; j++)
        {
            if([(Location *)annotation compareTo:((Location *)[locationsToRemove objectAtIndex:j])])
            {
                [mapView removeAnnotation:annotation];
                i--;
            }
        }
    }
    [locationsToRemove removeAllObjects];
    
    //Add new locations second
    Location *tmpLocation;
    for (int i = 0; i < [locationsToAdd count]; i++)
    {
        tmpLocation = (Location *)[locationsToAdd objectAtIndex:i];
        if(tmpLocation.hidden == NO && !(tmpLocation.gameObject.type == GameObjectPlayer && [AppModel sharedAppModel].hidePlayers))
            [mapView addAnnotation:tmpLocation];
    }
    [locationsToAdd removeAllObjects];
    
    [delegate showTutorialPopupPointingToTabForViewController:self title:@"New GPS Location" message:@"You have a new place of interest on your GPS! Touch below to view the Map."];
    
    [AppModel sharedAppModel].hasSeenMapTabTutorial = YES;
    [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	if (!appSetNextRegionChange)
    {
		tracking = NO;
		playerTrackingButton.style = UIBarButtonItemStyleBordered;
	}
	
	appSetNextRegionChange = NO;
}

- (MKAnnotationView *)mapView:(MKMapView *)myMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation == mapView.userLocation)
        return nil;
    else
        return [[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
}

- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if(view.annotation == aMapView.userLocation) return;
    Location *location = (Location *)view.annotation;

	NSMutableArray *buttonTitles = [NSMutableArray arrayWithCapacity:1];
	int cancelButtonIndex = 0;
	if (location.allowsQuickTravel)
    {
		[buttonTitles addObject: NSLocalizedString(@"GPSViewQuickTravelKey", @"")];
		cancelButtonIndex = 1;
	}
	[buttonTitles addObject: NSLocalizedString(@"CancelKey", @"")];
	
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:location.name
															delegate:self
												   cancelButtonTitle:nil
											  destructiveButtonTitle:nil
												   otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.cancelButtonIndex = cancelButtonIndex;
	
	for (NSString *title in buttonTitles)
		[actionSheet addButtonWithTitle:title];
	
	[actionSheet showInView:view];
}


- (void)mapView:(MKMapView *)mV didAddAnnotationViews:(NSArray *)views
{
    for (AnnotationView *aView in views)
    {
        //Drop animation
        CGRect endFrame = aView.frame;
        aView.frame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y - 230.0, aView.frame.size.width, aView.frame.size.height);
        [UIView animateWithDuration:0.45 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{[aView setFrame: endFrame];} completion:^(BOOL finished) {}];
    }
}

- (double)getZoomLevel:(MKMapView *)mV
{
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	id<MKAnnotation> currentAnnotation = [mapView.selectedAnnotations lastObject];
	
	if (buttonIndex == actionSheet.cancelButtonIndex)
        [mapView deselectAnnotation:currentAnnotation animated:YES];
	else
    {
        [delegate displayGameObject:((Location *)currentAnnotation).gameObject fromSource:self];
        [mapView deselectAnnotation:currentAnnotation animated:YES];
    }
}

@end

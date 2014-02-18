//
//  MapViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ARISTemplate.h"
#import "AppModel.h"
#import "Location.h"
#import "TileOverlay.h"
#import "TileOverlayView.h"
#import "MapViewController.h"
#import "StateControllerProtocol.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Location.h"
#import "Player.h"
#import "ARISAppDelegate.h"
#import "AnnotationView.h"
#import "Media.h"

#import "CrumbPath.h"
#import "CrumbPathView.h"

#import "MapHUD.h"

@interface MapViewController() <MKMapViewDelegate, MapHUDDelegate, StateControllerProtocol>
{
    NSMutableArray *locations;
    NSMutableArray *locationsToAdd;
    NSMutableArray *locationsToRemove;
    NSMutableArray *overlayArray;
    
    BOOL tracking;
    BOOL appSetNextRegionChange;
    BOOL isViewLoaded;

    MapHUD *hud;
    BOOL annotationPressed;
    MKMapView *mapView;
    
    UIBarButtonItem *mapTypeButton;
    UIBarButtonItem *playerButton;
    UIBarButtonItem *playerTrackingButton;
    
    UIButton *centerButton;
    UIButton *fitToAnnotationButton;
    
    CrumbPath *crumbs;
    CrumbPathView *crumbView;

    NSTimer *refreshTimer;

    id<MKAnnotation> currentAnnotation; //PHIL HATES this...
    id<MapViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@end

@implementation MapViewController

- (id) initWithDelegate:(id<MapViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"GPS";
        self.tabIconName = @"map";
        
        delegate = d;
        
        tracking = YES;
        isViewLoaded = NO;
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

- (void) loadView
{
    [super loadView];
    
    mapView = [[MKMapView alloc] init];
	mapView.delegate = self;
    
    if     ([[AppModel sharedAppModel].currentGame.mapType isEqualToString:@"SATELLITE"]) mapView.mapType = MKMapTypeSatellite;
    else if([[AppModel sharedAppModel].currentGame.mapType isEqualToString:@"HYBRID"])    mapView.mapType = MKMapTypeHybrid;
    else                                                                                  mapView.mapType = MKMapTypeStandard;
    

    centerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [centerButton addTarget:self action:@selector(zoomAndCenterMap) forControlEvents:UIControlEventTouchDown];
    [centerButton setImage:[UIImage imageNamed:@"74-location-white.png"] forState:UIControlStateNormal];
    
    fitToAnnotationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fitToAnnotationButton addTarget:self action:@selector(zoomToFitAnnotations) forControlEvents:UIControlEventTouchDown];
    [fitToAnnotationButton setImage:[UIImage imageNamed:@"246-route.png"] forState:UIControlStateNormal];
    
    [self.view addSubview:mapView];
    [self.view addSubview:centerButton];
    [self.view addSubview:fitToAnnotationButton];
    
    isViewLoaded = YES;
    
    //make the navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    [self updateOverlays];
    [self refresh];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    mapView.frame = self.view.bounds;
    centerButton.frame = CGRectMake(self.view.bounds.size.width - 60, self.view.bounds.size.height - 40, 20, 20);
    fitToAnnotationButton.frame = CGRectMake(self.view.bounds.size.width - 30, self.view.bounds.size.height - 40, 20, 20);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
	
	if(refreshTimer && [refreshTimer isValid]) [refreshTimer invalidate];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
}

- (void) changeMapType:(id)sender
{
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];

    switch(mapView.mapType)
    {
        case MKMapTypeStandard:  mapView.mapType = MKMapTypeSatellite; break;
        case MKMapTypeSatellite: mapView.mapType = MKMapTypeHybrid;    break;
        case MKMapTypeHybrid:    mapView.mapType = MKMapTypeStandard;  break;
    }
}

- (void) refreshButtonAction
{
	tracking = YES;
	[[[MyCLController sharedMyCLController] locationManager] stopUpdatingLocation];
	[[[MyCLController sharedMyCLController] locationManager] startUpdatingLocation];
    
	[self refresh];
}

- (void) playerButtonTouch
{
    [AppModel sharedAppModel].hidePlayers = ![AppModel sharedAppModel].hidePlayers;
    [self hideOrShowPlayerLocations];
}

- (void) hideOrShowPlayerLocations
{
    if([AppModel sharedAppModel].hidePlayers)
    {
        if(mapView)
        {
            NSEnumerator *existingAnnotationsEnumerator = [[mapView annotations] objectEnumerator];
            NSObject<MKAnnotation> *annotation;
            while(annotation = [existingAnnotationsEnumerator nextObject])
            {
                if(annotation != mapView.userLocation && [annotation isKindOfClass:[Location class]] && [((Location *)annotation).gameObject type] == GameObjectPlayer)
                    [mapView removeAnnotation:annotation];
            }
        }
    }
    else

    [[[MyCLController sharedMyCLController] locationManager] stopUpdatingLocation];
    [[[MyCLController sharedMyCLController] locationManager] startUpdatingLocation];

    tracking = NO;
    [self refresh];
}

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    if([overlay isKindOfClass:[CrumbPath class]])
    {
        if(!crumbView) crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
        return crumbView;
    }
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor ARISColorLightBlue] colorWithAlphaComponent:0.4];
        //circleView.fillColor = [[UIColor ARISColorLightBlue] colorWithAlphaComponent:0.0];
        circleView.opaque = NO;
        return circleView;
    }
    return nil;
    /*
    TileOverlayView *view = [[TileOverlayView alloc] initWithOverlay:overlay];
    //view.tileAlpha = 1;
    
    [AppModel sharedAppModel].overlayIsVisible = true;
    
    return view;
     */
}

- (void) updateOverlays
{
    /*
    [overlayArray removeAllObjects];
    [mapView removeOverlays:[mapView overlays]];
    
    for(int i = 0; i < [[AppModel sharedAppModel].overlayList count]; i++)
    {
        TileOverlay *overlay = [[TileOverlay alloc] initWithIndex: i];
        if(overlay != NULL)
        {
            [overlayArray addObject:overlay];
            [mapView addOverlay:overlay];
        }
    }
     */
}

- (void) refresh
{
    if(mapView)
    {
        if([AppModel sharedAppModel].player && ([AppModel sharedAppModel].currentGame.gameId != 0 && [AppModel sharedAppModel].player.playerId != 0))
        {
            [[AppServices sharedAppServices] fetchPlayerLocationList];
            [[AppServices sharedAppServices] fetchPlayerOverlayList];
            [self showLoadingIndicator];
        }
        if(tracking) [self zoomAndCenterMap];
    }
}

- (void) playerMoved
{
    if(!crumbs)
    {
        crumbs = [[CrumbPath alloc] initWithCenterCoordinate:[AppModel sharedAppModel].player.location.coordinate];
        [mapView addOverlay:crumbs];
    }
    else [crumbs addCoordinate:[AppModel sharedAppModel].player.location.coordinate]; 
    [crumbView setNeedsDisplay];
    
    if(mapView && tracking && [AppModel sharedAppModel].player && [AppModel sharedAppModel].currentGame.gameId != 0 && [AppModel sharedAppModel].player.playerId != 0)
        [self zoomAndCenterMap];
}

- (void) zoomAndCenterMap
{
	appSetNextRegionChange = YES;
	
	//Center the map on the player
	MKCoordinateRegion region = mapView.region;
	region.center = [AppModel sharedAppModel].player.location.coordinate;
	region.span = MKCoordinateSpanMake(0.001f, 0.001f);
    
	[mapView setRegion:region animated:YES];
}

-(void)zoomToFitAnnotations
{
    if([mapView.annotations count] == 0){
        return;
    }
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (Location *annotationLocation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotationLocation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotationLocation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotationLocation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotationLocation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

- (void) showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator startAnimating];
}

- (void) removeLoadingIndicator
{
	[self navigationItem].rightBarButtonItem = nil;
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
    
    if(isViewLoaded && self.view.window) [self refreshViewFromModel];
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
    
    if(isViewLoaded && self.view.window) [self refreshViewFromModel];
}

- (void) refreshViewFromModel
{
    if(!mapView) return;
    
    //Remove old locations first
    id<MKAnnotation> annotation;
    Location *loc;
    for(int i = 0; i < [[mapView annotations] count]; i++)
    {
        if(![[[mapView annotations] objectAtIndex:i] isKindOfClass:[Location class]]) continue;
        annotation = [[mapView annotations] objectAtIndex:i];
        loc = (Location *)annotation; 
        if(loc.gameObject.type == GameObjectItem) ((Item *)loc.gameObject).qty = loc.qty;  
        for(int j = 0; j < [locationsToRemove count]; j++)
        {
            if([loc compareTo:((Location *)[locationsToRemove objectAtIndex:j])])
            {
                if(loc.nearbyOverlay) [mapView removeOverlay:loc.nearbyOverlay]; 
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
        {
            if(tmpLocation.nearbyOverlay) [mapView addOverlay:tmpLocation.nearbyOverlay];
            [mapView addAnnotation:tmpLocation];
        }
    }
    [locationsToAdd removeAllObjects];
}

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if(!appSetNextRegionChange)
    {
        tracking = NO;
    }

    appSetNextRegionChange = NO;
}

- (MKAnnotationView *) mapView:(MKMapView *)myMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if(annotation == mapView.userLocation) return nil;
    else return [[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
}

- (void) mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view
{
    annotationPressed = YES;
    [self displayHUDWithLocation:(Location *)view.annotation andAnnotation:view];
}

- (void) displayHUDWithLocation:(Location *)location andAnnotation:(MKAnnotationView *)annotation
{
    CGFloat navAndStatusBar = 64;
    CGRect frame = CGRectMake(0, (navAndStatusBar + ((self.view.bounds.size.height-navAndStatusBar) * .75)), self.view.bounds.size.width, ((self.view.bounds.size.height-navAndStatusBar) * .25));
    if(!hud) hud = [[MapHUD alloc] initWithDelegate:self withFrame:frame];
    [self.view addSubview:hud.view];
    [hud setLocation:location withAnnotation:annotation];
    
    //re-add the zoom in button and zoom to fit button
    [centerButton removeFromSuperview];
    [centerButton setAlpha:0.0];
    [self.view addSubview:centerButton];
    
    [fitToAnnotationButton removeFromSuperview];
    [fitToAnnotationButton setAlpha:0.0];
    [self.view addSubview:fitToAnnotationButton];
}

- (void) mapView:(MKMapView *)mV didAddAnnotationViews:(NSArray *)views
{
    for(AnnotationView *aView in views)
    {
        //Drop animation
        CGRect endFrame = aView.frame;
        aView.frame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y - 230.0, aView.frame.size.width, aView.frame.size.height);
        [UIView animateWithDuration:0.45 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{[aView setFrame: endFrame];} completion:^(BOOL finished) {}];
    }
}

- (double) getZoomLevel:(MKMapView *)mV
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

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!annotationPressed) {
        [hud.collapseView close];
    }
    annotationPressed = NO;
}

#pragma mark StateControlProtocol delegate methods

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    return [delegate displayGameObject:g fromSource:s];
}

- (void) displayTab:(NSString *)t
{
    [delegate displayTab:t];
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [delegate displayScannerWithPrompt:p];
}

#pragma mark MapHUD delegate methods

- (void) dismissHUDWithAnnotation:(MKAnnotationView *)annotation
{
    [centerButton setAlpha:1.0];
    [fitToAnnotationButton setAlpha:1.0];
    [mapView deselectAnnotation:[annotation annotation] animated:NO];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

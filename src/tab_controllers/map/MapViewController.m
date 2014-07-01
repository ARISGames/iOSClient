//
//  MapViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AppModel.h"
#import "MapViewController.h"
#import "StateControllerProtocol.h"
#import "AppModel.h"
#import "User.h"
#import "AnnotationView.h"
#import "Media.h"

#import "CrumbPath.h"
#import "CrumbPathView.h"

#import "MapHUD.h"
#import "Overlay.h"
#import "MapOverlayView.h"
#import "TriangleButton.h"
#import "ItemActionViewController.h"

@interface MapViewController() <MKMapViewDelegate, MapHUDDelegate, StateControllerProtocol>
{
    MKMapView *mapView;
    MapHUD *hud;
    UIView *blackout;
    UIView *blackoutRight;
    UIView *blackoutLeft;
    UIView *blackoutBottom;

    UIButton *threeLinesButton;
    UIButton *centerButton;
    UIButton *fitToAnnotationButton;

    CrumbPath *crumbs;
    CrumbPathView *crumbView;

    NSTimer *refreshTimer;
    TriangleButton *viewAnnotationButton;
    TriangleButton *pickUpButton;

    BOOL resetWiggle;

    id<MapViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@end

@implementation MapViewController

- (id) initWithDelegate:(id<MapViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"MAP";
        self.tabIconName = @"map";

        delegate = d;

        _ARIS_NOTIF_LISTEN_(@"UserMoved",self,@selector(playerMoved),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_NEW_AVAILABLE",self,@selector(refreshViewFromModel),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_LESS_AVAILABLE",self,@selector(refreshViewFromModel),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_OVERLAYS_NEW_AVAILABLE",self,@selector(refreshViewFromModel),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_OVERLAYS_LESS_AVAILABLE",self,@selector(refreshViewFromModel),nil);
    }
    return self;
}

- (void) loadView
{
    [super loadView];

    mapView = [[MKMapView alloc] init];
	mapView.delegate = self;
    mapView.showsUserLocation = _MODEL_GAME_.show_player_location;

    if     ([_MODEL_GAME_.map_type isEqualToString:@"SATELLITE"]) mapView.mapType = MKMapTypeSatellite;
    else if([_MODEL_GAME_.map_type isEqualToString:@"HYBRID"])    mapView.mapType = MKMapTypeHybrid;
    else                                                          mapView.mapType = MKMapTypeStandard;

    hud = [[MapHUD alloc] initWithDelegate:self];
    [self initBlackoutsAndSetFrame];

    UIColor *buttonBGColor = [UIColor colorWithRed:242/255.0 green:241/255.0 blue:237/255.0 alpha:1];

    threeLinesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [threeLinesButton addTarget:self action:@selector(threeLinesButtonTouched) forControlEvents:UIControlEventTouchDown];
    [threeLinesButton setImage:[UIImage imageNamed:@"threelines.png"] forState:UIControlStateNormal];
    threeLinesButton.imageEdgeInsets = UIEdgeInsetsMake(6,6,6,6);
    threeLinesButton.backgroundColor = buttonBGColor;
    threeLinesButton.layer.borderColor = [UIColor whiteColor].CGColor;
    threeLinesButton.layer.borderWidth = 2.0f;

    centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [centerButton addTarget:self action:@selector(centerMapOnPlayer) forControlEvents:UIControlEventTouchDown];
    [centerButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
    centerButton.imageEdgeInsets = UIEdgeInsetsMake(6,6,6,6);

    centerButton.backgroundColor = buttonBGColor;
    centerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    centerButton.layer.borderWidth = 2.0f;

    fitToAnnotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fitToAnnotationButton addTarget:self action:@selector(zoomToFitAnnotations) forControlEvents:UIControlEventTouchDown];
    [fitToAnnotationButton setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
    fitToAnnotationButton.imageEdgeInsets = UIEdgeInsetsMake(6,6,6,6);
    fitToAnnotationButton.backgroundColor = buttonBGColor;
    fitToAnnotationButton.layer.borderColor = [UIColor whiteColor].CGColor;
    fitToAnnotationButton.layer.borderWidth = 2.0f;

    viewAnnotationButton = [[TriangleButton alloc] initWithColor:[UIColor ARISColorLightBlue] isPointingLeft:NO];
    pickUpButton = [[TriangleButton alloc] initWithColor:[UIColor colorWithRed:229.0f/255.0f green:127.0f/255.0f blue:134.0f/255.0f alpha:1.0f] isPointingLeft:YES];

    [self.view addSubview:mapView];
    [self.view addSubview:threeLinesButton];
    [self.view addSubview:centerButton];
    [self.view addSubview:fitToAnnotationButton];
    [self.view addSubview:blackout];
    [self.view addSubview:blackoutRight];
    [self.view addSubview:blackoutLeft];
    [self.view addSubview:blackoutBottom];
    [self.view addSubview:hud.view];

    resetWiggle = NO;

    //make the navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    mapView.frame = self.view.bounds;

    int buttonSize = 40;
    threeLinesButton.frame      = CGRectMake(15, 24,  buttonSize, buttonSize);
    centerButton.frame          = CGRectMake(15, 74,  buttonSize, buttonSize);
    fitToAnnotationButton.frame = CGRectMake(15, 124, buttonSize, buttonSize);

    hud.view.frame = CGRectMake(0, self.view.bounds.size.height-80, self.view.bounds.size.width, 80);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = nil;  //get rid of it from super, already added manually to view
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    [self refreshViewFromModel];
	[self refreshModels];
	
	if(refreshTimer && [refreshTimer isValid]) [refreshTimer invalidate];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refreshModels) userInfo:nil repeats:YES];
}

- (void) viewDidDisappear:(BOOL)animated
{
   	if(refreshTimer && [refreshTimer isValid]) [refreshTimer invalidate]; 
    refreshTimer = nil;
}

- (void) refreshModels
{
    [_MODEL_TRIGGERS_ requestPlayerTriggers];
    [_MODEL_OVERLAYS_ requestPlayerOverlays]; 
}

- (void) refreshViewFromModel
{
    if(!mapView) return;
    
    NSArray *mapAnnotations = mapView.annotations;
    NSArray *mapOverlays = mapView.overlays;
    BOOL shouldRemove;
    BOOL shouldAdd; 
    
    Trigger *mapTrigger;
    Trigger *modelTrigger;
    Overlay *mapOverlay;
    Overlay *modelOverlay; 
    
    //
    //LOCATIONS
    //
    
    //Remove locations
    for(int i = 0; i < mapAnnotations.count; i++)
    {
        if(![mapAnnotations[i] isKindOfClass:[Trigger class]]) continue;
        mapTrigger = mapAnnotations[i];
        shouldRemove = YES;
        for(int j = 0; j < _MODEL_TRIGGERS_.playerTriggers.count; j++)
        {
            modelTrigger = _MODEL_TRIGGERS_.playerTriggers[j];
            if(mapTrigger.trigger_id == modelTrigger.trigger_id) shouldRemove = NO;
        } 
        if(shouldRemove)
        {
            [mapView removeAnnotation:mapTrigger];
            [mapView removeOverlay:mapTrigger.mapCircle]; 
        }
    }
    //Add locations
    for(int i = 0; i < _MODEL_TRIGGERS_.playerTriggers.count; i++) 
    {
        modelTrigger = _MODEL_TRIGGERS_.playerTriggers[i]; 
        if(![modelTrigger.type isEqualToString:@"LOCATION"]) continue;  
        shouldAdd = YES;
        for(int j = 0; j < mapAnnotations.count; j++) 
        {
            if(![mapAnnotations[j] isKindOfClass:[Trigger class]]) continue;
            mapTrigger = mapAnnotations[j]; 
            if(mapTrigger.trigger_id == modelTrigger.trigger_id) shouldAdd = NO;
        } 
        if(shouldAdd)
        {
            [mapView addAnnotation:modelTrigger];
            [mapView addOverlay:modelTrigger.mapCircle];  
        }
    } 
    
    
    //
    //OVERLAYS
    //
    
    //Remove overlays
    for(int i = 0; i < mapOverlays.count; i++)
    {
        if(![mapOverlays[i] isKindOfClass:[Overlay class]]) continue;
        mapOverlay = mapOverlays[i];
        shouldRemove = YES;
        for(int j = 0; j < _MODEL_OVERLAYS_.playerOverlays.count; j++)
        {
            modelOverlay = _MODEL_OVERLAYS_.playerOverlays[j];
            if(mapOverlay.overlay_id == modelOverlay.overlay_id) shouldRemove = NO;
        } 
        [mapView removeOverlay:mapOverlay];   
    }
    //Add overlays
    for(int i = 0; i < _MODEL_OVERLAYS_.playerOverlays.count; i++) 
    {
        modelOverlay = _MODEL_OVERLAYS_.playerOverlays[i]; 
        shouldAdd = YES;
        for(int j = 0; j < mapOverlays.count; j++) 
        {
            if(![mapOverlays[j] isKindOfClass:[Overlay class]]) continue;
            mapOverlay = mapOverlays[j]; 
            if(mapOverlay.overlay_id == modelOverlay.overlay_id) shouldAdd = NO;
        } 
        [mapView addOverlay:modelOverlay];    
    }  
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
        circleView.opaque = NO;
        return circleView;
    }
    if([overlay isKindOfClass:[Overlay class]])
    {
        MapOverlayView *mapOverlayView = [[MapOverlayView alloc] initWithOverlay:overlay];
        return mapOverlayView;
    }
    return nil;
}

- (MKAnnotationView *) mapView:(MKMapView *)myMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if(![annotation isKindOfClass:[Trigger class]]) return nil;
    else return [[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
}

- (void) playerMoved
{
    /*
    //Pen Down
    if(!crumbs)
    {
        crumbs = [[CrumbPath alloc] initWithCenterCoordinate:_MODEL_PLAYER_.location.coordinate];
        [mapView addOverlay:crumbs];
    }
    else [crumbs addCoordinate:_MODEL_PLAYER_.location.coordinate];
    [crumbView setNeedsDisplay];
     */
}

- (void) centerMapOnPlayer
{
    [self centerMapOnLoc:_MODEL_PLAYER_.location.coordinate];
    MKCoordinateRegion region = mapView.region;
    region.span = MKCoordinateSpanMake(0.001f, 0.001f);
}

- (void) centerMapOnLoc:(CLLocationCoordinate2D)loc
{
   	MKCoordinateRegion region = mapView.region;
	region.center = loc;

	[mapView setRegion:region animated:NO];
}

-(void) zoomToFitAnnotations
{
    if(mapView.annotations.count == 0) return;

    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;

    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;

    for(int i = 0; i < mapView.annotations.count; i++)
    {
        id<MKAnnotation> an = mapView.annotations[i];
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, an.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, an.coordinate.latitude);

        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, an.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, an.coordinate.latitude);
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


- (void) mapView:(MKMapView *)mv didSelectAnnotationView:(MKAnnotationView *)av
{
    if(av.annotation && [av.annotation isKindOfClass:[Trigger class]])
        [self displayHUDWithLocation:(Trigger *)av.annotation andAnnotation:(AnnotationView *)av];
}

- (void) enableAnnotations
{
    Trigger *t; 
    for (int i = 0; i < mapView.annotations.count; i++)
    {
        if(![mapView.annotations[i] isKindOfClass:[Trigger class]]) continue;
        t = mapView.annotations[i];
        [[mapView viewForAnnotation:t] setEnabled:YES];
    }
}

- (void) disableAnnotations
{
    Trigger *t; 
    for (int i = 0; i < mapView.annotations.count; i++)
    {
        if(![mapView.annotations[i] isKindOfClass:[Trigger class]]) continue;
        t = mapView.annotations[i];
        [[mapView viewForAnnotation:t] setEnabled:NO];
    } 
}

- (void) displayHUDWithLocation:(Trigger *)trigger andAnnotation:(AnnotationView *)annotation
{
    //temporary set the wiggle to false when the trigger is selected
    if(trigger.wiggle)
    {
        trigger.wiggle = NO;
        resetWiggle = YES;
    }
    else{
        resetWiggle = NO;
    }
    [self displayBlackout];

    mapView.zoomEnabled = NO;
    mapView.scrollEnabled = NO;
    mapView.userInteractionEnabled = NO;
    [self disableAnnotations];

    [annotation enlarge];
    [hud setTrigger:trigger];
    [hud open];
    [self centerMapOnLoc:trigger.coordinate];

    [blackout setAlpha:0.0f];
    [blackoutLeft setAlpha:0.0f];
    [blackoutRight setAlpha:0.0f];
    [blackoutBottom setAlpha:0.0f];

    CLLocationDistance distance = [_MODEL_PLAYER_.location distanceFromLocation:trigger.location];
    if((trigger.infinite_distance || distance <= trigger.distance) && _MODEL_PLAYER_.location != nil)
    {
        viewAnnotationButton.frame = CGRectMake((self.view.bounds.size.width / 2) + 60, (self.view.bounds.size.height / 2) - 28, 75, 120);
        [viewAnnotationButton setTitle:NSLocalizedString(@"ViewLocationKey", @"") forState:UIControlStateNormal];
        [viewAnnotationButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
        [viewAnnotationButton addTarget:self action:@selector(interactWithLocation:) forControlEvents:UIControlEventTouchUpInside];
        [viewAnnotationButton setAlpha:0.0f];
        [self.view addSubview:viewAnnotationButton];

        /*
        if([location.gameObject isKindOfClass:[Item class]])
        {
            pickUpButton.frame = CGRectMake((self.view.bounds.size.width / 2) - 135, (self.view.bounds.size.height / 2) - 28, 75, 120);
            [pickUpButton setTitle:NSLocalizedString(@"PickUpItemKey", @"") forState:UIControlStateNormal];
            [pickUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
            [pickUpButton setAlpha:0.0f];
            [pickUpButton setLocation:location];
            [pickUpButton addTarget:self action:@selector(pickUpItem:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:pickUpButton];
        }
         */
    }
    [self animateInButtons];
}

- (void) animateInButtons
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.2f];
    [viewAnnotationButton setAlpha:1.0f];
    [pickUpButton setAlpha:1.0f];
    [blackout setAlpha:1.0f];
    [blackoutBottom setAlpha:1.0f];
    [blackoutLeft setAlpha:1.0f];
    [blackoutRight setAlpha:1.0f];
    [UIView commitAnimations];
}

/*
- (void) pickUpItem:(TriangleButton*)sender
{
    Trigger *currLocation = sender.location;
    if([currLocation.gameObject isKindOfClass:[Item class]])
    {
        Item *item = (Item *)currLocation.gameObject;
        [self dismissSelection];
    }
}
 */

- (void) dismissSelection
{
    [viewAnnotationButton removeFromSuperview];
    [pickUpButton removeFromSuperview];
    [self dismissBlackout];

    mapView.zoomEnabled = YES;
    mapView.scrollEnabled = YES;
    mapView.userInteractionEnabled = YES;
    [self enableAnnotations];

    while(mapView.selectedAnnotations.count > 0)
    {
        if([mapView.selectedAnnotations[0] class] == [Trigger class])
        { 
            Trigger *an = mapView.selectedAnnotations[0];
            [((AnnotationView *)[mapView viewForAnnotation:an]) shrinkToNormal];
            if(resetWiggle)
            {
                an.wiggle = YES;
                [((AnnotationView *)[mapView viewForAnnotation:an]) setNeedsDisplay];
            }
        }
        [mapView deselectAnnotation:mapView.selectedAnnotations[0] animated:NO];
    }
    [hud dismiss];
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

- (void) blackoutTouched
{
    [self dismissSelection];
}

- (void)interactWithLocation:(TriangleButton*)sender
{
    //Trigger *currLocation = sender.location;
    //[self displayGameObject:currLocation.gameObject fromSource:currLocation];
}

- (void) threeLinesButtonTouched
{
    [super showNav];
}

#pragma mark blackout methods

- (void) initBlackoutsAndSetFrame
{
    blackout = [[UIView alloc] init];
    blackout.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, (self.view.bounds.size.height/2) - 28);
    [blackout addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackoutTouched)]];
    blackout.userInteractionEnabled = NO;

    blackoutRight = [[UIView alloc] init];
    blackoutRight.frame = CGRectMake(220, blackout.frame.size.height, 100, self.view.bounds.size.height - blackout.frame.size.height);
    [blackoutRight addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackoutTouched)]];
    blackoutRight.userInteractionEnabled = NO;

    blackoutLeft = [[UIView alloc] init];
    blackoutLeft.frame = CGRectMake(0, blackout.frame.size.height, 100, self.view.bounds.size.height - blackout.frame.size.height);
    [blackoutLeft addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackoutTouched)]];
    blackoutLeft.userInteractionEnabled = NO;

    blackoutBottom = [[UIView alloc] init];
    blackoutBottom.frame = CGRectMake(100, (self.view.bounds.size.height / 2) + 92, 120, self.view.bounds.size.height - ((self.view.bounds.size.height / 2) + 92));
    [blackoutBottom addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackoutTouched)]];
    blackoutBottom.userInteractionEnabled = NO;
}

- (void) displayBlackout
{
    UIColor *blackoutColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
    [blackout setBackgroundColor:blackoutColor];
    [blackoutRight setBackgroundColor:blackoutColor];
    [blackoutLeft setBackgroundColor:blackoutColor];
    [blackoutBottom setBackgroundColor:blackoutColor];

    [blackout setUserInteractionEnabled:YES];
    [blackoutBottom setUserInteractionEnabled:YES];
    [blackoutRight setUserInteractionEnabled:YES];
    [blackoutLeft setUserInteractionEnabled:YES];
}

- (void) dismissBlackout
{
    [blackout setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f]];
    [blackout setUserInteractionEnabled:NO];
    [blackoutRight setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f]];
    [blackoutRight setUserInteractionEnabled:NO];
    [blackoutLeft setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f]];
    [blackoutLeft setUserInteractionEnabled:NO];
    [blackoutBottom setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f]];
    [blackoutBottom setUserInteractionEnabled:NO];
}

#pragma mark StateControlProtocol delegate methods

- (BOOL) displayGameObject:(id)g fromSource:(id)s
{
    [self dismissSelection];
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

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

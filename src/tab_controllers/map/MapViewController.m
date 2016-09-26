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
#import "AppModel.h"
#import "User.h"
#import "AnnotationView.h"

#import "CrumbPath.h"
#import "CrumbPathView.h"

#import "MapHUD.h"
#import "Overlay.h"
#import "MapOverlayView.h"
#import "TriangleButton.h"
#import "ItemActionViewController.h"
#import <Google/Analytics.h>


// simple struct to hold annotation/overlay pairs so they can be added/removed together
@interface MapViewAnnotationOverlay : NSObject
{
    id<MKAnnotation> annotation;
    id<MKOverlay> overlay;
}
@property(nonatomic, strong) id<MKAnnotation> annotation;
@property(nonatomic, strong) id<MKOverlay> overlay;

- (id) initWithAnnotation:(id<MKAnnotation>)a overlay:(id<MKOverlay>)o;
@end

@implementation MapViewAnnotationOverlay

@synthesize annotation;
@synthesize overlay;

- (id) initWithAnnotation:(id<MKAnnotation>)a overlay:(id<MKOverlay>)o
{
    if(self = [super init])
    {
        annotation = a;
        overlay = o;
    }
    return self;
}

@end

@interface MapViewController() <MKMapViewDelegate, MapHUDDelegate>
{
    Tab *tab;

    MKMapView *mapView;
    NSMutableArray *annotationOverlays; //annot/overlays (triggers/circles) added to map
    NSMutableArray *overlays; //overlays (custom maps) added to map

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

    TriangleButton *viewAnnotationButton;
    TriangleButton *pickUpButton;

    Trigger *triggerLookingAt;

    BOOL resetWiggle;
    BOOL firstLoad; //for auto-centering map

    id<MapViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation MapViewController

- (id) initWithTab:(Tab *)t delegate:(id<MapViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tab = t;
        delegate = d;

        _ARIS_NOTIF_LISTEN_(@"USER_MOVED",self,@selector(playerMoved),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_PLAYER_TRIGGERS_AVAILABLE",self,@selector(refreshViewFromModel),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_INVALIDATED",self,@selector(triggersInvalidated:),nil); //weird external model update
        _ARIS_NOTIF_LISTEN_(@"MODEL_OVERLAYS_NEW_AVAILABLE",self,@selector(refreshViewFromModel),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_OVERLAYS_LESS_AVAILABLE",self,@selector(refreshViewFromModel),nil);
        firstLoad = true;

        annotationOverlays = [[NSMutableArray alloc] init];
        overlays = [[NSMutableArray alloc] init];
    }
    return self;
}

// helpers because obj c doesn't have typed arrays...
- (MapViewAnnotationOverlay *) mvaoAt:(long)i { return annotationOverlays[i]; }
- (id<MKOverlay>) mvoAt:(long)i { return overlays[i]; }

- (void) loadView
{
    [super loadView];

    mapView = [[MKMapView alloc] init];
    mapView.delegate = self;
    mapView.showsUserLocation = _MODEL_GAME_.map_show_player;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f) mapView.showsCompass = YES;

    if     ([_MODEL_GAME_.map_type isEqualToString:@"SATELLITE"]) mapView.mapType = MKMapTypeSatellite;
    else if([_MODEL_GAME_.map_type isEqualToString:@"HYBRID"])    mapView.mapType = MKMapTypeHybrid;
    else                                                          mapView.mapType = MKMapTypeStandard;

    hud = [[MapHUD alloc] initWithDelegate:self];
    [self initBlackoutsAndSetFrame];

    UIColor *buttonBGColor = [UIColor colorWithRed:242/255.0 green:241/255.0 blue:237/255.0 alpha:1];

    threeLinesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [threeLinesButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchDown];
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
    [fitToAnnotationButton addTarget:self action:@selector(animateZoomToFitAnnotations) forControlEvents:UIControlEventTouchDown];
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

    long buttonSize = 40;
    threeLinesButton.frame      = CGRectMake(15, 24,  buttonSize, buttonSize);
    centerButton.frame          = CGRectMake(15, 74,  buttonSize, buttonSize);
    fitToAnnotationButton.frame = CGRectMake(15, 124, buttonSize, buttonSize);

    hud.view.frame = CGRectMake(0, self.view.bounds.size.height-80, self.view.bounds.size.width, 80);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:self.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self refreshViewFromModel];
    [self refreshModels];
}

- (void) refreshModels
{
    [_MODEL_TRIGGERS_ requestPlayerTriggers];
    [_MODEL_OVERLAYS_ requestPlayerOverlays];
}

- (void) triggersInvalidated:(NSNotification *)n
{
    NSMutableArray *invalidated = n.userInfo[@"invalidated_triggers"];

    Trigger *invalidatedTrigger;
    Trigger *mapTrigger;
    MapViewAnnotationOverlay *mvao;

    for(long i = 0; i < invalidated.count; i++)
    {
        mvao = nil;
        invalidatedTrigger = invalidated[i];
        for(long j = 0; j < annotationOverlays.count; j++)
        {
            mapTrigger = [self mvaoAt:j].annotation;
            if(mapTrigger.trigger_id == invalidatedTrigger.trigger_id) mvao = [self mvaoAt:j];
        }
        if(mvao)
        {
            [mapView removeAnnotation:mvao.annotation];
            [mapView removeOverlay:mvao.overlay];
            [annotationOverlays removeObject:mvao];
        }
    }
}

- (void) clearLocalData
{
    if(!mapView) return;

    for(long i = 0; i < annotationOverlays.count; i++)
    {
        [mapView removeAnnotation:[self mvaoAt:i].annotation];
        [mapView removeOverlay:[self mvaoAt:i].overlay];
    }
    for(long i = 0; i < overlays.count; i++)
    {
        [mapView removeOverlay:[self mvoAt:i]];
    }
    annotationOverlays = [[NSMutableArray alloc] init];
    overlays = [[NSMutableArray alloc] init];
}

- (void) refreshViewFromModel
{
    if(!mapView) return;

    BOOL shouldRemove;
    BOOL shouldAdd;

    Trigger *mapTrigger;
    Trigger *modelTrigger;
    Instance *modelInstance;
    Overlay *mapOverlay;
    Overlay *modelOverlay;

    //
    //LOCATIONS
    //

    //Remove locations
    for(long i = 0; i < annotationOverlays.count; i++)
    {
        mapTrigger = [self mvaoAt:i].annotation;
        shouldRemove = YES;
        for(long j = 0; j < _MODEL_TRIGGERS_.playerTriggers.count; j++)
        {
            modelTrigger = _MODEL_TRIGGERS_.playerTriggers[j];
            if(mapTrigger.trigger_id == modelTrigger.trigger_id &&
               (
                 [_MODEL_INSTANCES_ instanceForId:mapTrigger.instance_id].infinite_qty ||
                 [_MODEL_INSTANCES_ instanceForId:mapTrigger.instance_id].qty > 0 ||
                ![[_MODEL_INSTANCES_ instanceForId:mapTrigger.instance_id].object_type isEqualToString:@"ITEM"]
               )
              ) shouldRemove = NO;
        }
        if(shouldRemove)
        {
            MapViewAnnotationOverlay *mvao = [self mvaoAt:i];
            [mapView removeAnnotation:mvao.annotation];
            [mapView removeOverlay:mvao.overlay];
            [annotationOverlays removeObject:mvao];
            i--;
        }
    }
    //Add locations
    for(long i = 0; i < _MODEL_TRIGGERS_.playerTriggers.count; i++)
    {
        modelTrigger = _MODEL_TRIGGERS_.playerTriggers[i];
        modelInstance = [_MODEL_INSTANCES_ instanceForId:modelTrigger.instance_id];
        if(modelInstance.instance_id == 0 || !modelInstance.object) continue;

        if(
           ( //trigger not eligible for map
            ![modelTrigger.type isEqualToString:@"LOCATION"] || modelTrigger.hidden
           )
           ||
           ( //instance not eligible for map
            [modelInstance.object_type isEqualToString:@"ITEM"] &&
            !modelInstance.infinite_qty &&
             modelInstance.qty <= 0
           )
          ) continue;

        shouldAdd = YES;
        for(long j = 0; j < annotationOverlays.count; j++)
        {
            mapTrigger = [self mvaoAt:j].annotation;
            if(mapTrigger.trigger_id == modelTrigger.trigger_id) shouldAdd = NO;
        }
        if(shouldAdd)
        {
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:modelTrigger.location.coordinate radius:(modelTrigger.infinite_distance ? 0 : modelTrigger.distance)];
            MapViewAnnotationOverlay *mvao = [[MapViewAnnotationOverlay alloc] initWithAnnotation:modelTrigger overlay:circle];

            [mapView addAnnotation:mvao.annotation];
            [mapView addOverlay:mvao.overlay];
            [annotationOverlays addObject:mvao];
        }
    }


    //
    //OVERLAYS
    //

    //Remove overlays
    for(long i = 0; i < overlays.count; i++)
    {
        mapOverlay = [self mvoAt:i];
        shouldRemove = YES;
        for(long j = 0; j < _MODEL_OVERLAYS_.playerOverlays.count; j++)
        {
            modelOverlay = _MODEL_OVERLAYS_.playerOverlays[j];
            if(mapOverlay.overlay_id == modelOverlay.overlay_id) shouldRemove = NO;
        }
        if(shouldRemove)
        {
            [mapView removeOverlay:mapOverlay];
            [overlays removeObject:mapOverlay];
            i--;
        }
    }
    //Add overlays
    for(long i = 0; i < _MODEL_OVERLAYS_.playerOverlays.count; i++)
    {
        modelOverlay = _MODEL_OVERLAYS_.playerOverlays[i];
        shouldAdd = YES;
        for(long j = 0; j < overlays.count; j++)
        {
            mapOverlay = [self mvoAt:j];
            if(mapOverlay.overlay_id == modelOverlay.overlay_id) shouldAdd = NO;
        }
        if(shouldAdd)
        {
            [mapView addOverlay:modelOverlay];
            [overlays addObject:modelOverlay];
        }
    }

    //refresh views (ugly)
    [mapView setCenterCoordinate:mapView.region.center animated:NO];
    if(firstLoad)
    {
      if     ([_MODEL_GAME_.map_focus isEqualToString:@"PLAYER"])        [self centerMapOnPlayer];
      else if([_MODEL_GAME_.map_focus isEqualToString:@"LOCATION"])      [self centerMapOnLoc:_MODEL_GAME_.map_location.coordinate zoom:_MODEL_GAME_.map_zoom_level];
      else if([_MODEL_GAME_.map_focus isEqualToString:@"FIT_LOCATIONS"]) [self zoomToFitAnnotations:NO];
    }
    firstLoad = false;
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
        //(dep) MapOverlayView *mapOverlayView = [[MapOverlayView alloc] initWithOverlay:overlay];
        //(dep) return mapOverlayView;
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
    [self centerMapOnLoc:_MODEL_PLAYER_.location.coordinate zoom:1.f];
}

- (void) centerMapOnLoc:(CLLocationCoordinate2D)loc
{
    MKCoordinateRegion region = mapView.region;
    region.center = loc;

    [mapView setRegion:region animated:NO];
}

- (void) centerMapOnLoc:(CLLocationCoordinate2D)loc zoom:(float)z
{
    MKCoordinateRegion region = mapView.region;
    region.center = loc;
    if(z > 3.) z = 3.;
    region.span = MKCoordinateSpanMake(0.001f*pow(10,z), 0.001f*pow(10,z));

    [mapView setRegion:region animated:NO];
}

- (void) animateZoomToFitAnnotations
{
    [self zoomToFitAnnotations:YES];
}

- (void) zoomToFitAnnotations:(BOOL)animate
{
    if(mapView.annotations.count == 0) return;

    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;

    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;

    for(long i = 0; i < mapView.annotations.count; i++)
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
    if(region.span.latitudeDelta > 180) region.span.latitudeDelta = 180;
    if(region.span.longitudeDelta > 360) region.span.longitudeDelta = 360;

    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:animate];
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
        [self displayHUDWithTrigger:(Trigger *)av.annotation andAnnotation:(AnnotationView *)av];
}

- (void) enableAnnotations
{
    Trigger *t;
    for (long i = 0; i < mapView.annotations.count; i++)
    {
        if(![mapView.annotations[i] isKindOfClass:[Trigger class]]) continue;
        t = mapView.annotations[i];
        [[mapView viewForAnnotation:t] setEnabled:YES];
    }
}

- (void) disableAnnotations
{
    Trigger *t;
    for (long i = 0; i < mapView.annotations.count; i++)
    {
        if(![mapView.annotations[i] isKindOfClass:[Trigger class]]) continue;
        t = mapView.annotations[i];
        [[mapView viewForAnnotation:t] setEnabled:NO];
    }
}

- (void) displayHUDWithTrigger:(Trigger *)trigger andAnnotation:(AnnotationView *)annotation
{
    //temporary set the wiggle to false when the trigger is selected
    if(trigger.wiggle)
    {
        trigger.wiggle = NO;
        resetWiggle = YES;
    }
    else
    {
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
    if(_MODEL_GAME_.map_offsite_mode || trigger.infinite_distance || (distance <= trigger.distance && _MODEL_PLAYER_.location != nil))
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
    triggerLookingAt = trigger;
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

- (void) interactWithLocation:(TriangleButton*)sender
{
    if(triggerLookingAt) { [_MODEL_DISPLAY_QUEUE_ enqueueTrigger:triggerLookingAt]; [self dismissSelection]; }
    else [self dismissSelection];
    triggerLookingAt = nil;
}

- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}

#pragma mark blackout methods

- (void) initBlackoutsAndSetFrame
{
  int icon_w = 56*2;
  int screen_w = self.view.bounds.size.width;
  int screen_h = self.view.bounds.size.height;

  blackout = [[UIView alloc] init];
  blackout.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, screen_w, (screen_h-(icon_w/2))/2);
  [blackout addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackoutTouched)]];
  blackout.userInteractionEnabled = NO;

  blackoutLeft = [[UIView alloc] init];
  blackoutLeft.frame = CGRectMake(0, blackout.frame.size.height, (screen_w-icon_w)/2, screen_h-blackout.frame.size.height);
  [blackoutLeft addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackoutTouched)]];
  blackoutLeft.userInteractionEnabled = NO;
  
  blackoutRight = [[UIView alloc] init];
  blackoutRight.frame = CGRectMake((screen_w+icon_w)/2, blackout.frame.size.height, (screen_w-icon_w)/2, screen_h-blackout.frame.size.height);
  [blackoutRight addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackoutTouched)]];
  blackoutRight.userInteractionEnabled = NO;

  blackoutBottom = [[UIView alloc] init];
  blackoutBottom.frame = CGRectMake((screen_w-icon_w)/2, blackout.frame.size.height+icon_w, icon_w, screen_h-(blackout.frame.size.height+icon_w));
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

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"MAP"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; return @"Map"; }
- (ARISMediaView *) tabIcon
{
    ARISMediaView *amv = [[ARISMediaView alloc] init];
    if(tab.icon_media_id)
        [amv setMedia:[_MODEL_MEDIA_ mediaForId:tab.icon_media_id]];
    else
        [amv setImage:[UIImage imageNamed:@"map"]];
    return amv;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

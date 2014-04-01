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
#import "CustomMapOverlay.h"
#import "CustomMapOverlayView.h"
#import "TriangleButton.h"
#import "LocationsModel.h"
#import "ItemActionViewController.h"


@interface MapViewController() <MKMapViewDelegate, MapHUDDelegate, StateControllerProtocol>
{
    NSMutableArray *locations;
    NSMutableArray *locationsToAdd;
    NSMutableArray *locationsToRemove;
    
    BOOL isViewLoaded;

    MKMapView *mapView;
    MapHUD *hud;
    UIView *blackout;
    
    UIButton *threeLinesButton; 
    UIButton *centerButton;
    UIButton *fitToAnnotationButton;
    
    CrumbPath *crumbs;
    CrumbPathView *crumbView;

    NSTimer *refreshTimer;
    TriangleButton *viewAnnotationButton;
    TriangleButton *pickUpButton;

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
        
        isViewLoaded = NO;
        locationsToAdd    = [[NSMutableArray alloc] initWithCapacity:10];
        locationsToRemove = [[NSMutableArray alloc] initWithCapacity:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator)     name:@"ConnectionLost"                               object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerMoved)                name:@"PlayerMoved"                                  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator)     name:@"ReceivedLocationList"                         object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLocationsToNewQueue:)    name:@"NewlyAvailableLocationsAvailable"             object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLocationsToRemoveQueue:) name:@"NewlyUnavailableLocationsAvailable"           object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge)             name:@"NewlyChangedLocationsGameNotificationSent"    object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector
         (addOverlaysToMap)              name:@"NewOverlaysAvailable"
            object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    mapView = [[MKMapView alloc] init];
	mapView.delegate = self;
    mapView.showsUserLocation = [AppModel sharedAppModel].currentGame.showPlayerLocation; 
    
    if     ([[AppModel sharedAppModel].currentGame.mapType isEqualToString:@"SATELLITE"]) mapView.mapType = MKMapTypeSatellite;
    else if([[AppModel sharedAppModel].currentGame.mapType isEqualToString:@"HYBRID"])    mapView.mapType = MKMapTypeHybrid;
    else                                                                                  mapView.mapType = MKMapTypeStandard;
    
    hud = [[MapHUD alloc] initWithDelegate:self];
    blackout = [[UIView alloc] init];
    blackout.frame = self.view.bounds;
    [blackout addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackoutTouched)]];
    blackout.userInteractionEnabled = NO; 
    
    
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
    
    viewAnnotationButton = [[TriangleButton alloc] initWithColor:[UIColor ARISColorDarkBlue] isPointingLeft:NO];
    pickUpButton = [[TriangleButton alloc] initWithColor:[UIColor ARISColorRed] isPointingLeft:YES];
    
    [self.view addSubview:mapView];
    [self.view addSubview:threeLinesButton]; 
    [self.view addSubview:centerButton];
    [self.view addSubview:fitToAnnotationButton];
    [self.view addSubview:blackout]; 
    [self.view addSubview:hud.view];   
    
    isViewLoaded = YES;
    
    //make the navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.userInteractionEnabled = NO; 
    
    [self refresh];
    
    [self addOverlaysToMap];
}

- (void) addOverlaysToMap
{
    for (int i = 0; i < mapView.overlays.count; i++) {
        if ([mapView.overlays[i] isKindOfClass:[CustomMapOverlay class]]) {
            [mapView removeOverlay:mapView.overlays[i]];
        }
    }
    
    for (NSNumber *overlayId in [AppModel sharedAppModel].currentGame.overlaysModel.overlayIds) {
        int integerId = [overlayId intValue];
        id<MKOverlay> mapOverlay = [[AppModel sharedAppModel].currentGame.overlaysModel overlayForOverlayId:integerId];
        if (mapOverlay) {
            [mapView addOverlay:mapOverlay];
        }
    }
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    mapView.frame = self.view.bounds;
    
    int buttonSize = 40;
    threeLinesButton.frame      = CGRectMake(15, 24,  buttonSize, buttonSize); 
    centerButton.frame          = CGRectMake(15, 69,  buttonSize, buttonSize);
    fitToAnnotationButton.frame = CGRectMake(15, 114, buttonSize, buttonSize);  
    
    hud.view.frame = CGRectMake(0, self.view.bounds.size.height-80, self.view.bounds.size.width, 80);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = nil;  //get rid of it from super
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	[[AppServices sharedAppServices] updateServerMapViewed];
	
    [self refreshViewFromModel];
	[self refresh];
	
	if(refreshTimer && [refreshTimer isValid]) [refreshTimer invalidate];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    [self zoomToFitAnnotations];  
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
    if ([overlay isKindOfClass:[CustomMapOverlay class]]) {
        CustomMapOverlayView *mapOverlayView = [[CustomMapOverlayView alloc] initWithCustomOverlay:overlay];
        return mapOverlayView;
    }
    return nil;
}


- (void) refresh
{
    //the fact that we need to check this here means we're doing something wrong with our architecture... 
    if(![AppModel sharedAppModel].player || [AppModel sharedAppModel].player.playerId == 0 || [AppModel sharedAppModel].currentGame.gameId == 0)  return;
    
    if(mapView)
    {
        [[AppServices sharedAppServices] fetchPlayerLocationList];
        [[AppServices sharedAppServices] fetchPlayerOverlayList];
        [self showLoadingIndicator];
    }
}

- (void) playerMoved
{
    /*
     Pen Down
    if(!crumbs)
    {
        crumbs = [[CrumbPath alloc] initWithCenterCoordinate:[AppModel sharedAppModel].player.location.coordinate];
        [mapView addOverlay:crumbs];
    }
    else [crumbs addCoordinate:[AppModel sharedAppModel].player.location.coordinate]; 
    [crumbView setNeedsDisplay];
     */
}

- (void) centerMapOnPlayer
{
    //the fact that we need to check this here means we're doing something wrong with our architecture...
    if(![AppModel sharedAppModel].player || [AppModel sharedAppModel].player.playerId == 0 || [AppModel sharedAppModel].currentGame.gameId == 0) return;
	
	//Center the map on the player
    [self centerMapOnLoc:[AppModel sharedAppModel].player.location.coordinate];
    MKCoordinateRegion region = mapView.region;
    region.span = MKCoordinateSpanMake(0.001f, 0.001f);
}

- (void) centerMapOnLoc:(CLLocationCoordinate2D)loc
{
   	MKCoordinateRegion region = mapView.region;
	region.center = loc;
	//region.span = MKCoordinateSpanMake(0.001f, 0.001f);
    
	[mapView setRegion:region animated:YES]; 
}

-(void) zoomToFitAnnotations
{
    if([mapView.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(Location *annotationLocation in mapView.annotations)
    {
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

- (MKAnnotationView *) mapView:(MKMapView *)myMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if(annotation == mapView.userLocation) return nil;
    else return [[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
}

- (void) mapView:(MKMapView *)mv didSelectAnnotationView:(MKAnnotationView *)av
{
    if(av.annotation && [av class] == [AnnotationView class] && [av.annotation class] == [Location class])
    {
        [self displayHUDWithLocation:(Location *)av.annotation andAnnotation:(AnnotationView *)av];
    }
}

- (void) displayHUDWithLocation:(Location *)location andAnnotation:(AnnotationView *)annotation
{
    [blackout setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.01f]];
    [blackout setUserInteractionEnabled:YES];
    [annotation enlarge];
    [hud setLocation:location];
    [hud open];
    [self centerMapOnLoc:location.latlon.coordinate];
    
    CLLocationDistance distance = [[[AppModel sharedAppModel] player].location distanceFromLocation:location.latlon];
    if((distance <= location.errorRange && [[AppModel sharedAppModel] player].location != nil) || location.allowsQuickTravel){
        viewAnnotationButton.frame = CGRectMake((self.view.bounds.size.width / 2) + 65, (self.view.bounds.size.height / 2) - 15, 75, 100);
        [viewAnnotationButton setTitle:@"View" forState:UIControlStateNormal];
        [viewAnnotationButton addTarget:self action:@selector(interactWithLocation:) forControlEvents:UIControlEventTouchUpInside];
        [viewAnnotationButton setLocation:location];
        [viewAnnotationButton setAlpha:0.0f];
        [self.view addSubview:viewAnnotationButton];
        
        [self performSelector:@selector(animateInButtons) withObject:nil afterDelay:1.0f];
        
        if ([location.gameObject isKindOfClass:[Item class]]) {
            pickUpButton.frame = CGRectMake((self.view.bounds.size.width / 2) - 140, (self.view.bounds.size.height / 2) - 15, 75, 100);
            [pickUpButton setTitle:@"Pick up" forState:UIControlStateNormal];
            [pickUpButton setAlpha:0.0f];
            [pickUpButton setLocation:location];
            [pickUpButton addTarget:self action:@selector(pickUpItem:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:pickUpButton];
        }
    }
    

}

- (void) animateInButtons
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.7f];
    [viewAnnotationButton setAlpha:1.0f];
    [pickUpButton setAlpha:1.0f];
    [UIView commitAnimations];
}

- (void) pickUpItem:(TriangleButton*)sender
{
    Location *currLocation = sender.location;
    if ([currLocation.gameObject isKindOfClass:[Item class]]) {
        Item *item = (Item *)currLocation.gameObject;
        [self pickUpButtonTouched:item location:currLocation];
        [self dismissSelection];
    }
}

- (void) pickUpButtonTouched:(Item *)item location:(Location *)location
{
    //this code is taken straight from ItemViewController
    if(item.qty > 1 && !item.infiniteQty)
    {
        int q = item.qty;
        
        Item *invItem = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:item.itemId];
        if(!invItem) { invItem = [[AppModel sharedAppModel].currentGame itemForItemId:item.itemId]; invItem.qty = 0; }
        
        int maxPUAmt = invItem.infiniteQty ? 99999 : invItem.maxQty-invItem.qty;
        if(q < maxPUAmt) maxPUAmt = q;
        
        int wc = [AppModel sharedAppModel].currentGame.inventoryModel.weightCap;
        int cw = [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight;
        while(wc != 0 && (maxPUAmt*item.weight + cw) > wc) maxPUAmt--;
        
        if(maxPUAmt < q) q = maxPUAmt;
        
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithPrompt:@"Pick Up" positive:YES qty:q delegate:self];
        [[self navigationController] pushViewController:itemActionVC animated:YES];
    }
    else
        [self pickupItemQty:1 item:item location:location];
}

- (void) pickupItemQty:(int)q item:(Item *)item location:(Location *)location
{
    //this code was taken straight from ItemViewController
    Item *invItem = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:item.itemId];
    if(!invItem) { invItem = [[AppModel sharedAppModel].currentGame itemForItemId:item.itemId]; invItem.qty = 0; }
    
    int maxPUAmt = invItem.infiniteQty ? 99999 : invItem.maxQty-invItem.qty;
    if(q < maxPUAmt) maxPUAmt = q;
    
    int wc = [AppModel sharedAppModel].currentGame.inventoryModel.weightCap;
    int cw = [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight;
    while(wc != 0 && (maxPUAmt*item.weight + cw) > wc) maxPUAmt--;
    
    if(maxPUAmt < q)
    {
        q = maxPUAmt;
    }
    else if(q > 0)
    {
        [[AppServices sharedAppServices] updateServerPickupItem:item.itemId fromLocation:location.locationId qty:q];
        [[AppModel sharedAppModel].currentGame.locationsModel modifyQuantity:-q forLocationId:location.locationId];
        item.qty -= q;
    }
}

- (void) dismissSelection
{
    [viewAnnotationButton removeFromSuperview];
    [pickUpButton removeFromSuperview];
    [blackout setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f]]; 
    [blackout setUserInteractionEnabled:NO];
    
    while([mapView.selectedAnnotations count] > 0)
    {
        if([[mapView.selectedAnnotations objectAtIndex:0] class] == [Location class]){
            [((AnnotationView *)[mapView viewForAnnotation:((Location *)[mapView.selectedAnnotations objectAtIndex:0])]) shrinkToNormal];
        }
        [mapView deselectAnnotation:[mapView.selectedAnnotations objectAtIndex:0] animated:NO];
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

- (void)interactWithLocation:(TriangleButton*)sender{
    Location *currLocation = sender.location;
    [self displayGameObject:currLocation.gameObject fromSource:currLocation];
}

- (void) threeLinesButtonTouched
{
    [super showNav];
}

#pragma mark StateControlProtocol delegate methods

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    [self dismissSelection];
    //ugh this is bad...
    if(g.type == GameObjectItem && [s isKindOfClass:[Location class]])
    {
        ((Item *)g).qty = ((Location *)s).qty;
        ((Item *)g).infiniteQty = ((Location *)s).infiniteQty; 
    }
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

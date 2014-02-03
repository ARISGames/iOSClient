//
//  NoteLocationPickerController.m
//  ARIS
//
//  Created by Phil Dougherty on 1/31/14.
//
//

#import "NoteLocationPickerController.h"
#import "NoteLocationPickerCrosshairsView.h"
#import "ARISTemplate.h"

#import <MapKit/MapKit.h>

@interface NoteLocationPickerController() <MKMapViewDelegate>
{
    CLLocationCoordinate2D location;
    MKMapView *mapView; 
    UIButton *saveButton;
    NoteLocationPickerCrosshairsView *crossHairs;
    id<NoteLocationPickerControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteLocationPickerController

- (id) initWithInitialLocation:(CLLocationCoordinate2D)l delegate:(id<NoteLocationPickerControllerDelegate>)d
{
    if(self = [super init])
    {
        location = l;
        delegate = d;
        
        self.title = NSLocalizedString(@"MapViewTitleKey",@"");
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    mapView = [[MKMapView alloc] init];
	mapView.delegate = self;
    crossHairs = [[NoteLocationPickerCrosshairsView alloc] init];
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    [saveButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:mapView]; 
    [self.view addSubview:crossHairs];  
    [self.view addSubview:saveButton];   
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    mapView.frame    = self.view.bounds;
    crossHairs.frame = self.view.bounds;
    saveButton.frame = CGRectMake(self.view.bounds.size.width-100, self.view.bounds.size.height-60, 80, 40); 
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    mapView.mapType = MKMapTypeSatellite;
    //mapView.mapType = MKMapTypeHybrid;
    //mapView.mapType = MKMapTypeStandard;
    
    //[mapView setShowsUserLocation:NO];
    [self zoomAndCenterMap];
}

- (void) changeMapType:(id)sender
{
    switch(mapView.mapType)
    {
        case MKMapTypeStandard: mapView.mapType = MKMapTypeSatellite; break;
        case MKMapTypeSatellite:mapView.mapType = MKMapTypeHybrid;    break;
        case MKMapTypeHybrid:   mapView.mapType = MKMapTypeStandard;  break;
    }
}

- (void) zoomAndCenterMap
{	
	MKCoordinateRegion region = mapView.region;
	region.center = location;
	region.span = MKCoordinateSpanMake(0.001f, 0.001f);
    
	[mapView setRegion:region animated:YES];
}

- (double) getZoomLevel:(MKMapView *)mV
{
    //Copied and pasted from who knows where
    double MERCATOR_RADIUS = 85445659.44705395;
    double MAX_GOOGLE_LEVELS  = 20;
    CLLocationDegrees longitudeDelta = mV.region.span.longitudeDelta;
    CGFloat mapWidthInPixels = mV.bounds.size.width;
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = MAX_GOOGLE_LEVELS - log2(zoomScale);
    if(zoomer < 0) zoomer = 0;
    return zoomer;
}

- (void) saveButtonTouched
{
    [delegate newLocationPicked:mapView.centerCoordinate];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

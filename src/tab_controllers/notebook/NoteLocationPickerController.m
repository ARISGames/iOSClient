//
//  NoteLocationPickerController.m
//  ARIS
//
//  Created by Phil Dougherty on 1/31/14.
//
//

#import "NoteLocationPickerController.h"

#import <MapKit/MapKit.h>
#import "AnnotationView.h"

@interface NoteLocationPickerController() <MKMapViewDelegate>
{
    MKMapView *mapView;
    CLLocation *location;
    id<NoteLocationPickerControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteLocationPickerController

- (id) initWithInitialLocation:(CLLocation *)l delegate:(id<NoteLocationPickerControllerDelegate>)d
{
    if(self = [super init])
    {
        location = l;
        delegate = d;
        
        self.title = NSLocalizedString(@"MapViewTitleKey",@"");
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    mapView = [[MKMapView alloc] init];
	mapView.delegate = self;
    [self.view addSubview:mapView];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    mapView.frame = self.view.bounds;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    mapView.mapType = MKMapTypeSatellite;
    //mapView.mapType = MKMapTypeHybrid;
    //mapView.mapType = MKMapTypeStandard;
    
    [mapView setShowsUserLocation:NO];
    [self zoomAndCenterMap];
}

- (void) changeMapType:(id)sender
{
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];

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
	region.center = location.coordinate;
	region.span = MKCoordinateSpanMake(0.001f, 0.001f);
    
	[mapView setRegion:region animated:YES];
}

- (double) getZoomLevel:(MKMapView *)mV
{
    double MERCATOR_RADIUS = 85445659.44705395;
    double MAX_GOOGLE_LEVELS  = 20;
    CLLocationDegrees longitudeDelta = mV.region.span.longitudeDelta;
    CGFloat mapWidthInPixels = mV.bounds.size.width;
    double zoomScale = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = MAX_GOOGLE_LEVELS - log2(zoomScale);
    if(zoomer < 0) zoomer = 0;
    return zoomer;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

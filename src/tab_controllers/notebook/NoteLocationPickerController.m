//
//  NoteLocationPickerController.m
//  ARIS
//
//  Created by Phil Dougherty on 1/31/14.
//
//

#import "NoteLocationPickerController.h"
#import "NoteLocationPickerCrosshairsView.h"
#import "AppModel.h"

#import <MapKit/MapKit.h>

@interface NoteLocationPickerController() <MKMapViewDelegate>
{
    CLLocationCoordinate2D location;
    CLLocationCoordinate2D initialLocation;
    MKMapView *mapView;
    UIButton *resetButton;
    MKPointAnnotation *notePoint;
    MKPinAnnotationView *centerAnnotationView;
    id<NoteLocationPickerControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteLocationPickerController

- (id) initWithInitialLocation:(CLLocationCoordinate2D)l delegate:(id<NoteLocationPickerControllerDelegate>)d
{
    if(self = [super init])
    {
        location = l;
        initialLocation = l;
        delegate = d;

        self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SetKey", @""), NSLocalizedString(@"LocationKey", @"")];
    }
    return self;
}

- (void) loadView
{
    [super loadView];

    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonTouched)];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;

    mapView = [[MKMapView alloc] init];

    resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetButton addTarget:self action:@selector(resetButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    resetButton.imageEdgeInsets = UIEdgeInsetsMake(6,6,6,6);
    [resetButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];

    resetButton.backgroundColor =  [UIColor colorWithRed:242/255.0 green:241/255.0 blue:237/255.0 alpha:1];
    resetButton.layer.borderColor = [UIColor whiteColor].CGColor;
    resetButton.layer.borderWidth = 2.0f;

    [self.view addSubview:mapView];
    [self.view addSubview:resetButton];

    notePoint = [[MKPointAnnotation alloc] init];
    notePoint.coordinate = location;
    centerAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:notePoint reuseIdentifier:@"centerAnnotationView"];
    centerAnnotationView.userInteractionEnabled = NO;

    [mapView addSubview: centerAnnotationView];

    mapView.mapType = MKMapTypeStandard;

}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    mapView.frame     = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    resetButton.frame = CGRectMake(
        self.view.bounds.size.width-self.view.bounds.size.width/7-10,
        self.view.bounds.size.height-self.view.bounds.size.width/7-10,
        self.view.bounds.size.width/7,
        self.view.bounds.size.width/7
    );

    MKCoordinateSpan span = MKCoordinateSpanMake(0, 0.01);
    [mapView setRegion:MKCoordinateRegionMake(location, span) animated:NO];

    // Default zoom
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
}

- (void)mapView:(MKMapView *)mapViewA regionDidChangeAnimated:(BOOL)animated {
    CGPoint mapViewPoint = [mapViewA convertCoordinate:mapView.centerCoordinate toPointToView:mapViewA];

    centerAnnotationView.center = mapViewPoint;
    [delegate newLocationPicked:mapView.centerCoordinate];
}

- (void) changeMapType
{
    switch(mapView.mapType)
    {
        case MKMapTypeStandard: mapView.mapType = MKMapTypeSatellite; break;
        case MKMapTypeSatellite:mapView.mapType = MKMapTypeHybrid;    break;
        case MKMapTypeHybrid:   mapView.mapType = MKMapTypeStandard;  break;
    }
}

- (void) resetButtonTouched
{
    [mapView setCenterCoordinate:_MODEL_PLAYER_.location.coordinate animated:YES];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

//
//  NoteLocationPickerController.m
//  ARIS
//
//  Created by Phil Dougherty on 1/31/14.
//
//

#import "NoteLocationPickerController.h"
#import "NoteLocationPickerCrosshairsView.h"

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
    mapView.delegate = self;

    resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetButton setTitle:NSLocalizedString(@"ResetKey", @"") forState:UIControlStateNormal];
    [resetButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    resetButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [resetButton addTarget:self action:@selector(resetButtonTouched) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:mapView];
    [self.view addSubview:resetButton];

    notePoint = [[MKPointAnnotation alloc] init];
    notePoint.coordinate = location;
    centerAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:notePoint reuseIdentifier:@"centerAnnotationView"];
    centerAnnotationView.userInteractionEnabled = NO;

    [mapView addSubview: centerAnnotationView];

    mapView.mapType = MKMapTypeStandard;

    [mapView setCenterCoordinate:location animated:NO];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    mapView.frame     = CGRectMake(0,64,self.view.bounds.size.width,self.view.bounds.size.height-64);
    resetButton.frame = CGRectMake(self.view.bounds.size.width-100, self.view.bounds.size.height-30, 95, 30);
}

- (void)mapView:(MKMapView *)mapViewA regionDidChangeAnimated:(BOOL)animated {
    CGPoint mapViewPoint = [mapViewA convertCoordinate:mapView.centerCoordinate toPointToView:mapViewA];

    centerAnnotationView.center = mapViewPoint;
    [delegate newLocationPicked:mapView.centerCoordinate];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,19,19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(0, 0, 24, 24);
    [saveButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;
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
    [mapView setCenterCoordinate:location animated:YES];
}

- (void) saveButtonTouched
{
    [delegate newLocationPicked:mapView.centerCoordinate];
}

- (void) backButtonTouched
{
    [delegate locationPickerCancelled:self];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

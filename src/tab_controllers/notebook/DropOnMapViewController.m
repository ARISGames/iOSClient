//
//  DropOnMapViewController.m
//  ARIS
//
//  Created by Brian Thiel on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DropOnMapViewController.h"
#import "ARISAppDelegate.h"
#import "AnnotationView.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"
#import "AppServices.h"

static float INITIAL_SPAN = 0.001;

@implementation DropOnMapViewController
@synthesize mapView,mapTypeButton,locations,tracking,toolBar,noteId,myAnnotation,delegate,pickupButton,note;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.title = NSLocalizedString(@"DropOnMapTitleKey", @"");
        self.hidesBottomBarWhenPushed = YES;
        tracking = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"PlayerMoved" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSLog(@"Begin Loading DropOnMap View");
	mapView.showsUserLocation = YES;
	[mapView setDelegate:self];
	[self.view addSubview:mapView];
	NSLog(@"DropOnMapViewController: Mapview inited and added to view");
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DoneKey", @"")
                                                                   style: UIBarButtonItemStyleDone
                                                                  target:self 
                                                                  action:@selector(backButtonTouchAction:)];
    self.navigationItem.leftBarButtonItem = doneButton;

	DDAnnotation *annotation;
    note = [[AppModel sharedAppModel] noteForNoteId:self.noteId playerListYesGameListNo:YES];
    if(note.latitude == 0 && note.longitude == 0)
        annotation= [[DDAnnotation alloc] initWithCoordinate:[AppModel sharedAppModel].player.location.coordinate addressDictionary:nil];
    else
    {
        CLLocationCoordinate2D coord;
        coord.latitude  = note.latitude;
        coord.longitude = note.longitude;
        annotation= [[DDAnnotation alloc] initWithCoordinate:coord addressDictionary:nil];
    }
	annotation.title = @"Drag to Move Note";
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	self.myAnnotation = annotation;
	[self.mapView addAnnotation:annotation];	

    //Setup the buttons
	mapTypeButton.target = self; 
	mapTypeButton.action = @selector(changeMapType:);
	
    pickupButton.target = self; 
	pickupButton.action = @selector(pickupButtonAction:);
}

-(void)viewDidAppear:(BOOL)animated
{    
    if (![AppModel sharedAppModel].player || [AppModel sharedAppModel].currentGame.gameId==0)
    {
        NSLog(@"DropOnMapViewController: Player is not logged in, don't refresh");
        return;
    }
    	
	[self refresh];		
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (refreshTimer)
    {
		[refreshTimer invalidate];
		refreshTimer = nil;
	}
}

- (void)refresh
{
    if(mapView && tracking) [self zoomAndCenterMap];
}

-(void) zoomAndCenterMap
{
	appSetNextRegionChange = YES;
	
	MKCoordinateRegion region = mapView.region;
	region.center = [AppModel sharedAppModel].player.location.coordinate;
	region.span = MKCoordinateSpanMake(INITIAL_SPAN, INITIAL_SPAN);
    
	[mapView setRegion:region animated:YES];
}

- (IBAction)changeMapType:(id)sender
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

-(void)pickupButtonAction:(id)sender
{
    [[self.delegate note] setDropped:NO];
        
    [note setDropped:NO];
    note.latitude = 0;
    note.longitude = 0;
    [[AppServices sharedAppServices]deleteNoteLocationWithNoteId:self.noteId];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backButtonTouchAction:(id)sender{
    [[AppServices sharedAppServices] dropNote:self.noteId atCoordinate:self.myAnnotation.coordinate];
        [note setDropped:YES];
    note.latitude = myAnnotation.coordinate.latitude;
    note.longitude = myAnnotation.coordinate.longitude;
    [[self.delegate note] setDropped:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) shouldAutorotate
{
    return YES;
}

-(NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	//User must have moved the map. Turn off Tracking
	NSLog(@"GPSVC: regionDidChange delegate metohd fired");
    
	if (!appSetNextRegionChange) {
		NSLog(@"GPSVC: regionDidChange without appSetNextRegionChange, it must have been the user");
		tracking = NO;
	}
	appSetNextRegionChange = NO;
}

/*- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view {
	Location *location = ((Annotation*)view.annotation).location;
    if(view.annotation == aMapView.userLocation) return;
	NSLog(@"MapViewController: didSelectAnnotationView for location: %@",location.name);
}*/

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
	if (oldState == MKAnnotationViewDragStateDragging) {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
		annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];		
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{	
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView)
		draggablePinView.annotation = annotation;
    else
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];

	return draggablePinView;
}
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
    if([mp isKindOfClass:[DDAnnotation class]])
    {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
        [mv setRegion:region animated:YES];
        [mv selectAnnotation:mp animated:YES];
    }
}

@end

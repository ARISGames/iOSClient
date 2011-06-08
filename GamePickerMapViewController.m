//
//  GamePickerMapViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "GamePickerMapViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "ARISAppDelegate.h"
#import <UIKit/UIActionSheet.h>
#import "GamesMapAnnotation.h"
#import "GameDetails.h"
#import <MapKit/MapKit.h>


static float INITIAL_SPAN = 20;

@implementation GamePickerMapViewController

@synthesize locations;
@synthesize mapView;
@synthesize tracking;
@synthesize mapTypeButton;
@synthesize playerTrackingButton;
@synthesize toolBar;
@synthesize refreshButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Map";
        self.tabBarItem.image = [UIImage imageNamed:@"gps.png"];
        tracking = YES;
		playerTrackingButton.style = UIBarButtonItemStyleDone;
        
    }
    return self;
}

- (void)dealloc
{
    [mapView release];
    [refreshButton release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;

    
	NSLog(@"Begin Loading GPS View");
	mapView.showsUserLocation = YES;
	[mapView setDelegate:self];
	[self.view addSubview:mapView];
	NSLog(@"GPSViewController: Mapview inited and added to view");
	//Setup the buttons
	mapTypeButton.target = self; 
	mapTypeButton.action = @selector(changeMapType:);
	mapTypeButton.title = NSLocalizedString(@"MapTypeKey",@"");
	
	playerTrackingButton.target = self; 
	playerTrackingButton.action = @selector(refresh);
	playerTrackingButton.style = UIBarButtonItemStyleDone;
    	
    [self refresh];
	
    
	NSLog(@"GPSViewController: View Loaded");
}

-(void)removeLoadingIndicator{
	[[self navigationItem] setRightBarButtonItem:self.refreshButton];
}

- (void) refresh {
	if (mapView) {
        
        //register for notifications
        //register for notifications
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewGameListReady" object:nil];
        [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"RecievedGameList" object:nil];
        [dispatcher addObserver:self selector:@selector(goToGame) name:@"NewGameListReady" object:nil];
        
        //Force an update of the locations
        [[AppServices sharedAppServices] fetchMiniGamesListLocations];
        
        [self showLoadingIndicator];
        
        //Zoom and Center
		if (tracking) [self zoomAndCenterMap];
        
	} else {
		NSLog(@"GPSViewController: refresh requested but ignored, as mapview is nil");	
		
	}
}

- (void)refreshViewFromModel {
	NSLog(@"GPSViewController: Refreshing view from model");
	
	NSLog(@"GPSViewController: refreshViewFromModel: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
    
    //unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	self.locations = [AppModel sharedAppModel].gameList;
	
	if (mapView) {
		//Blow away the old markers except for the player marker
		NSEnumerator *existingAnnotationsEnumerator = [[[mapView annotations] copy] objectEnumerator];
		NSObject <MKAnnotation> *annotation;
		while ((annotation = [existingAnnotationsEnumerator nextObject])) {
			//if (annotation != mapView.userLocation)
            [mapView removeAnnotation:annotation];
		}
        
		//Add the freshly loaded locations from the notification
		for (Game* game in locations ) {
            GamesMapAnnotation *annotation = [[GamesMapAnnotation alloc] initWithTitle:game.name andCoordinate:game.location.coordinate];
            annotation.gameId = game.gameId;
            annotation.rating = game.rating;
            annotation.calculatedScore = game.calculatedScore;
            [mapView addAnnotation:annotation];
        }
	}
	
	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
    
}

-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[barButton release];
	[activityIndicator startAnimating];
}


- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"GPSViewController: Stopping Refresh Timer");
	if (refreshTimer) {
		[refreshTimer invalidate];
		refreshTimer = nil;
	}
}

-(void) zoomAndCenterMap {
	appSetNextRegionChange = YES;
	
	//Center the map on the player
	MKCoordinateRegion region = mapView.region;
	region.center = [AppModel sharedAppModel].playerLocation.coordinate;
	region.span = MKCoordinateSpanMake(INITIAL_SPAN, INITIAL_SPAN);
	[mapView setRegion:region animated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)changeMapType: (id) sender {
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"ticktick" shouldVibrate:NO];
	
	switch (mapView.mapType) {
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


#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	//User must have moved the map. Turn off Tracking
	NSLog(@"GPSVC: regionDidChange delegate metohd fired");
    
	if (!appSetNextRegionChange) {
		NSLog(@"GPSVC: regionDidChange without appSetNextRegionChange, it must have been the user");
		tracking = YES;
		playerTrackingButton.style = UIBarButtonItemStyleBordered;
	}
	
	appSetNextRegionChange = NO;
    
    
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{ 
	
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    
	MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPin"];
	UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annView.rightCalloutAccessoryView = actionButton;
    [actionButton addTarget:self action:@selector(gameWasSelected:) forControlEvents:UIControlEventTouchUpInside];
	annView.animatesDrop=TRUE;  
	annView.canShowCallout = YES;  
	[annView setSelected:YES];  
	//annView.pinColor = MKPinAnnotationColorGreen;  
	//annView.calloutOffset = CGPointMake(-5, 5);  
	return annView;  
}

- (IBAction)gameWasSelected:(id)sender {
    GamesMapAnnotation *selected = [self.mapView.selectedAnnotations objectAtIndex:0];
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self selector:@selector(goToGame) name:@"NewGameListReady" object:nil];
    [[AppServices sharedAppServices] fetchOneGame:selected.gameId];
}

- (void) goToGame {
    NSLog(@"GamePickerMapViewController goToGame");
    
    //unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    Game *selectedGame = [[[AppModel sharedAppModel] gameList] objectAtIndex:0];	
    GameDetails *gameDetailsVC = [[GameDetails alloc]initWithNibName:@"GameDetails" bundle:nil];
    gameDetailsVC.game = selectedGame;
    [self.navigationController pushViewController:gameDetailsVC animated:YES];
    [gameDetailsVC release];
}

- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view {
	//Location *location = ((Annotation*)view.annotation).location;
	//NSLog(@"GPSViewController: didSelectAnnotationView for location: %@",location.name);
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSLog(@"GPSViewController: action sheet button %d was clicked",buttonIndex);
	
	Annotation *currentAnnotation = [mapView.selectedAnnotations lastObject];
	
	if (buttonIndex == actionSheet.cancelButtonIndex) [mapView deselectAnnotation:currentAnnotation animated:YES]; 
	else {
        [currentAnnotation.location display];
        [mapView deselectAnnotation:currentAnnotation animated:YES];
    }
}


@end

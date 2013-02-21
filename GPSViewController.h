//
//  GPSViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Location.h"
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "TileOverlay.h"
#import "TileOverlayView.h"
#import "RootViewController.h"


@interface GPSViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate> {
	IBOutlet MKMapView *mapView;
	NSMutableArray *locations;
    NSMutableArray *route;
	BOOL tracking,mapTrace;
	BOOL appSetNextRegionChange;
	IBOutlet UIBarButtonItem *mapTypeButton;
	IBOutlet UIBarButtonItem *playerTrackingButton;
	IBOutlet UIToolbar *toolBar;
    IBOutlet UIBarButtonItem *addMediaButton;
	NSTimer *refreshTimer;
    IBOutlet UIBarButtonItem *playerButton;
    
}

- (void) refresh;
- (void) zoomAndCenterMap;
- (void) showLoadingIndicator;
- (void) dismissTutorial;
- (void) refreshViewFromModel;
- (void) playerMoved;
- (void) updateOverlays;
- (double) getZoomLevel:(MKMapView *)mV;
- (IBAction) playerButtonTouch;

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) NSMutableArray *locations;
@property (nonatomic) NSMutableArray *route;

@property BOOL tracking;
@property BOOL mapTrace;

@property TileOverlay *overlay;
@property NSMutableArray *overlayArray;

@property (nonatomic) IBOutlet UIBarButtonItem *mapTypeButton;
@property (nonatomic) IBOutlet UIBarButtonItem *playerButton;

@property (nonatomic) IBOutlet UIBarButtonItem *addMediaButton;
@property (nonatomic) IBOutlet UIBarButtonItem *playerTrackingButton;
@property (nonatomic) IBOutlet UIToolbar *toolBar;


@end

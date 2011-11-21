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



@interface GPSViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate> {
	IBOutlet MKMapView *mapView;
	NSArray *locations;
    NSMutableArray *route;
	BOOL tracking,mapTrace;
	BOOL appSetNextRegionChange;
	IBOutlet UIBarButtonItem *mapTypeButton;
	IBOutlet UIBarButtonItem *playerTrackingButton;
	IBOutlet UIToolbar *toolBar;
	int silenceNextServerUpdateCount;
	int newItemsSinceLastView;
    IBOutlet UIBarButtonItem *addMediaButton;
	NSTimer *refreshTimer;

}

-(void) refresh;
-(void) zoomAndCenterMap;
-(void) showLoadingIndicator;
-(void)dismissTutorial;



@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, retain) NSMutableArray *route;


@property BOOL tracking;
@property BOOL mapTrace;



@property (nonatomic, retain) IBOutlet UIBarButtonItem *mapTypeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addMediaButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *playerTrackingButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;


@end

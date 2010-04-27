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



@interface GPSViewController : UIViewController <MKMapViewDelegate> {
	AppModel *appModel;
	MKMapView *mapView;
	NSArray *locations;
	BOOL autoCenter;
	IBOutlet UIBarButtonItem *mapTypeButton;
	IBOutlet UIBarButtonItem *playerTrackingButton;
	BOOL silenceNextServerUpdate;

}

-(void) refresh;
-(void) zoomAndCenterMap;


@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSArray *locations;

@property BOOL autoCenter;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *mapTypeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *playerTrackingButton;

@end

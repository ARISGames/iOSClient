//
//  GPSViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h"
#import "RMMapView.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "Location.h"


@interface GPSViewController : UIViewController {
	NSString *moduleName;
	AppModel *appModel;
	RMMapView *mapView;
	RMMarker *playerMarker;
	RMMarkerManager *markerManager;
	BOOL autoCenter;
}

-(void) setModel:(AppModel *)model;
-(void) refreshMap;
-(void) zoomAndCenterMap;
-(void) refreshPlayerMarker;


@property(copy, readwrite) NSString *moduleName;
@property (nonatomic, retain) RMMapView *mapView;
@property BOOL autoCenter;

@end

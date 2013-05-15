//
//  DropOnMapViewController.h
//  ARIS
//
//  Created by Brian Thiel on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppModel.h"
#import "Location.h"
#import "DDAnnotation.h"
#import "NoteEditorViewController.h"

@interface DropOnMapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate>{
    IBOutlet MKMapView *mapView;
	NSArray *locations;
	BOOL tracking;
	BOOL appSetNextRegionChange;
	IBOutlet UIBarButtonItem *mapTypeButton;
    IBOutlet UIBarButtonItem *pickupButton;
	IBOutlet UIToolbar *toolBar;
    
	int newItemsSinceLastView;
	NSTimer *refreshTimer;
    int noteId;
    DDAnnotation *myAnnotation;
    NoteEditorViewController *__unsafe_unretained delegate;
    Note *note;
}

-(void) refresh;
-(void) zoomAndCenterMap;
- (IBAction)changeMapType: (id) sender;
- (IBAction)pickupButtonAction: (id) sender;
- (IBAction)backButtonTouchAction: (id) sender;

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) NSArray *locations;
@property (nonatomic) DDAnnotation *myAnnotation;
@property(readwrite,assign)int noteId;
@property(nonatomic) Note *note;

@property BOOL tracking;

@property(readwrite,unsafe_unretained)id delegate;
@property (nonatomic) IBOutlet UIBarButtonItem *mapTypeButton;
@property (nonatomic) IBOutlet UIBarButtonItem *pickupButton;
@property (nonatomic) IBOutlet UIToolbar *toolBar;

@end

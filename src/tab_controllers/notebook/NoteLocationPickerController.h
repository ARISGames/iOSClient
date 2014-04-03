//
//  NoteLocationPickerController.h
//  ARIS
//
//  Created by Phil Dougherty on 1/31/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class NoteLocationPickerController;
@protocol NoteLocationPickerControllerDelegate
- (void) newLocationPicked:(CLLocationCoordinate2D)l;
- (void) locationPickerCancelled:(NoteLocationPickerController *)nlp;
@end
@interface NoteLocationPickerController : UIViewController
- (id) initWithInitialLocation:(CLLocationCoordinate2D)l delegate:(id<NoteLocationPickerControllerDelegate>)d;
@end

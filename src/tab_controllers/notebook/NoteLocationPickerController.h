//
//  NoteLocationPickerController.h
//  ARIS
//
//  Created by Phil Dougherty on 1/31/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol NoteLocationPickerControllerDelegate
- (void) newLocationPicked:(CLLocationCoordinate2D)l;
@end
@interface NoteLocationPickerController : UIViewController
- (id) initWithInitialLocation:(CLLocationCoordinate2D)l delegate:(id<NoteLocationPickerControllerDelegate>)d;
@end

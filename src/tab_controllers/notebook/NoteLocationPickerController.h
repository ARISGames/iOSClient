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
@end
@interface NoteLocationPickerController : UIViewController
- (id) initWithInitialLocation:(CLLocation *)l delegate:(id<NoteLocationPickerControllerDelegate>)d;
@end

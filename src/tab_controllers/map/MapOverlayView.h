//
//  MapOverlayView.h
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import <MapKit/MapKit.h>
#import "Overlay.h"

@interface MapOverlayView : MKOverlayView

- (id) initWithOverlay:(Overlay *)o;

@end

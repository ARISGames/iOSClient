//
//  MapOverlayView.h
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import <MapKit/MapKit.h>
#import "CustomMapOverlay.h"

@interface CustomMapOverlayView : MKOverlayView

- (id)initWithCustomOverlay:(CustomMapOverlay *)customOverlay;

@end

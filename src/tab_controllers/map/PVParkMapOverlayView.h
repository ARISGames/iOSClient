//
//  PVParkMapOverlayView.h
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import <MapKit/MapKit.h>

@interface PVParkMapOverlayView : MKOverlayView

- (instancetype) initWithOverlay:(id<MKOverlay>)overlay overlayImage:(UIImage *)overlayImage;

@end

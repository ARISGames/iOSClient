//
//  MapOverlayView.m
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import "CustomMapOverlayView.h"

@implementation CustomMapOverlayView

- (void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    UIImage *image = [UIImage imageNamed:@"overlay_park-351x500.png"];
    CGImageRef imageReference = image.CGImage;
    
    MKMapRect theMapRect = [self.overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    
    CGContextDrawImage(context, theRect, imageReference);
}

@end

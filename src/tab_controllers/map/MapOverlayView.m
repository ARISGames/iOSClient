//
//  MapOverlayView.m
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import "MapOverlayView.h"

@implementation MapOverlayView

- (void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    UIImage *image = [UIImage imageNamed:@"globe-512.png"];
    CGImageRef imageReference = image.CGImage;
    
    MKMapRect theMapRect = [self.overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];
    CGRect clipRect = [self rectForMapRect:mapRect];
    
    CGContextAddRect(context, clipRect);
    CGContextClip(context);
    
    CGContextDrawImage(context, theRect, imageReference);
}

@end

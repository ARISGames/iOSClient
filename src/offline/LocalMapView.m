//
//  LocalMapView.m
//  ARIS
//
//  Created by Miodrag Glumac on 10/17/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import "LocalMapView.h"
#import "LocalMap.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC
#endif

@implementation LocalMapView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    LocalMap* overlay = self.overlay;
    UIImage *image = [overlay mapImage];
    CGContextSetAlpha(context, 0.5);
    
    MKMapRect overlayMapRect = [self.overlay boundingMapRect];
    CGRect overlayRect = [self rectForMapRect:overlayMapRect];
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, image.size.height * [overlay zoom]);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, overlayRect, image.CGImage);
    CGContextRestoreGState(context);
}

@end

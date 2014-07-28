//
//  MapOverlayView.m
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import "MapOverlayView.h"
#import "AppModel.h"
#import "Overlay.h"
#import "ARISMediaView.h"

@interface MapOverlayView()
{
    Overlay *overlay;
    ARISMediaView *mediaView;
    UIImage *imageOverlay;
}
@end

@implementation MapOverlayView

- (id) initWithOverlay:(Overlay *)o
{
    if(self = [super init])
    {
        overlay = o;
        mediaView = [[ARISMediaView alloc] init];
        [mediaView setMedia:[_MODEL_MEDIA_ mediaForId:o.media_id]];
    }
    return self;
}

- (void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    UIImageView *imageView = ([mediaView.subviews[0] isKindOfClass:[UIImageView class]]) ? mediaView.subviews[0] : nil;
    imageOverlay = imageView.image; 
    CGImageRef imageReference = imageOverlay.CGImage;
    
    MKMapRect theMapRect = [overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    
    CGContextDrawImage(context, theRect, imageReference);
}

@end

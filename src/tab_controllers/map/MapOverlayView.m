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
    ARISMediaView *media;
    UIImage *imageOverlay;
}
@end

@implementation MapOverlayView

- (id) initWithCustomOverlay:(Overlay *)customOverlay
{
    if(self = [super init])
    {
        overlay = customOverlay;
        media = [_MODEL_MEDIA_ mediaForId:customOverlay.media_id];
        UIImageView *imageView = ([media.subviews[0] isKindOfClass:[UIImageView class]]) ? media.subviews[0] : nil;
        imageOverlay = imageView.image;
    }
    return self;
}

- (void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    CGImageRef imageReference = imageOverlay.CGImage;
    
    MKMapRect theMapRect = [overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    
    CGContextDrawImage(context, theRect, imageReference);
}

@end

//     File: TileOverlayView.m
// Abstract: 
//     MKOverlayView subclass to display a raster tiled map overlay.
//   
//  Version: 1.0
// 
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
// 
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a personal, non-exclusive
// license, under Apple's copyrights in this original Apple software (the
// "Apple Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
// 
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
// 
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 
// Copyright (C) 2010 Apple Inc. All Rights Reserved.
// 

#import "TileOverlayView.h"
#import "TileOverlay.h"
#import "AppModel.h"

@implementation TileOverlayView

@synthesize tileAlpha;
@synthesize overlayID;

- (id)initWithOverlay:(id <MKOverlay>)overlay
{
    if (self = [super initWithOverlay:overlay])
    {
        tileAlpha = 1;
    }
    return self;
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale
{
    NSArray *tilesInRect;
    for (int i = 0; i < [[AppModel sharedAppModel].overlayList count]; i++)
    {
        tilesInRect = [(TileOverlay *)self.overlay tilesInMapRect:mapRect zoomScale:zoomScale withIndex:i];
        if ([tilesInRect count] > 0) return true;
    }
    //Again (see comment below), why are we iterating? Are we asking "do ANY tilesInRect have > 0 count"? If so, why are we then
    //just using the final one (in drawMapRect:zoomScale:inContext:)? -Phil 3/6/13

    return false;    
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    NSArray *tilesInRect;
    for (int i = 0; i < [[AppModel sharedAppModel].overlayList count]; i++) //count always > 0, otherwise this function wouldn't be called
        tilesInRect = [(TileOverlay *)self.overlay tilesInMapRect:mapRect zoomScale:zoomScale withIndex:i];
    //^ This iterates through an array, and sets 'tilesInRect' to each member, but doesn't do anything with it, resulting in:
    //tilesInRect = [self.overlay tilesInMapRect:mapRect zoomScale:zoomScale withIndex:[[AppModel sharedAppModel].overlayList count]-1];
    //So why don't we just set it to that rather than iterating through stuff? Was this intended to do more than that? -Phil 3/6/13

    CGContextSetAlpha(context, tileAlpha);
    for (ImageTile *tile in tilesInRect)
    {
        CGRect rect = [self rectForMapRect:tile.frame];
        UIImage *image = tile.image;
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, 1/zoomScale, 1/zoomScale);
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
        CGContextRestoreGState(context);
    }
}

@end

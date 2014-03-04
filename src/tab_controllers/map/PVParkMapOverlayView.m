//
//  PVParkMapOverlayView.m
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import "PVParkMapOverlayView.h"

@interface PVParkMapOverlayView ()
@property (nonatomic, strong) UIImage *overlayImage;
@end

@implementation PVParkMapOverlayView

- (instancetype) initWithOverlay:(id<MKOverlay>)overlay overlayImage:(UIImage *)overlayImage
{
    self = [super initWithOverlay:overlay];
}

@end

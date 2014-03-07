//
//  MapOverlay.m
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import "CustomMapOverlay.h"

@interface CustomMapOverlay(){
    CLLocationCoordinate2D upperLeftCoordinate;
    CLLocationCoordinate2D upperRightCoordinate;
    CLLocationCoordinate2D bottomLeftCoordinate;
    ARISMediaView *mediaOverlay;
}

@end

@implementation CustomMapOverlay
@synthesize boundingMapRect;
@synthesize coordinate;
@synthesize mediaOverlay;

-(id)initWithUpperLeftCoordinate:(CLLocationCoordinate2D)upperLeftCoord upperRightCoordinate:(CLLocationCoordinate2D)upperRightCoord bottomLeftCoordinate:(CLLocationCoordinate2D)bottomLeftCoord overlayMedia:(ARISMediaView *)media
{
    self = [super init];
    if (self) {
        upperLeftCoordinate = upperLeftCoord;
        upperRightCoordinate = upperRightCoord;
        bottomLeftCoordinate = bottomLeftCoord;
        mediaOverlay = media;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return upperLeftCoordinate;
}

- (MKMapRect)boundingMapRect
{
    MKMapPoint upperLeft = MKMapPointForCoordinate(upperLeftCoordinate);
    MKMapPoint upperRight = MKMapPointForCoordinate(upperRightCoordinate);
    MKMapPoint bottomLeft = MKMapPointForCoordinate(bottomLeftCoordinate);
    MKMapRect bounds = MKMapRectMake(upperLeft.x, upperLeft.y, fabs(upperLeft.x - upperRight.x), fabs(upperLeft.y - bottomLeft.y));
    return bounds;
}

@end

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
}

@end

@implementation CustomMapOverlay

-(id)initWithUpperLeftCoordinate:(CLLocationCoordinate2D)upperLeftCoord upperRightCoordinate:(CLLocationCoordinate2D)upperRightCoord bottomLeftCoordinate:(CLLocationCoordinate2D)bottomLeftCoord
{
    self = [super init];
    if (self) {
        upperLeftCoordinate = upperLeftCoord;
        upperRightCoordinate = upperRightCoord;
        bottomLeftCoordinate = bottomLeftCoord;
    }
    return self;
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

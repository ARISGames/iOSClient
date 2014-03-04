//
//  MapOverlay.m
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import "MapOverlay.h"

@implementation MapOverlay

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coord1 = {37.434999, -122.16121};
    return coord1;
}

- (MKMapRect)boundingMapRect
{
    MKMapPoint upperLeft = MKMapPointForCoordinate(self.coordinate);
    MKMapRect bounds = MKMapRectMake(upperLeft.x, upperLeft.y, 2000, 2000);
    return bounds;
}

@end

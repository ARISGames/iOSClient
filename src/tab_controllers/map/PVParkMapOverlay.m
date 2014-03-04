//
//  PVParkMapOverlay.m
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import "PVParkMapOverlay.h"
#import "PVPark.h"

@implementation PVParkMapOverlay
@synthesize coordinate;
@synthesize boundingMapRect;


- (instancetype) initWithPark:(PVPark *)park
{
    self = [super init];
    if (self) {
        boundingMapRect = park.overlayBoundingMapRect;
        coordinate = park.midCoordinate;
    }
    return self;
}

@end

//
//  PVParkMapOverlay.h
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class PVPark;

@interface PVParkMapOverlay : NSObject <MKOverlay>

- (instancetype) initWithPark:(PVPark *)park;

@end

//
//  MapOverlay.h
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapOverlay : NSObject

- (MKMapRect) boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end

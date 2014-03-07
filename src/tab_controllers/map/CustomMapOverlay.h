//
//  MapOverlay.h
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ARISMediaView.h"

@interface CustomMapOverlay : NSObject <MKOverlay>

@property (nonatomic) ARISMediaView *mediaOverlay;

-(id)initWithUpperLeftCoordinate:(CLLocationCoordinate2D)upperLeftCoord upperRightCoordinate:(CLLocationCoordinate2D)upperRightCoord bottomLeftCoordinate:(CLLocationCoordinate2D)bottomLeftCoord overlayMedia:(ARISMediaView *)media;

@end

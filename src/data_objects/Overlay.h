//
//  Overlay.h
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//<MKOverlay> adds 'coordinate' and 'boundingMapRect' accessors,
//which are derived on the fly from the raw data
@interface Overlay : NSObject <MKOverlay>
{
  int overlay_id;
  int media_id;
  CLLocation *top_left_corner;
  CLLocation *top_right_corner;
  CLLocation *bottom_left_corner;
}

@property (nonatomic, assign) int overlay_id;
@property (nonatomic, assign) int media_id;
@property (nonatomic, strong) CLLocation *top_left_corner;
@property (nonatomic, strong) CLLocation *top_right_corner;
@property (nonatomic, strong) CLLocation *bottom_left_corner;

- (id) initWithDictionary:(NSDictionary *)dict;

@end

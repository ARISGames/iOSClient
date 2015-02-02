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
  long overlay_id;
  long media_id;
  CLLocation *top_left_corner;
  CLLocation *top_right_corner;
  CLLocation *bottom_left_corner;
}

@property (nonatomic, assign) long overlay_id;
@property (nonatomic, assign) long media_id;
@property (nonatomic, strong) CLLocation *top_left_corner;
@property (nonatomic, strong) CLLocation *top_right_corner;
@property (nonatomic, strong) CLLocation *bottom_left_corner;

- (id) initWithDictionary:(NSDictionary *)dict;

@end

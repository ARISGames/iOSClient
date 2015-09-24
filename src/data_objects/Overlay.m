//
//  Overlay.m
//  ARIS
//
//  Created by Justin Moeller on 3/4/14.
//
//

#import "Overlay.h"
#import "NSDictionary+ValidParsers.h"

@implementation Overlay

@synthesize overlay_id;
@synthesize media_id;
@synthesize top_left_corner;
@synthesize top_right_corner;
@synthesize bottom_left_corner;

- (id) init
{
  if(self = [super init])
  {
    overlay_id         = 0;
    media_id           = 0;
    top_left_corner    = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    top_right_corner   = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    bottom_left_corner = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    overlay_id         = [dict validIntForKey:@"overlay_id"];
    media_id           = [dict validIntForKey:@"media_id"];
    top_left_corner    = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"top_left_latitude"] longitude:[dict validDoubleForKey:@"top_left_longitude"]];
    top_right_corner   = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"top_right_latitude"] longitude:[dict validDoubleForKey:@"top_right_longitude"]];
    bottom_left_corner = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"bottom_left_latitude"] longitude:[dict validDoubleForKey:@"bottom_left_longitude"]];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:[NSString stringWithFormat:@"%ld",overlay_id]];
  [r appendString:[NSString stringWithFormat:@"%ld",media_id]];
  [r appendString:[NSString stringWithFormat:@"%f",top_left_corner.coordinate.latitude]];
  [r appendString:[NSString stringWithFormat:@"%f",top_left_corner.coordinate.longitude]];
  [r appendString:[NSString stringWithFormat:@"%f",top_right_corner.coordinate.latitude]];
  [r appendString:[NSString stringWithFormat:@"%f",top_right_corner.coordinate.longitude]];
  [r appendString:[NSString stringWithFormat:@"%f",bottom_left_corner.coordinate.latitude]];
  [r appendString:[NSString stringWithFormat:@"%f",bottom_left_corner.coordinate.longitude]];
  return r;
}

//MKOverlay stuff
- (CLLocationCoordinate2D) coordinate
{
  return top_left_corner.coordinate;
}

- (MKMapRect) boundingMapRect
{
  MKMapPoint upperLeft = MKMapPointForCoordinate(top_left_corner.coordinate);
  MKMapPoint upperRight = MKMapPointForCoordinate(top_right_corner.coordinate);
  MKMapPoint bottomLeft = MKMapPointForCoordinate(bottom_left_corner.coordinate);
  MKMapRect bounds = MKMapRectMake(upperLeft.x, upperLeft.y, fabs(upperLeft.x - upperRight.x), fabs(upperLeft.y - bottomLeft.y));
  return bounds;
}

@end


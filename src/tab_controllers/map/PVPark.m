//
//  PVPark.m
//  ARIS
//
//  Created by Justin Moeller on 2/28/14.
//  File created for tutorial from here http://www.raywenderlich.com/30001/overlay-images-and-overlay-views-with-mapkit-tutorial
//

#import "PVPark.h"

@implementation PVPark
@synthesize boundary;
@synthesize boundaryPointsCount;

@synthesize midCoordinate;
@synthesize overlayTopLeftCoordinate;
@synthesize overlayTopRightCoordinate;
@synthesize overlayBottomLeftCoordinate;
@synthesize overlayBottomRightCoordinate;

@synthesize overlayBoundingMapRect;
@synthesize name;

- (instancetype) initWithConstants
{
    self = [super init];
    if (self) {
        CGPoint midPoint = CGPointFromString(@"{34.4248,-118.5971}");
        midCoordinate = CLLocationCoordinate2DMake(midPoint.x, midPoint.y);
        
        CGPoint overlayTopLeftPoint = CGPointFromString(@"{34.4311,-118.6012}");
        overlayTopLeftCoordinate = CLLocationCoordinate2DMake(overlayTopLeftPoint.x, overlayTopLeftPoint.y);
        
        CGPoint overlayTopRightPoint = CGPointFromString(@"{34.4311,-118.5912}");
        overlayBottomRightCoordinate = CLLocationCoordinate2DMake(overlayTopRightPoint.x, overlayTopRightPoint.y);
        
        CGPoint overlayBottomLeftPoint = CGPointFromString(@"{34.4194,-118.6012}");
        overlayBottomLeftCoordinate = CLLocationCoordinate2DMake(overlayBottomLeftPoint.x, overlayBottomLeftPoint.y);
        
        NSArray *boundaryPoints = [[NSArray alloc] initWithObjects:@"{34.4313,-118.59890}", @"{34.4274,-118.60246}", @"{34.4268,-118.60181}",
                                   @"{34.4202,-118.6004}", @"{34.42013,-118.59239}", @"{34.42049,-118.59051}", @"{34.42305,-118.59276}",
                                   @"{34.42557,-118.59289}", @"{34.42739,-118.59171}", nil];
        
        boundaryPointsCount = boundaryPoints.count;
        boundary = malloc(sizeof(CLLocationCoordinate2D) * boundaryPointsCount);
        
        for(int i = 0; i < boundaryPointsCount; i++){
            CGPoint p = CGPointFromString(boundaryPoints[i]);
            boundary[i] = CLLocationCoordinate2DMake(p.x, p.y);
        }
    }
    
    return self;
}

- (CLLocationCoordinate2D) overlayBottomRightCoordinate{
    return CLLocationCoordinate2DMake(self.overlayBottomLeftCoordinate.latitude, self.overlayTopRightCoordinate.longitude);
}

- (MKMapRect)overlayBoundingMapRect{
    MKMapPoint topLeft = MKMapPointForCoordinate(self.overlayTopLeftCoordinate);
    MKMapPoint topRight = MKMapPointForCoordinate(self.overlayTopRightCoordinate);
    MKMapPoint bottomLeft = MKMapPointForCoordinate(self.overlayBottomLeftCoordinate);
    
    return MKMapRectMake(topLeft.x, topLeft.y, fabs(topLeft.x - topRight.x), fabs(topLeft.y - bottomLeft.y));
}

@end

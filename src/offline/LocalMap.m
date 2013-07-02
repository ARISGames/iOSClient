//
//  LocalMap.m
//  ARIS
//
//  Created by Miodrag Glumac on 10/14/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import "LocalMap.h"
#import "MMap.h"
#import "MGame.h"
#import "MMedia.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC
#endif

@implementation LocalMap

@synthesize mapImage, zoom;

- (id)initWithGame:(MGame*)game {
    if (self = [super init]) {
        MMap *map = [game.maps anyObject];
        origin = CLLocationCoordinate2DMake([map.latitude doubleValue], [map.longitude doubleValue]);
        NSString *cacheDirectory =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [[cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", game.gameId]] stringByAppendingPathComponent:[map.media filePath]];
        self.mapImage = [UIImage imageWithContentsOfFile:path];
        zoom = [map.zoom doubleValue];
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return origin;
}

- (MKMapRect)boundingMapRect
{
    // Compute the boundingMapRect given the origin, the gridSize and the grid width and height
    MKMapPoint center = MKMapPointForCoordinate(origin);
    
    double height = mapImage.size.height * zoom;
    double width = mapImage.size.width * zoom;
    
    MKMapRect bounds = MKMapRectMake(center.x - width/2, center.y - height/2, width, height);
    
    return bounds;
}


@end

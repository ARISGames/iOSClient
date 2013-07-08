//
//  LocalMap.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/14/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <MapKit/MapKit.h>

#import <Foundation/Foundation.h>

@class MGame;

@interface LocalMap : NSObject <MKOverlay> {

    CLLocationCoordinate2D origin;
    double zoom;
}

@property (retain, nonatomic) UIImage *mapImage;
@property (nonatomic) double zoom;

- (id)initWithGame:(MGame*)game;

@end

//
//  NearbyObjectARCoordinate.h
//  ARIS
//
//  Created by David J Gagnon on 12/6/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARGeoCoordinate.h"
#import "Location.h"


@interface NearbyObjectARCoordinate : ARGeoCoordinate {
	int mediaId;
}

@property(readwrite, assign) int mediaId;

+ (NearbyObjectARCoordinate *)coordinateWithNearbyLocation:(Location *)aNearbyLocation;


@end

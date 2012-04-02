//
//  GamesMapAnnotation.m
//  ARIS
//
//  Created by Philip Dougherty on 6/8/11.
//  Copyright 2011 UW Madison. All rights reserved.
//

#import "GamesMapAnnotation.h"

@implementation GamesMapAnnotation

@synthesize title, coordinate;
@synthesize gameId, rating, calculatedScore;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {
	self = [super init];
	title = ttl;
	coordinate = c2d;
	return self;
}


@end


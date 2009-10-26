//
//  RMProjection.m
//  MapView
//
//  Created by Joseph Gentle on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "proj_api.h"
#import "RMProjection.h"


NS_INLINE RMLatLong RMPixelPointAsLatLong(RMXYPoint xypoint) {
    union _ {RMXYPoint xy; RMLatLong latLong;};
    return ((union _ *)&xypoint)->latLong;
}


@implementation RMProjection

@synthesize internalProjection;
@synthesize bounds;
@synthesize projectionWrapsHorizontally;

- (id) initWithString: (NSString*)params InBounds: (RMXYRect) projBounds
{
	if (![super init])
		return nil;
	
	internalProjection = pj_init_plus([params UTF8String]);
	if (internalProjection == NULL)
	{
		NSLog(@"Unhandled error creating projection. String is %@", params);
		[self dealloc];
		return nil;
	}
	
	bounds = projBounds;

	projectionWrapsHorizontally = YES;
	
	return self;
}

- (id) initWithString: (NSString*)params
{
	RMXYRect theBounds;
	theBounds = RMXYMakeRect(0,0,0,0);
	return [self initWithString:params InBounds:theBounds];
}

-(id)init
{
	return [self initWithString:@"+proj=latlong +ellps=WGS84"];
}

-(void)dealloc
{
	if (internalProjection)
		pj_free(internalProjection);
	
	[super dealloc];
}

- (RMXYPoint) wrapPointHorizontally: (RMXYPoint) aPoint
{
	if (projectionWrapsHorizontally == NO
		|| bounds.size.width == 0.0f || bounds.size.height == 0.0f)
		return aPoint;
	
	while (aPoint.x < bounds.origin.x)
		aPoint.x += bounds.size.width;
	while (aPoint.x > (bounds.origin.x + bounds.size.width))
		aPoint.x -= bounds.size.width;
	
	return aPoint;
}

-(RMXYPoint) constrainPointToBounds: (RMXYPoint) aPoint
{
	if (bounds.size.width == 0.0f || bounds.size.height == 0.0f)
		return aPoint;
	
	[self wrapPointHorizontally:aPoint];
	
	if (aPoint.y < bounds.origin.y)
		aPoint.y = bounds.origin.y;
	else if (aPoint.y > (bounds.origin.y + bounds.size.height))
		aPoint.y = bounds.origin.y + bounds.size.height;
	
	return aPoint;
}

- (RMXYPoint)latLongToPoint:(RMLatLong)aLatLong
{
	projUV uv = {
		aLatLong.longitude * DEG_TO_RAD,
		aLatLong.latitude * DEG_TO_RAD
	};
	
	projUV result = pj_fwd(uv, internalProjection);
	
	RMXYPoint result_point = {
		result.u,
		result.v,
	};
	
	return result_point;
}

- (RMLatLong)pointToLatLong:(RMXYPoint)aPoint
{
	projUV uv = {
		aPoint.x,
		aPoint.y,
	};
	
	projUV result = pj_inv(uv, internalProjection);
	
	RMLatLong result_coordinate = {
		result.v * RAD_TO_DEG,
		result.u * RAD_TO_DEG,
	};
	
	return result_coordinate;
}

static RMProjection* _google = nil;
static RMProjection* _latlong = nil;
static RMProjection* _osgb = nil;

+ (RMProjection*)googleProjection
{
	if (_google)
	{
		return _google;
	}
	else
	{
		RMXYRect theBounds = RMXYMakeRect(-20037508.34, -20037508.34, 20037508.34 * 2, 20037508.34 * 2);
		
		_google = [[RMProjection alloc] initWithString:@"+title= Google Mercator EPSG:900913\
				   +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"
											  InBounds: theBounds];
		return _google;
	}
}

+ (RMProjection*)EPSGLatLong
{
	if (_latlong)
	{
		return _latlong;
	}
	else
	{
		RMXYRect theBounds = RMXYMakeRect(-180, -90, 360, 180);
		
		_latlong = [[RMProjection alloc] initWithString:@"+proj=latlong +ellps=WGS84" InBounds: theBounds];
		return _latlong;
	}
}

+(RMProjection*) OSGB
{
	if (_osgb)
	{
		return _osgb;
	}
	else
	{// OSGB36 and tmerc
		// TODO: This should use the new initWithString:InBounds: method... but I don't know what the bounds are!
		_osgb = [[RMProjection alloc] initWithString:@"+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.999601 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs"];
		_osgb.projectionWrapsHorizontally = NO;
		return _osgb;
	}
}


@end

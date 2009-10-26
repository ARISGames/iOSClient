//
//  RMCachedTileSource.h
//  MapView
//
//  Created by Joseph Gentle on 25/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMTileSource.h"

@class RMTileCache;

// Simple wrapper around a tilesource which checks the image cache first.
@interface RMCachedTileSource : NSObject<RMTileSource>
{
	id <RMTileSource> tileSource;
	RMTileCache *cache;
}

- (id) initWithSource: (id<RMTileSource>) source;
- (void) didReceiveMemoryWarning;

// Bleah ugly name.
+ (RMCachedTileSource*) cachedTileSourceWithSource: (id<RMTileSource>) source;

- (id<RMTileSource>) underlyingTileSource;

@end

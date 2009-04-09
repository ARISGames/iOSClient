/*
 *  Tile.c
 *  RouteMe
 *
 *  Created by Joseph Gentle on 9/09/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "RMTile.h"
#import <math.h>

uint64_t RMTileHash(RMTile tile)
{
	uint64_t accumulator = 0;
	
	for (int i = 0; i < tile.zoom; i++) {
		accumulator |= ((uint64_t)tile.x & (1LL<<i)) << i;
		accumulator |= ((uint64_t)tile.y & (1LL<<i)) << (i+1);
	}
	accumulator |= 1LL<<(tile.zoom * 2);
	
	return accumulator;
}

RMTile RMTileDummy()
{
	RMTile t;
	t.x = -1;
	t.y = -1;
	t.zoom = -1;
	return t;
}

char RMTileIsDummy(RMTile tile)
{
	return tile.x == -1 && tile.y == -1 && tile.zoom == -1;
}

char RMTilesEqual(RMTile one, RMTile two)
{
	return (one.x == two.x) && (one.y == two.y) && (one.zoom == two.zoom);
}

// Round the rectangle to whole numbers of tiles
RMTileRect RMTileRectRound(RMTileRect rect)
{
	rect.size.width = ceilf(rect.size.width + rect.origin.offset.x);
	rect.size.height = ceilf(rect.size.height + rect.origin.offset.y);
	rect.origin.offset.x = 0;
	rect.origin.offset.y = 0;
	
	return rect;
}

/*
// Calculate and return the intersection of two rectangles
TileRect TileRectIntersection(TileRect one, TileRect two)
{
	TileRect intersection;
//	NSCAssert (one.origin.tile.zoom != two.origin.tile.zoom, @"Intersecting tiles do not have matching zoom");
	intersection.origin.tile.x = maxi(one.origin.tile.x, two.origin.tile.x);
	intersection.origin.tile.y = maxi(one.origin.tile.y, two.origin.tile.y);
	
	
	
	return intersection;
}

// Calculate and return the union of two rectangles
TileRect TileRectUnion(TileRect one, TileRect two);*/
//
//  Game.h
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface Game : NSObject {
	int gameId;
	NSString *site;
	NSString *name;
	NSString *description;
	NSString *authors;

	
	CLLocation *location;	
	int numPlayers;
	int pcMediaId;
	int iconMediaId;
}

@property(readwrite, assign) int gameId;
@property(copy, readwrite) NSString *site;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *description;
@property(copy, readwrite) NSString *authors;

@property(copy, readwrite) CLLocation *location;
@property(readwrite, assign) int pcMediaId;
@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) int numPlayers;



- (double)distanceFromPlayer;
- (NSComparisonResult)compareDistanceFromPlayer:(Game*)otherGame;



@end

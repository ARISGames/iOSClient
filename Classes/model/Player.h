//
//  Player.h
//  ARIS
//
//  Created by David Gagnon on 5/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Player : NSObject {
	NSString *name;
	double latitude;
	double longitude;
	BOOL hidden;
}

@property(copy, readwrite) NSString *name;
@property(readwrite) double latitude;
@property(readwrite) double longitude;
@property(readwrite) BOOL hidden;

@end

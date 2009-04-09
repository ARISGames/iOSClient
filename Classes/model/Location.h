//
//  Location.h
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Location : NSObject {
	int locationId;
	NSString *name;
	NSString *latitude;
	NSString *longitude;
	bool hidden;
}

@property(readwrite, assign) int locationId;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *latitude;
@property(copy, readwrite) NSString *longitude;
@property(readwrite) bool hidden;

@end

//
//  NearbyLocation.h
//  ARIS
//
//  Created by David Gagnon on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NearbyLocation : NSObject {
	int locationId;
	NSString *name;
	NSString *type;
	NSString *iconURL;
	NSString *URL;
}

@property(readwrite, assign) int locationId;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *type;
@property(copy, readwrite) NSString *iconURL;
@property(copy, readwrite) NSString *URL;


@end

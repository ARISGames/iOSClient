//
//  Item.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Item : NSObject {
	int itemId;
	NSString *name;
	NSString *description;
	NSString *type;
	NSString *mediaURL;
	NSString *iconURL;
}

@property(readwrite, assign) int itemId;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *description;
@property(copy, readwrite) NSString *type;
@property(copy, readwrite) NSString *mediaURL;
@property(copy, readwrite) NSString *iconURL;

@end

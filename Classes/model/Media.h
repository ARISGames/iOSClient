//
//  Media.h
//  ARIS
//
//  Created by Kevin Harris on 9/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Media : NSObject {
	NSInteger	uid;
	NSString	*url;
	NSString	*type;
	
	//Image Specific Vars
	UIImage		*image; //cache of the image data	
}

@property(readonly) NSInteger	uid;
@property(readonly)	NSString	*url;
@property(readonly) NSString	*type;
@property(retain, readwrite) UIImage	*image;


- (id) initWithId:(NSInteger)anId andUrlString:(NSString *)aUrl ofType:(NSString *)aType;

@end

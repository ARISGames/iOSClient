//
//  Option.h
//  ARIS
//
//  Created by Kevin Harris on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Option : NSObject {
	NSString *text;
	NSInteger nodeId;
}

@property(readwrite, copy) NSString *text;
@property(readwrite, assign) NSInteger nodeId;
- (void)setNodeIdFromString:(NSString *)aString;
@end
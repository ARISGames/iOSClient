//
//  Option.m
//  ARIS
//
//  Created by Kevin Harris on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Option.h"


@implementation Option
@synthesize text, nodeId;
- (void)setNodeIdFromString:(NSString *)aString {
	nodeId = [aString intValue];
}
@end

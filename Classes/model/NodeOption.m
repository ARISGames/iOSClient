//
//  Option.m
//  ARIS
//
//  Created by Kevin Harris on 5/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "NodeOption.h"

@implementation NodeOption
@synthesize text, nodeId, hasViewed;

- (NodeOption *) initWithText:(NSString *)optionText andNodeId: (int)optionNodeId 
                 andHasViewed:(BOOL)hasViewedB{
	if (self = [super init]) {
		self.text = optionText;
		self.nodeId = optionNodeId;
        self.hasViewed = hasViewedB;
	}
	return self;
}


@end

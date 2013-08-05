//
//  NpcScriptOption.h
//  ARIS
//
//  Created by Kevin Harris on 5/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "NpcScriptOption.h"

@implementation NpcScriptOption

@synthesize optionText;
@synthesize scriptText;
@synthesize nodeId;
@synthesize hasViewed;

- (id) initWithOptionText:(NSString *)t scriptText:(NSString *)s nodeId:(int)n hasViewed:(BOOL)v;
{
	if(self = [super init])
    {
		self.optionText = t;
		self.scriptText = s;
		self.nodeId = n;
        self.hasViewed = v;
	}
	return self;
}


@end

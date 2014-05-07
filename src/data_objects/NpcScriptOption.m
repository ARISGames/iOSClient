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
@synthesize plaque_id;
@synthesize hasViewed;

- (id) initWithOptionText:(NSString *)t scriptText:(NSString *)s plaque_id:(int)n hasViewed:(BOOL)v;
{
	if(self = [super init])
    {
		self.optionText = t;
		self.scriptText = s;
		self.plaque_id = n;
        self.hasViewed = v;
	}
	return self;
}


@end

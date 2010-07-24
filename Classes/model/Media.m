//
//  Media.m
//  ARIS
//
//  Created by Kevin Harris on 9/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Media.h"


@implementation Media
@synthesize uid, url, type, image;

- (id) initWithId:(NSInteger)anId andUrlString:(NSString *)aUrl ofType:(NSString *)aType {
	assert(anId > 0 && @"Non-natural ID.");
	assert(aUrl && [aUrl length] > 0 && @"Empty url string.");
	assert(aType && [aType length] > 0 && "@Empty type.");
	
	if (self = [super init]) {
		uid = anId;
		url = [aUrl retain];
		type = [aType retain];
	}
	
	return self;
}

- (void)dealloc {
	[url release];
	[type release];
	[image release];
    [super dealloc];
}

@end

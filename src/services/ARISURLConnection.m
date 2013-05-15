//
//  ARISURLConnection.m
//  ARIS
//
//  Created by Brian Deith on 11/10/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "ARISURLConnection.h"


@implementation ARISURLConnection
@synthesize parser;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate parser:(SEL)aParser {
	if (self = [self initWithRequest:(NSURLRequest *)request delegate:(id)delegate]) {
		self.parser = aParser;
	}
	return self;
}


@end

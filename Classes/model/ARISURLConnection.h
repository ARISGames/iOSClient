//
//  ARISURLConnection.h
//  ARIS
//
//  Created by Brian Deith on 11/10/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ARISURLConnection : NSURLConnection {
	
	SEL parser;
}

@property(readwrite) SEL parser;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate parser:(SEL)parser;

@end

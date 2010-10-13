//
//  JSONResult.h
//  ARIS
//
//  Created by David J Gagnon on 8/27/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JSONResult : NSObject {
	int returnCode;
	NSString *returnCodeDescription;
	NSObject *data;
	NSString *hash;
}

@property(readwrite) int returnCode;
@property(copy, readwrite) NSString *returnCodeDescription;
@property(copy, readwrite) NSObject *data;
@property(copy, readwrite) NSString *hash;


- (JSONResult*)initWithJSONString:(NSString *)JSONString;
- (NSObject*) parseJSONData:(NSObject *)dictionary;



@end



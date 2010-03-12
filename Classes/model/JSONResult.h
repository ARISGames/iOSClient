//
//  JSONResult.h
//  ARIS
//
//  Created by David J Gagnon on 8/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JSONResult : NSObject {
	int returnCode;
	NSString *returnCodeDescription;
	NSObject *data;
	NSInteger hash;
}

@property(readwrite) int returnCode;
@property(copy, readwrite) NSString *returnCodeDescription;
@property(copy, readwrite) NSObject *data;
@property(readonly) NSInteger hash;



- (JSONResult*)initWithJSONString:(NSString *)JSONString;
- (NSObject*) parseJSONData:(NSObject *)dictionary;



@end



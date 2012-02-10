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
    NSDictionary *userInfo;
	NSString *hash;
}

@property(readwrite) int returnCode;
@property(copy, readwrite) NSString *returnCodeDescription;
@property(copy, readwrite) NSObject *data;
@property(copy, readwrite) NSDictionary *userInfo;
@property(copy, readwrite) NSString *hash;


- (JSONResult*)initWithJSONString:(NSString *)JSONString andUserData:(NSDictionary *)userData;
- (NSObject*) parseJSONData:(NSObject *)dictionary;



@end



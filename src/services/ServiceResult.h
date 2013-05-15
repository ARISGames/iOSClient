//
//  ServiceResult.h
//  ARIS
//
//  Created by David J Gagnon on 8/27/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceResult : NSObject
{
	int returnCode;
	NSString *returnCodeDescription;
	NSObject *data;
    NSDictionary *userInfo;
}

@property(readwrite) int returnCode;
@property(copy, readwrite) NSString *returnCodeDescription;
@property(copy, readwrite) NSObject *data;
@property(copy, readwrite) NSDictionary *userInfo;

- (id) initWithJSONString:(NSString *)JSONString andUserData:(NSDictionary *)userData;
- (NSObject*) parseJSONData:(NSObject *)dictionary;

@end

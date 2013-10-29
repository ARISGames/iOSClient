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

@property(nonatomic, assign) int returnCode;
@property(nonatomic, strong) NSString *returnCodeDescription;
@property(nonatomic, strong) NSObject *data;
@property(nonatomic, strong) NSDictionary *userInfo;

- (id) initWithJSONString:(NSString *)JSONString andUserData:(NSDictionary *)userData;

@end

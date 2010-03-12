//
//  JSONConnection.h
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONResult.h"


@interface JSONConnection : NSObject{
	NSString *jsonServerBaseURL;
	NSString *serviceName;
	NSString *methodName;
	NSArray *arguments;
	NSMutableData *asyncData;
}

@property(copy, readwrite) NSString *jsonServerBaseURL;
@property(copy, readwrite) NSString *serviceName;
@property(copy, readwrite) NSString *methodName;
@property(copy, readwrite) NSArray *arguments;

- (JSONConnection*)initWithArisJSONServer: (NSString *)server
					andServiceName:(NSString *)serviceName 
					andMethodName:(NSString *)methodName
					andArguments:(NSArray *)arguments;

- (JSONResult*) performSynchronousRequest;
- (void) performAsynchronousRequestWithParser: (SEL)parser;

@end

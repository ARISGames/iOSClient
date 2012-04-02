//
//  JSONConnection.h
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONResult.h"


@interface JSONConnection : NSObject  <NSURLConnectionDelegate>{
	NSURL *jsonServerURL;
	NSString *serviceName;
	NSString *methodName;
	NSArray *arguments;
    NSString *handler;
    NSMutableDictionary *userInfo;
	NSMutableData *asyncData;
	NSURL *completeRequestURL;
    NSURLConnection *connection;
}

@property(nonatomic, retain) NSURL *jsonServerURL;
@property(nonatomic, retain) NSString *serviceName;
@property(nonatomic, retain) NSString *methodName;
@property(nonatomic, retain) NSArray *arguments;
@property(nonatomic, retain) NSString *handler;
@property(nonatomic, retain) NSMutableDictionary *userInfo;
@property(nonatomic, retain) NSURL *completeRequestURL;
@property(nonatomic, retain) NSMutableData *asyncData;
@property(nonatomic, retain) NSURLConnection *connection;



- (JSONConnection*)initWithServer: (NSURL *)server
					andServiceName:(NSString *)serviceName 
					andMethodName:(NSString *)methodName
					andArguments:(NSArray *)arguments
                      andUserInfo:(NSMutableDictionary *)userInfo;

- (JSONResult*) performSynchronousRequest;
- (void) performAsynchronousRequestWithHandler: (SEL)handler;
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection;
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;


@end

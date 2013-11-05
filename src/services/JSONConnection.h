//
//  JSONConnection.h
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceResult : NSObject
{
    NSObject *data;
    NSDictionary *userInfo;
   	NSMutableData *asyncData; 
    NSURL *url;
    NSURLConnection *connection; 
    id __unsafe_unretained handler;
    SEL successSelector; 
    SEL failSelector;   
    
    NSDate *start;
    NSTimeInterval time;
};
@property (nonatomic, strong) NSObject *data;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSMutableData *asyncData;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) id handler;
@property (nonatomic, assign) SEL successSelector;
@property (nonatomic, assign) SEL failSelector;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, assign) NSTimeInterval time;
@end

@interface JSONConnection : NSObject  

- (id) initWithServer:(NSString *)server;
- (void) performAsynchronousRequestWithService:(NSString *)service method:(NSString *)m arguments:(NSArray *)args handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs userInfo:(NSDictionary *)dict;
- (ServiceResult *) performSynchronousRequestWithService:(NSString *)service method:(NSString *)m arguments:(NSArray *)args userInfo:(NSDictionary *)dict;

- (void) performAsyncRequestWithURL:(NSURL *)url handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs userInfo:(NSDictionary *)dict;
- (ServiceResult *) performSyncRequestWithURL:(NSURL *)url userInfo:(NSDictionary *)dict;
- (NSURL *) createRequestURLFromService:(NSString *)service method:(NSString *)method arguments:(NSArray *)args;

@end

//
//  ARISConnection.h
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServiceResult;

@interface ARISConnection : NSObject  

- (id) initWithServer:(NSString *)server;
- (void) performAsynchronousRequestWithService:(NSString *)s method:(NSString *)m arguments:(NSDictionary *)args handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs userInfo:(NSDictionary *)dict;
- (ServiceResult *) performSynchronousRequestWithService:(NSString *)s method:(NSString *)m arguments:(NSDictionary *)args userInfo:(NSDictionary *)dict;

@end

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

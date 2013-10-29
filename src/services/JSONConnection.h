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
};
@property (nonatomic, strong) NSObject *data;
@property (nonatomic, strong) NSDictionary *userInfo;
- (id) initWithData:(NSObject *)d userInfo:(NSDictionary *)u;
@end

@interface JSONConnection : NSObject  

- (JSONConnection*) initWithServer:(NSURL *)server
                    andServiceName:(NSString *)serviceName 
                     andMethodName:(NSString *)methodName
                      andArguments:(NSArray *)arguments
                       andUserInfo:(NSMutableDictionary *)userInfo;

- (ServiceResult *) performSynchronousRequest;
- (void) performAsynchronousRequestWithHandler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs;

@end

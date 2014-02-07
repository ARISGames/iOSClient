//
//  ARISConnection.h
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARISServiceResult;
@class ARISServiceGraveyard;
@class RequestCD;

@interface ARISConnection : NSObject  

- (id) initWithServer:(NSString *)s graveyard:(ARISServiceGraveyard *)g;
- (void) performAsynchronousRequestWithService:(NSString *)s method:(NSString *)m arguments:(NSDictionary *)args handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs retryOnFail:(BOOL)r userInfo:(NSDictionary *)dict;
- (ARISServiceResult *) performSynchronousRequestWithService:(NSString *)s method:(NSString *)m arguments:(NSDictionary *)args userInfo:(NSDictionary *)dict;

- (void) performRevivalWithRequest:(RequestCD *)r;

@end

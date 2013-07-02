//
//  NSURLConnection+block.h
//  ARIS
//
//  Created by Miodrag Glumac on 9/16/11.
//  Copyright 2012 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NSURLConnectionFinishBlock)(NSData*);
typedef void(^NSURLConnectionErrorBlock)(NSError*);
typedef void(^NSURLConnectionProgressBlock)(float);

@interface NSURLConnection (NSURLConnection_block)

- (id)initWithRequest:(NSURLRequest *)request finishBlock:(NSURLConnectionFinishBlock)block errorBlock:(NSURLConnectionErrorBlock)errorBlock;
- (id)initWithRequest:(NSURLRequest *)request finishBlock:(NSURLConnectionFinishBlock)block errorBlock:(NSURLConnectionErrorBlock)errorBlock progressBlock:(NSURLConnectionProgressBlock)progressBlock;

@end

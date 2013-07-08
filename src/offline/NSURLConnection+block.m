//
//  NSURLConnection+block.m
//  ARIS
//
//  Created by Miodrag Glumac on 9/16/11.
//  Copyright 2012 Amherst College. All rights reserved.
//

#import "NSURLConnection+block.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC
#endif

@interface  DownloadDelegate : NSObject {
    long long _downloadSize;
}

@property (nonatomic, strong) NSURLConnectionFinishBlock finishBlock;
@property (nonatomic, strong) NSURLConnectionErrorBlock errorBlock;
@property (nonatomic, strong) NSURLConnectionProgressBlock progressBlock;

@property (nonatomic, strong) NSMutableData *receivedData;

- (id)initWithBlock:(NSURLConnectionFinishBlock)block;
- (id)initWithBlock:(NSURLConnectionFinishBlock)block errorBlock:(NSURLConnectionErrorBlock)errorBlock;

@end

@implementation DownloadDelegate

@synthesize finishBlock, errorBlock, progressBlock, receivedData;

- (id)initWithBlock:(NSURLConnectionFinishBlock)block {
    if (self = [self init]) {
        self.finishBlock = block;
        self.receivedData = [[NSMutableData alloc] init];
    }
    return self;
}

- (id)initWithBlock:(NSURLConnectionFinishBlock)block errorBlock:(NSURLConnectionErrorBlock)eBlock {
    if (self = [self initWithBlock:block]) {
        self.errorBlock = eBlock;
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (errorBlock) {
        errorBlock(error);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    if (progressBlock) {
        float progress = ((float) [receivedData length] / (float) _downloadSize);
        progressBlock(progress);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (progressBlock) {
        _downloadSize = [response expectedContentLength];
        progressBlock(0.0);
    }
    
    [receivedData setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    finishBlock(receivedData);
}

@end

@implementation NSURLConnection (NSURLConnection_block)

- (id)initWithRequest:(NSURLRequest *)request finishBlock:(NSURLConnectionFinishBlock)block errorBlock:(NSURLConnectionErrorBlock)errorBlock {
    DownloadDelegate *delegate = [[DownloadDelegate alloc] initWithBlock:block errorBlock:errorBlock];
    if (self = [self initWithRequest:request delegate:delegate]) {
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request finishBlock:(NSURLConnectionFinishBlock)block errorBlock:(NSURLConnectionErrorBlock)errorBlock progressBlock:(NSURLConnectionProgressBlock)progressBlock {
    DownloadDelegate *delegate = [[DownloadDelegate alloc] initWithBlock:block errorBlock:errorBlock];
    delegate.progressBlock = progressBlock;
    if (self = [self initWithRequest:request delegate:delegate]) {
    }
    return self;
}

@end

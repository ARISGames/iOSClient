//
//  ARISServiceResult.m
//  ARIS
//
//  Created by Phil Dougherty on 2/7/14.
//
//

#import "ARISServiceResult.h"

@implementation ARISServiceResult

@synthesize humanDescription;
@synthesize resultData;
@synthesize userInfo;
@synthesize asyncData;
@synthesize urlRequest;
@synthesize connection;
@synthesize handler;
@synthesize successSelector;
@synthesize failSelector;
@synthesize retryOnFail;
@synthesize start;
@synthesize time;

- (void) dealloc
{
    [self.connection cancel];
}
@end
